package com.xinguoedu.m.media
{
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.vo.MediaVO;
	import com.xinguoedu.utils.Logger;
	
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.setInterval;

	/**
	 * 普通的http视频，包括flv, mp4, f4v 
	 * @author yatsen_yang
	 * 
	 */	
	public class HttpMedia extends BaseMedia
	{
		/** 缓冲区被填满的程度 **/
		private var _bufferFill:Number;
		/** 缓冲区是否被填满 **/
		private var _bufferFull:Boolean;
		/** 缓冲区视频秒数 **/
		private var _bufferTime:Number;	
		/** 视频是否完全缓存到本地 **/
		private var _bufferingComplete:Boolean;
		/** 上一次拖动的时间 **/
		private var _sec:Number = 0;
		
		public function HttpMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function init(mediaVO:MediaVO):void
		{
			super.init(mediaVO);
			
			_nc = new NetConnection();
			_nc.connect(null);
			
			_stream = new NetStream(_nc);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_stream.client = this;
			//检查策略文件
			mediaVO.checkPolicyFile && (_stream.checkPolicyFile = true);
			_stream.bufferTime = 5;			
			
			_video = new Video();
			_video.smoothing = true;
			_video.attachNetStream(_stream);			
			_display.addChild(_video);
			
			mediaVO.autostart && startLoadAndPlay();
		}	
		
		override public function startLoadAndPlay():void
		{
			_stream.play(_mediaVO.url);
			destroyPosTimer();
			_posInterval = setInterval(positionInterval, 100);				
			dispatchEvt(StreamStatus.START_LOAD_MEDIA);
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADING, {bufferPercent:0}));
		}
		
		override protected function netStatusHandler(evt:NetStatusEvent):void
		{
			trace('httpmideia---->', evt.info.code);
			switch(evt.info.code)
			{
				case StreamStatus.BUFFER_FULL: //无拖动或者拖动后缓冲区满
					!_posInterval && (_posInterval = setInterval(positionInterval, 100));
					break;
				case StreamStatus.SEEK_COMPLETE:
					play();
					break;
				case StreamStatus.PLAY_STOP:
					complete();
					break;
				default:
					break;
			}
			
			dispatchEvt(evt.info.code);
		}
		
		private function positionInterval():void
		{
			//!_ismp4 && (_kfTime = 0);
			if(_duration <= 0)
				return;
			
			_pos = _stream.time;
			
			/*if (_duration > 0 && _stream) 
			{
				_bufferTime = _stream.bufferTime < (_duration - _pos) ? _stream.bufferTime : Math.ceil(_duration - _pos);
				_bufferFill = _stream.bufferTime ? Math.ceil(Math.ceil(_stream.bufferLength) / _bufferTime * 100) : 0;
			}*/
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
			
			if (_bufferFill <= 95 && (_duration - _pos) > 5) 
			{
				_bufferFull = false;
				//_stream.pause();				
				EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADING, {percent:_bufferFill/100}));
			} 
			else if (_bufferFill > 95 && !_bufferFull) 
			{
				_bufferFull = true;
				_stream.resume();
			}
			
			if (_pos < _duration) 
			{
				/** 
				 * 数据结构,为提高效率，事件直接派发，由controlbarComp接收处理
				 * position 播放头的位置,以秒为单位
				 * duration 视频时长
				 * bufferDuration 视频缓存到本地的时长
				 * 
				 * **/		
				EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_TIME, 
					{
						position: _pos, 
						duration: _duration, 
						bufferDuration:_kfTime + _bufferPercent * (_duration - _kfTime)
					}));
				if(!_isNearlyComplete && (_duration - _pos <= NumberConst.NEARLY_COMPLETE))
				{
					_isNearlyComplete = true;
					super.playbackNearlyComplete();
				}
			}
			else if (_duration > 0) 
			{
				complete();
			}
		}
		
		override public function play():void
		{
			if(!_posInterval)
			{
				_posInterval = setInterval(positionInterval, 100);
			}
			
			if(_isComplete)
			{
				_stream.play(_mediaVO.url);
			}
			else
			{
				_stream.resume();
			}			
		
			super.play(); //防止出现netstatusHandler不被触发时导致无法播放的问题
		}
		
		override public function pause():void
		{
			_stream.pause();
			super.pause(); //防止出现netstatusHandler不被触发时导致无法暂停的问题
		}
		
		override public function seek(sec:Number):void
		{
			if(Math.abs(_sec - sec) <= 0.01) //修复重复请求的bug
				return;
				
			_sec = sec;
			
			if(sec <= 0) //play from start
			{
				trace("play from start");
				_stream.close();
				_stream.play(_mediaVO.url);
				return;
			}			
			
			//已缓存到本地的视频长度
			//var cachedDuration:Number = (_bufferPercent >= 1 ? _duration : _stream.time + _bufferPercent * _duration);			
			_kfTime = getOffset(sec, true);
			if(sec >= _duration)
			{
				complete();
			}
			else
			{
				//匹配start
				var url:String = _mediaVO.url;
				var newurl:String;
				if(_mediaVO.url.indexOf("start=") == -1)
				{
					newurl = url + "?start=" + getOffset(sec);
				}
				else
				{
					var temp:String = _mediaVO.url.slice(0,url.lastIndexOf('=')+1);	
					newurl = (temp += getOffset(sec));
				}			
				
				if(!_ismp4)
				{				
					_stream.close();
					_stream.play(newurl);
				}
				else
				{
					_stream.play(_mediaVO.url + "?start=" + _kfTime);
				}		
				
				Logger.info("HttpMedia", "newurl:" + newurl);
			}		
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
		
		private function complete():void
		{
			stop();			
			super.playbackComplete();
		}
		
		private function stop():void
		{
			_stream.close();			
			destroyPosTimer();			
			_keyframes = null;
			_sec = 0;
		}
		
		/** 拖动timeslider icon移动 **/
		override public function dragTimeSliderMoving(sec:Number):void
		{
			seek(sec);	
		}
	}
}