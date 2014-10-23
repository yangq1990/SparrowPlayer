package com.xinguoedu.m.media.httpm
{
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.media.SegmentEvt;
	import com.xinguoedu.utils.MetadataUtil;
	
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/**
	 * 视频 分段
	 * @author yatsen_yang
	 * 
	 */	
	public class Segment extends EventDispatcher
	{
		private var _ismp4:Boolean;
		private var _stream:NetStream;
		/** Object with keyframe times and positions. **/
		private var _keyframes:Object;
		/** 当前分段视频的时长 **/
		private var _duration:Number = 0;
		/** 计时器 **/
		private var _posInterval:uint;
		/** 分段是否被激活 **/
		private var _isActive:Boolean;
		/** 分段地址 **/
		private var _url:String;
		/** 是否已收到metadata **/
		private var _hasMetadata:Boolean = false;
		/** 播放头位置 **/
		private var _pos:Number;
		/** 指定在开始显示流之前需要多长时间将消息存入缓冲区 **/
		private var _bufferTime:Number;
		/** 缓冲区被填满的程度  **/
		private var _bufferFill:Number;
		/** 视频缓存到本地的百分比 **/
		private var _bufferPercent:Number;
		/** 缓冲区是否被填满 **/
		private var _isBufferFull:Boolean;
		/** 分段是否播放完**/
		private var _isComplete:Boolean;
		/** 上次seek的时间点 **/
		private var _sec:Number;
		/** 等到缓冲区满后是否要切换画面 **/
		private var _isToSwitch:Boolean;
		/** 是否需要提前加载下一个segment **/
		private var _isToPreloadNext:Boolean;
		/** 根据seek时间获取到的关键帧的timestamp **/
		private var _kfTime:Number=0;
		/** 获取到metadata后开始seek**/
		private var _seekAfterMetadata:Boolean;
		/** 分段是否播放完 **/
		private var _isPlaybackComplete:Boolean;
		
		
		public function Segment(nc:NetConnection, url:String)
		{
			_url = url;
			_stream = new NetStream(nc);			
			_stream.bufferTime = 5;		
			_stream.client = this;		
			addStreamListeners();
		}
		
		private function addStreamListeners():void
		{
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		/**
		 * 视频metadata处理函数 
		 * @param info
		 * 
		 */		
		public function onMetaData(info:Object):void
		{
			if (info['seekpoints']) 
			{
				_ismp4 = true;
				_keyframes = convertSeekpoints(info['seekpoints']);
			}
			else
			{
				_ismp4 = false;
				_keyframes = info['keyframes']; //记录关键帧的位置
			}
			
			_hasMetadata = true;
			_duration = info.duration;
			dispatchEvent(new SegmentEvt(SegmentEvt.METADATA, {w:info.width, h:info.height}));
			
			if(_seekAfterMetadata)
			{
				seek(_kfTime);
				_seekAfterMetadata = false;
			}
		}
		
		protected function convertSeekpoints(dat:Object):Object 
		{
			var kfr:Object = {};
			kfr.times = [];
			kfr.filepositions = [];
			for (var j:String in dat)
			{
				kfr.times[j] = Number(dat[j]['time']);
				kfr.filepositions[j] = Number(dat[j]['offset']);
			}
			return kfr;
		}
		
		
		public function get isActive():Boolean
		{
			return _isActive;
		}
		
		public function set isActive(bool:Boolean):void
		{
			_isActive = bool;
			if(bool)
			{
				destroyPosTimer();
				_posInterval = setInterval(positionInterval, 100);
			}
		}
		
		/**
		 * 加载分段视频 
		 */		
		public function load(start:Number=0):void
		{
			if(!_stream.hasEventListener(NetStatusEvent.NET_STATUS))
			{
				addStreamListeners();
			}
			
			if(_hasMetadata && start > 0)
			{
				seek(start);
			}
			else
			{
				if(start > 0)
				{
					_kfTime = start;
					_seekAfterMetadata = true;
				}				
				_stream.play(_url);
			}
			
			dispatchEvent(new SegmentEvt(SegmentEvt.LOAD_SEGMENT));
		}
		
		/** 清除定时器 **/
		private function destroyPosTimer():void
		{
			if(_posInterval)
			{
				clearInterval(_posInterval);
				_posInterval = undefined;	
			}
		}
		
		/** 定时调用函数 **/
		private function positionInterval():void
		{
			if(!_hasMetadata || _duration <= 0)
				return;
			
			if(_isBufferFull && _isToSwitch) //避免segment切换时画面不切换的bug
			{
				_isToSwitch = false;
				dispatchEvent(new SegmentEvt(SegmentEvt.SWITCH));
				_stream.resume();
			}
			
			_pos = _stream.time;
			
			if(_kfTime > 0) //拖动过
			{
				_bufferTime = _stream.bufferTime < (_pos - _kfTime) ? _stream.bufferTime : Math.ceil(_pos - _kfTime);
			}
			else
			{
				_bufferTime = _stream.bufferTime < (_duration - _pos) ? _stream.bufferTime : Math.ceil(_duration - _pos);				
			}
			
			_bufferFill = _stream.bufferTime ? (_stream.bufferLength/_stream.bufferTime) * 100 : 0;
			_bufferPercent = _stream.bytesTotal ? (_stream.bytesLoaded / _stream.bytesTotal) : 0;
			
			if (_bufferFill <= 80 && (_duration - _pos) > 5) 
			{
				_isBufferFull = false;
				//_stream.pause();			
				//此处的bufferPercent指的是内存区填满的程度
				//EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADING, {pos:_pos+elapsedDuration, bufferPercent:_bufferFill/100}));
			} 
			else if (_bufferFill > 95 && !_isBufferFull) 
			{
				_isBufferFull = true;
				_stream.resume();
			}
			
			if (_pos < _duration) 
			{
				/** 
				 * position 播放头的位置,以秒为单位
				 * segmentDuration 分段视频时长
				 * bufferDuration 视频缓存到本地的时长
				 * **/			
				dispatchEvent(new SegmentEvt(SegmentEvt.TIME, 
					{
						position:_pos, 
						segmentDuration:_duration, 
						bufferDuration: _kfTime + _bufferPercent * (_duration - _kfTime)
					}));
				//当前分段视频即将播放完，提前20s加载下一个视频
				if(!_isToPreloadNext && (_duration - _pos <= 20))
				{
					_isToPreloadNext = true;
					dispatchEvent(new SegmentEvt(SegmentEvt.PRELOAD_NEXT));
				}
			}
			else if (_duration > 0) 
			{
				complete();
			}
			
		}
		
		private function complete():void
		{
			if(!_isPlaybackComplete)
			{
				_isPlaybackComplete = true;
				dispatchEvent(new SegmentEvt(SegmentEvt.COMPLETE));
			}		
		}
		
		/**
		 * 分段视频流的引用 
		 * @return  
		 * 
		 */		
		public function get stream():NetStream
		{
			return _stream;
		}
		
		/**
		 * 释放资源 
		 * 
		 */		
		public function destroy():void
		{
			destroyPosTimer();
			
			if(_stream != null)
			{
				_stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				_stream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_stream.close();
			}		
			
			_isActive = _isToSwitch = _isToPreloadNext = _seekAfterMetadata = _isPlaybackComplete = false;
		}
		
		public function play():void
		{
			if(!_posInterval)
			{
				_posInterval = setInterval(positionInterval, 100);
			}
			
			if(_isComplete)
			{
				_stream.play(_url);
			}
			else
			{
				_stream.resume();
			}		
		}
		
		public function pause():void
		{
			_stream.pause();
		}
		
		public function mouseDownToSeek():void
		{
			destroyPosTimer();
		}
		
		/**
		 * 拖动视频 
		 * @param sec 要拖动的时间点
		 * 
		 */		
		public function seek(sec:Number):void
		{
			if(Math.abs(_sec - sec) <= 0.01) //修复重复请求的bug
				return;
			
			_sec = sec;
			destroyPosTimer();
			
			if(sec <= 0) //play from start
			{
				trace("play from start");
				_stream.close();
				_stream.play(_url);
				return;
			}			
			
			//已缓存到本地的视频长度
			//var cachedDuration:Number = (_bufferPercent >= 1 ? _duration : _stream.time + _bufferPercent * _duration);			
			_kfTime = MetadataUtil.getOffset(_keyframes, sec, true);
			if(sec >= _duration)
			{
				complete();
			}
			else
			{
				if(!_ismp4)
				{
					_stream.close();
					_stream.play(_url + "?start=" + MetadataUtil.getOffset(_keyframes, sec, false)); //从指定位置开始加载, 需要nginx支持start参数
				}
			}		
		}
		
		private function netStatusHandler(evt:NetStatusEvent):void
		{
			//trace("evt.info.code--->", evt.info.code, _url);
			switch(evt.info.code)
			{
				case StreamStatus.PLAY_START: //开始播放
					if(_isActive)
					{
						dispatchEvent(new SegmentEvt(SegmentEvt.PLAY_START, _bufferFill >= 100 ? 100 : _bufferFill));
					}
					break;
				case StreamStatus.BUFFER_FULL: //无拖动或者拖动后缓冲区满
					if(_isToSwitch)
					{
						_isToSwitch = false;
						dispatchEvent(new SegmentEvt(SegmentEvt.SWITCH));
					}
					
					if(_isActive)
					{
						!_posInterval && (_posInterval = setInterval(positionInterval, 100));
					}
					else
					{
						_stream.pause();
					}
					_isBufferFull = true;
					break;
				case StreamStatus.PAUSE_NOTIFY:
					//某些情况下，视频离结束还有几秒的时候，会触发
				case StreamStatus.PLAY_STOP:
					//complete();
					break;
				default:
					break;
			}
			
			dispatchEvent(new SegmentEvt(SegmentEvt.NET_STATUS, evt.info.code));
		}
		
		/**
		 *  Receive NetStream playback codes
		 *  
		 * */
		public function onPlayStatus(... rest):void 
		{
			for each (var dat:Object in rest) 
			{
				if (dat && dat.hasOwnProperty('code') && dat.code == "NetStream.Play.Complete") 
				{
					complete(); //播放完 					
				}
			}
		}	
		
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			dispatchEvent(new SegmentEvt(SegmentEvt.LOAD_SEGMENT_IOERROR));
		}

		/** 等到缓冲区满后是否要切换画面 **/
		public function get isToSwitch():Boolean
		{
			return _isToSwitch;
		}

		/**
		 * seek到一个新的segment, 在这个segment开始播放前，画面一直停留在拖动前的segment
		 * 等到该segment buffer full的时候切换换面，这样子做是为了避免黑屏
		 */
		public function set isToSwitch(value:Boolean):void
		{
			_isToSwitch = value;
		}

		public function setVolume(volume:int):void
		{
			if(_stream != null && _stream.soundTransform.volume != volume / 100)
			{
				_stream.soundTransform = new SoundTransform(volume / 100);
			}
		}
	}
}