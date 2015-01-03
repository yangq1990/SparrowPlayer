package com.xinguoedu.m.media
{
	import com.xinguoedu.consts.ConnectionStatus;
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.vo.BaseVO;
	import com.xinguoedu.m.vo.MediaVO;
	
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.setInterval;

	/**
	 * 基于RTMP协议的点播 
	 * @author yangq1990
	 * 
	 */	
	public class RtmpVodMedia extends BaseMedia
	{
		/** 缓冲区被填满的程度 **/
		private var _bufferFill:Number;
		/** 缓冲区是否被填满 **/
		private var _bufferFull:Boolean;		
		/** 连接关闭时记录的播放位置  **/
		private var _timeWhenClosed:Number = 0;
		/** media server返回的media目录下视频文件的name **/
		private var _fileName:String;
		private var _prefix:String;
		
		
		public function RtmpVodMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function init(mediaVO:MediaVO):void
		{
			super.init(mediaVO);
			
			if(mediaVO.autostart)
			{
				connectToMediaServer();
			}					
		}
		
		override public function connectToMediaServer(vo:BaseVO=null):void
		{
			_nc = new NetConnection();
			_nc.addEventListener(NetStatusEvent.NET_STATUS, ncStatusHandler);
			_nc.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_nc.client = this;
			_nc.connect("rtmp://" + _mediaVO.url);
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADING));
		}
		
		/** 与media server的连接状态处理 **/
		protected function ncStatusHandler(evt:NetStatusEvent):void
		{
			switch(evt.info.code)
			{
				case ConnectionStatus.SUCCESS:				
					break;
				case ConnectionStatus.CLOSED:
					if(_stream != null)
					{
						_timeWhenClosed = _stream.time;
					}
					dispatchEvt(ConnectionStatus.CLOSED);
					break;
				case ConnectionStatus.REJECTED:
					dispatchEvt(ConnectionStatus.REJECTED);
					break;
				case ConnectionStatus.FAILED:
					dispatchEvt(ConnectionStatus.FAILED);
					break;
			}
		}
		
		private function createStream():void
		{
			_stream = new NetStream(_nc);
			_stream.client = this;
			_stream.bufferTime = 5;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			if(_mediaVO.len > 0)
			{
				_stream.play(_prefix + _fileName, 0, _mediaVO.len, true);
				EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_PREVIEW_HINT, "此视频为预览版，您只能观看" + _mediaVO.len + "秒"));
			}
			else
			{
				_stream.play(_prefix + _fileName);
			}
			
		
			super.getVideo();
			_video.attachNetStream(_stream);			
			_display.addChild(_video);
			setVolume(_volume);
			
			destroyPosTimer();
			_posInterval = setInterval(positionInterval, 100);				
			dispatchEvt(StreamStatus.START_LOAD_MEDIA);
		}
		
		override public function onMetaData(info:Object):void
		{
			super.onMetaData(info);
			
			if(_timeWhenClosed > 0)
			{
				_stream.seek(_timeWhenClosed);
			}
		}
		
		private function positionInterval():void
		{
			if(_duration <= 0)
				return;
			
			_pos = _stream.time;
			_bufferFill = _stream.bufferLength/_stream.bufferTime * 100;	
			
			if (_bufferFill <= 95 && (_duration - _pos <= 5))
			{
				_bufferFull = false;
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
						//采用rtmp协议的点播，本地没有缓存，所以bytesLoaded始终为0，bufferDuration这里默认是视频的总时长
						bufferDuration: (_mediaVO.len ? _mediaVO.len : _duration)
					}));
				
				checkIsNearlyComplete(_duration, _pos);
			}
			else if (_duration > 0) 
			{
				complete();
			}
		}
		
		override protected function netStatusHandler(evt:NetStatusEvent):void
		{
			switch(evt.info.code)
			{
				case StreamStatus.SEEKSTART_NOTIFY:
				case StreamStatus.SEEK_NOTIFY:
				case StreamStatus.PLAY_START:
				case StreamStatus.SEEK_COMPLETE:
					dispatchMediaStateEvt(PlayerState.BUFFERING);
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADING));
					break;				
				case StreamStatus.BUFFER_FULL:
					!_posInterval && (_posInterval = setInterval(positionInterval, 100));
					dispatchMediaStateEvt(PlayerState.PLAYING);
				default:
					break;
			}
			
			dispatchEvt(evt.info.code);
		}
		
		private function securityErrorHandler(evt:SecurityErrorEvent):void
		{
			dispatchEvt(ConnectionStatus.SECURITY_ERROR);
		}
		
		override public function play():void
		{
			if(!_nc.connected)
			{
				connectToMediaServer(); 
				return;
			}
			
			if(_isComplete)
			{
				_stream && _stream.seek(0);
			}
			else
			{
				_stream.resume();
			}
			super.play();
		}
		
		override public function pause():void
		{
			if(!_nc.connected)
				return;
			
			_stream.pause();
			super.pause();
		}
		
		override public function seek(sec:Number):void
		{
			if(_mediaVO.len > 0 && sec > _mediaVO.len)
			{
				EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_PREVIEW_HINT, "此视频为预览版，您只能观看" + _mediaVO.len + "秒，无法拖动到预览时间之后"));
				return;
			}				
			
			super.seek(sec);
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
		}
		
		public function callback(msg:String):void
		{
			_fileName = msg;
			
			if(_fileName.indexOf("mp4") != -1 || _fileName.indexOf("f4v") != -1)
			{
				_prefix = "mp4:"
			}				
			else
			{
				_prefix = "";
			}				
			
			createStream();
		}
	}
}