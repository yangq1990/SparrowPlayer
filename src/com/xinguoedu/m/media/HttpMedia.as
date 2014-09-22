package com.xinguoedu.m.media
{
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.vo.MediaVO;
	
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
			_stream.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
			_stream.client = this;
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
		}
		
		override protected function netStatusHandler(evt:NetStatusEvent):void
		{
			if(evt.info.code == StreamStatus.SEEK_COMPLETE)
				play();
			
			dispatchEvt(evt.info.code);
		}
		
		protected function onIOErrorHandler(evt:IOErrorEvent):void
		{
			dispatchEvt(StreamStatus.LOAD_MEDIA_IOERROR);
		}
		
		private function positionInterval():void
		{
			_pos = Math.round(_stream.time * 100) / 100;
			
			if (_duration > 0 && _stream) 
			{
				_bufferTime = _stream.bufferTime < (_duration - _pos) ? _stream.bufferTime : Math.ceil(_duration - _pos);
				_bufferFill = _stream.bufferTime ? Math.ceil(Math.ceil(_stream.bufferLength) / _bufferTime * 100) : 0;
			} 
			else 
			{
				_bufferFill = _stream.bufferTime ? _stream.bufferLength/_stream.bufferTime * 100 : 0;
			}
			
			_bufferPercent = _stream.bytesTotal ? (_stream.bytesLoaded / _stream.bytesTotal) : 0;
			
			if (_bufferFill <= 50 && (_duration - _pos) > 5) 
			{
				_bufferFull = false;
				_stream.pause();
				dispatchEvt(StreamStatus.BUFFERING);
			} 
			else if (_bufferFill > 95 && !_bufferFull) 
			{
				_bufferFull = true;
				//sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
			}
			
			if (_pos < _duration) 
			{
				/** 
				 * 数据结构,为提高效率，事件直接派发，由controlbarComp接收处理
				 * position 播放头的位置,以秒为单位
				 * duration 视频时长
				 * bufferPercent 视频缓存到本地的比例
				 * 
				 * **/			
				EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_TIME, {position: _pos, duration: _duration, bufferPercent:_bufferPercent}));
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
			_stream.resume();
			super.play(); //防止出现netstatusHandler不被触发时导致无法播放的问题
		}
		
		override public function pause():void
		{
			_stream.pause();
			super.pause(); //防止出现netstatusHandler不被触发时导致无法暂停的问题
		}
		
		override public function seek(sec:Number):void
		{
			destroyPosTimer();
			
			if(sec <= 0) //play from start
			{
				trace("play from start");
				_stream.close();
				_stream.play(_mediaVO.url);
				return;
			}			
			
			//_stream.pause();
			
			//已缓存到本地的视频长度
			var cachedDuration:Number = (_bufferPercent >= 1 ? _duration : _stream.time + _bufferPercent * _duration);
			_kfTime = getOffset(sec, true); //离拖动点最近的关键帧的时间点
			if((sec < cachedDuration))
			{		
				_stream.seek(_kfTime);//offset:Number — 要在视频文件中移动到的时间近似值（以秒为单位）。 
			}
			else
			{
				if(sec >= _duration)
				{
					complete();
				}
				else
				{
					_stream.play(_mediaVO.url + "?start=" + getOffset(sec)); //从指定位置开始加载, 需要nginx支持start参数
				}				
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
			dispatchEvt(StreamStatus.PLAY_COMPLETE);
		}
		
		private function stop():void
		{
			_stream.close();
			
			destroyPosTimer();
			
			_keyframes = null;
		}
	}
}