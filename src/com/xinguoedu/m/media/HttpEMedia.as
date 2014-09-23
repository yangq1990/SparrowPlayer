package com.xinguoedu.m.media
{
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.vo.MediaVO;
	import com.xinguoedu.utils.Decrypt;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.setInterval;

	/**
	 * 播放加密的视频 
	 * @author yatsen_yang
	 * 
	 */	
	public class HttpEMedia extends BaseMedia
	{
		/** URLStream提供了对字节层面的访问 **/
		private var _urlStream:URLStream;
		/** 存储关键帧时间戳和字节偏移量字典的数组 **/
		private var _tags:Array;		
		/** 存放二进制视频数据的字节数组 **/
		private var _totalByteArray:ByteArray;
		/** 标识是否seek过，在buffer full时有用 **/
		private var _seekFlag:Boolean = false;		
		
		public function HttpEMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function init(mediaVO:MediaVO):void
		{
			super.init(mediaVO);
			
			_nc = new NetConnection();
			_nc.connect(null);
			
			_video = new Video();
			_video.smoothing = true;
			
			_tags = [];
			_totalByteArray = new ByteArray();
			
			_stream = new NetStream(_nc);
			_stream.client = this;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);			
			_stream.play(null);//处于数据生成模式
			//表示时间刻度不连续，请刷新 FIFO，告知字节分析程序需要分析文件标头或 FLV 标签的开头
			_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);			
		
			_video.attachNetStream(_stream);
			_display.addChild(_video);
			
			_urlStream = new URLStream();
			_urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_urlStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_urlStream.addEventListener(ProgressEvent.PROGRESS,progressHandler);  
			_urlStream.addEventListener(Event.COMPLETE,completeHnd);  
			_urlStream.addEventListener(Event.CLOSE,closeHandler);
			_urlStream.addEventListener(Event.OPEN, openHandler);			
			
			mediaVO.autostart && startLoadAndPlay();		
		}
		
		override public function startLoadAndPlay():void
		{
			_urlStream.load(new URLRequest(_mediaVO.url));		
		}
		
		/** 开始加载 **/
		private function openHandler(evt:Event):void
		{
			dispatchEvt(StreamStatus.START_LOAD_MEDIA);
		}
		
		/** security error  **/
		private function securityErrorHandler(evt:SecurityErrorEvent):void
		{
			dispatchEvt(StreamStatus.LOAD_MEDIA_IOERROR);
		}		
		
		/** ioerror **/
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			dispatchEvt(StreamStatus.LOAD_MEDIA_IOERROR);
		}
		
		private function closeHandler(evt:Event):void
		{  
			_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_urlStream.removeEventListener(ProgressEvent.PROGRESS,progressHandler);  
			_urlStream.removeEventListener(Event.COMPLETE,completeHnd);  
			_urlStream.removeEventListener(Event.CLOSE,closeHandler);
			_urlStream.removeEventListener(Event.OPEN, openHandler);
			_urlStream.close();			
			_urlStream = null;
			
			playComplete();
		}  
		
		/** 加载加密视频中 **/
		private function progressHandler(evt:ProgressEvent):void
		{	
			/*if(evt.bytesLoaded / evt.bytesTotal >= 0.6)
			{
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, 
					{				
						'bufferPercent':	evt.bytesLoaded / evt.bytesTotal,
						'itemDuration': 	_totalDuration, //当前视频片断的长度
						'duration': 		_totalDuration,  //视频总共的长度
						'position': 		_stream.time, 
						'elapsedDuration':  0
					}
				);
			}		*/
			
			while(_urlStream.bytesAvailable)
			{
				_urlStream.readBytes(_totalByteArray, _totalByteArray.length, _urlStream.bytesAvailable);
			}
		}  
		
		/** 加载完成 **/
		private function completeHnd(e:Event):void
		{
			Decrypt.decrypt(_totalByteArray, _mediaVO.omittedLength, _mediaVO.seed);
			_stream.appendBytes(_totalByteArray);
			
			dispatchMediaStateEvt(PlayerState.PLAYING);
			destroyPosTimer();		
			_posInterval = setInterval(positionInterval, 100); //每0.1s调用一次
		}  
		
		override protected function netStatusHandler(evt:NetStatusEvent):void
		{
			switch(evt.info.code)
			{
				case StreamStatus.SEEK_NOTIFY:
					_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);					
					_totalByteArray.position = _kfFilePos;					
					var bytes: ByteArray = new ByteArray();
					_totalByteArray.readBytes(bytes);
					_stream.appendBytes(bytes);					
					break;
				case StreamStatus.BUFFER_FULL:
					if(_seekFlag)
					{
						_seekFlag = false;
						_posInterval = setInterval(positionInterval, 100);
					}
					break;
				case StreamStatus.BUFFER_EMPTY:
					playComplete();
					break;
			}
			
			dispatchEvt(evt.info.code);
		}
		
		/** 时间定时器处理函数 **/
		private function positionInterval():void
		{
			if(_stream.time >= 0)
			{				
				EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_TIME, {position: _stream.time + _kfTime, duration: _duration, bufferPercent:1}));
			}
			
			//自动连播提示
			/*if(_config.playNextEnabled && _totalDuration >= 30 && (_totalDuration - _stream.time - _kfTime <= 30))
			{
				if(!_autoPlayNextFlag)
				{
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_AUTOPLAYNEXT);
					_autoPlayNextFlag = true;
				}				
			}		*/
			
			//播放完一次后重播，结束时不会派发buffer.empty，所以要显示调用playComplete
			if(!_isNearlyComplete && (_duration - _stream.time - _kfTime <= NumberConst.NEARLY_COMPLETE))
			{
				_isNearlyComplete = true;
				super.playbackNearlyComplete();
			}
			else if(_stream.time + _kfTime >= _duration)
			{
				playComplete();
			}
		}
		
		/** seek handler **/
		override public function seek(sec : Number) : void 
		{			
			_seekFlag = true;
			destroyPosTimer();
			
			_kfFilePos = getOffset(sec, false);
			_kfTime = getOffset(sec, true)
			_stream.seek(_kfTime);
		}
		
		override public function play():void
		{
			if(!_posInterval)
			{
				_posInterval = setInterval(positionInterval, 100);
			}
			_stream.resume();
			super.play();
		}
		
		override public function pause():void
		{
			_stream.pause();
			super.pause();
		}
		
		/** 播放完成 **/
		private function playComplete():void
		{
			_stream.close();
			destroyPosTimer();
			_kfFilePos = _kfTime = 0;
			_keyframes = null;
		}
	}
}