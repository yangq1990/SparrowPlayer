package com.xinguoedu.m.media.httpe
{
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.media.BaseMedia;
	import com.xinguoedu.m.vo.MediaVO;
	import com.xinguoedu.utils.DecryptUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
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
		
		private var _isChildWorkerReady:Boolean = false;
		
		private var _bgWorker:Worker;
		private var _bgWorkerCmdChannel:MessageChannel; 
		private var _bgWorkerDataChannel:MessageChannel;
		private var _bgWorkerStateChannel:MessageChannel;
		
		[Embed(source="SparrowPlayer_BGWorker.swf", mimeType="application/octet-stream")]
		private static var BackgroundWorker_ByteClass:Class;
		
		
		public function HttpEMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function init(mediaVO:MediaVO):void
		{
			super.init(mediaVO);
			
			_nc = new NetConnection();
			_nc.connect(null);
			
			super.getVideo();
			
			_tags = [];
			_totalByteArray = new ByteArray();
			
			if(Worker.isSupported) //Create the background worker
			{			
				_totalByteArray.shareable = true;				
				_bgWorker = WorkerDomain.current.createWorker(new BackgroundWorker_ByteClass() as ByteArray);
				
				// Set up the MessageChannels for communication between workers
				_bgWorkerCmdChannel = Worker.current.createMessageChannel(_bgWorker);
				_bgWorker.setSharedProperty("incomingCmdChannel", _bgWorkerCmdChannel);
				
				_bgWorkerDataChannel = Worker.current.createMessageChannel(_bgWorker);
				_bgWorker.setSharedProperty("data", _totalByteArray);
				
				_bgWorkerStateChannel = _bgWorker.createMessageChannel(Worker.current);
				_bgWorkerStateChannel.addEventListener(Event.CHANNEL_MESSAGE, bgWorkerStateChannelMsgHandler);
				_bgWorker.setSharedProperty('bgWokerStateChannel', _bgWorkerStateChannel);
				
				// Start the worker
				_bgWorker.addEventListener(Event.WORKER_STATE, bgWorkerStateHandler);
				_bgWorker.start();
			}		
			
			_stream = new NetStream(_nc);
			_stream.client = this;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);			
			_stream.play(null);//处于数据生成模式
			//表示时间刻度不连续，请刷新 FIFO，告知字节分析程序需要分析文件标头或 FLV 标签的开头
			_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);			
			setVolume(_volume);
		
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
		
		private function closeHandler(evt:Event):void
		{  
			destroyUrlStream();
			playComplete();
		}  
		
		/** 加载加密视频中 **/
		private function progressHandler(evt:ProgressEvent):void
		{	
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADING, {percent:evt.bytesLoaded/evt.bytesTotal}));
			
			while(_urlStream.bytesAvailable)
			{
				_urlStream.readBytes(_totalByteArray, _totalByteArray.length, _urlStream.bytesAvailable);
			}
		}  

		/** 加载完成 **/
		private function completeHnd(e:Event):void
		{			
			destroyUrlStream();
			
			if(Worker.isSupported && _isChildWorkerReady)
			{	
				_bgWorkerCmdChannel.send(['start', _mediaVO.omittedLength, _mediaVO.seed]);
			}
			else
			{
				DecryptUtil.decrypt(_totalByteArray, _mediaVO.omittedLength, _mediaVO.seed);
				appendBytesAndPlay();
			}			
		}  
		
		private function bgWorkerStateHandler(evt:Event):void
		{
			
		}
		
		private function bgWorkerStateChannelMsgHandler(evt:Event):void
		{
			var state:* = _bgWorkerStateChannel.receive();
			if(state == 'child_worker_ready') //子worker ready，可以通信了
			{
				_isChildWorkerReady = true;
			}
			else if(state == 'decryption_success') //子worker 处理视频success，可以播放了
			{
				_totalByteArray.shareable = false;
				appendBytesAndPlay();
			}
		}
		
		private function appendBytesAndPlay():void
		{
			_stream.appendBytes(_totalByteArray);
			dispatchMediaStateEvt(PlayerState.PLAYING);
			destroyPosTimer();		
			_posInterval = setInterval(positionInterval, 100);
		}
		
		/** 清理urlstream **/
		private function destroyUrlStream():void
		{
			if(_urlStream)
			{
				_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_urlStream.removeEventListener(ProgressEvent.PROGRESS,progressHandler);  
				_urlStream.removeEventListener(Event.COMPLETE,completeHnd);  
				_urlStream.removeEventListener(Event.CLOSE,closeHandler);
				_urlStream.removeEventListener(Event.OPEN, openHandler);
				_urlStream.close();			
				_urlStream = null;
			}			
		}
		
		/** 清理子worker **/
		private function destroyBGWorker():void
		{			
			_bgWorkerStateChannel.close();
			_bgWorkerStateChannel.removeEventListener(Event.CHANNEL_MESSAGE, bgWorkerStateChannelMsgHandler);
			_bgWorkerStateChannel = null;
			
			_bgWorkerDataChannel.close();
			_bgWorkerDataChannel = null;
			
			_bgWorkerCmdChannel.close();
			_bgWorkerCmdChannel = null;
			
			_bgWorker.terminate();
			_bgWorker.removeEventListener(Event.WORKER_STATE, bgWorkerStateHandler);
			_bgWorker = null;
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
						play();
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
				EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_TIME, 
					{
						position: _stream.time + _kfTime, 
						duration: _duration, 
						bufferDuration:_duration
					}));
			}
			
			if(_stream.time + _kfTime >= _duration)
			{
				playComplete();
			}
			else
			{
				checkIsNearlyComplete(_duration, _stream.time + _kfTime);
			}
		}
		
		/** seek handler **/
		override public function seek(sec : Number) : void 
		{			
			_seekFlag = true;
			destroyPosTimer();
			
			checkIsNearlyComplete(_duration, sec, true);
			
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
			
			//重播时相当于seek到头开始播放
			_isComplete ? seek(0) : _stream.resume();			
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
			destroyPosTimer();
			_kfFilePos = _kfTime = 0;
			super.playbackComplete();
		}
	}
}