package com.xinguoedu.m.media.httpe
{
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.media.BaseMedia;
	import com.xinguoedu.m.vo.MediaVO;
	
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/**
	 * 播放加密的视频 
	 * @author yatsen_yang
	 * 
	 */	
	public class HttpEMedia extends BaseMedia
	{		
		/** 存放二进制视频数据的字节数组 **/
		private var _totalByteArray:ByteArray;		
		/** 视频总共的字节数 **/
		private var _mediaBytesLen:Number = 0;		
		/** 视频是否全部加载到内存 **/
		private var _isLoadComplete:Boolean = false;
		/** 已缓冲的时间长度 **/
		private var _bufferDuration:Number = 0;		
		/** 视频全部加载完后拖动时的标识  **/
		private var _seekFlag:Boolean = false;			
		/** 视频加载的过程中是否拖动过视频 **/
		private var _isSeeked:Boolean = false;		
		/** 检查线程是否all ready的定时器标识**/
		private var _workerAllReadyInterval:uint;
		
		private var _isBufferEmpty:Boolean = false;
		
		/** 背景线程 **/
		private var _bgWorker:Worker;		
		/** 背景线程是否ready **/
		private var _isBgWorkerReady:Boolean = false;		
		private var _bgWorkerCmdChannel:MessageChannel; 
		private var _bgWorkerDataChannel:MessageChannel;
		private var _bgWorkerStateChannel:MessageChannel;		
		[Embed(source="SparrowPlayer_BGWorker.swf", mimeType="application/octet-stream")]
		private static var BackgroundWorker_ByteClass:Class;
		
		/** seek时启动的workder **/
		private var _seekingWorker:Worker;
		/** seekingworker是否ready **/
		private var _isSeekingWorkerReady:Boolean = false;
		private var _seekingWorkerReadyInterval:uint;
		private var _seekingWorkerCmdChannel:MessageChannel;
		private var _seekingWorkerStateChannel:MessageChannel;
		[Embed(source="SparrowPlayer_SeekingWorker.swf", mimeType="application/octet-stream")]
		private static var SeekingWorker_ByteClass:Class;
		
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
			
			_totalByteArray = new ByteArray();
		
			if(Worker.isSupported) //Create the background worker
			{			
				createBgWorker();
				createSeekingWorker();				
				
				_stream = new NetStream(_nc);
				_stream.bufferTime = 3;
				_stream.client = this;
				_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);			
				_stream.play(null);//处于数据生成模式
				_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);			
				setVolume(_volume);
				
				_video.attachNetStream(_stream);
				_display.addChild(_video);
				
				mediaVO.autostart && startLoadAndPlay();		
			}		
			else
			{				
				dispatchEvt(StreamStatus.FPVERSION_TOO_LOW);
			}		
		}
		
		/** 创建背景线程 **/
		private function createBgWorker():void
		{
			_totalByteArray.shareable = true;				
			_bgWorker = WorkerDomain.current.createWorker(new BackgroundWorker_ByteClass() as ByteArray);
			
			_bgWorkerCmdChannel = Worker.current.createMessageChannel(_bgWorker);
			_bgWorker.setSharedProperty("incomingCmdChannel", _bgWorkerCmdChannel);
			
			_bgWorkerDataChannel = Worker.current.createMessageChannel(_bgWorker);
			_bgWorker.setSharedProperty("data", _totalByteArray);
			
			_bgWorkerStateChannel = _bgWorker.createMessageChannel(Worker.current);
			_bgWorkerStateChannel.addEventListener(Event.CHANNEL_MESSAGE, bgWorkerStateChannelMsgHandler);
			_bgWorker.setSharedProperty('bgWokerStateChannel', _bgWorkerStateChannel);
			
			_bgWorker.addEventListener(Event.WORKER_STATE, bgWorkerStateHandler);
			_bgWorker.start();	
		}
		
		/** 创建拖动时需要的线程 **/
		private function createSeekingWorker():void
		{
			_seekingWorker = WorkerDomain.current.createWorker(new SeekingWorker_ByteClass() as ByteArray);
			
			_seekingWorkerCmdChannel = Worker.current.createMessageChannel(_seekingWorker);
			_seekingWorker.setSharedProperty("incomingCmdToSeekingWorker", _seekingWorkerCmdChannel);
			
			_seekingWorkerStateChannel = _seekingWorker.createMessageChannel(Worker.current);
			_seekingWorkerStateChannel.addEventListener(Event.CHANNEL_MESSAGE, seekingWorkerStateChannelMsgHandler);
			_seekingWorker.setSharedProperty("seekingWorkerStateChannel", _seekingWorkerStateChannel);
			
			_seekingWorker.addEventListener(Event.WORKER_STATE, seekingWorkerStateHandler);
			_seekingWorker.start();
		}		
		
		private function bgWorkerStateHandler(evt:Event):void {}
		private function seekingWorkerStateHandler(evt:Event):void{}
	
		override public function startLoadAndPlay():void
		{		
			if(_isBgWorkerReady && _isSeekingWorkerReady)
			{				
				_bgWorkerCmdChannel.send(["doLoad", _mediaVO.url, _mediaVO.omittedLength, _mediaVO.seed]);
			}
			else
			{
				//间隔检查
				_workerAllReadyInterval = setInterval(checkWorkerAllReady, 300);
			}
		}
		
		private function checkWorkerAllReady():void
		{
			if(_isBgWorkerReady && _isSeekingWorkerReady)
			{
				_bgWorkerCmdChannel.send(["doLoad", _mediaVO.url, _mediaVO.omittedLength, _mediaVO.seed]);
				clearInterval(_workerAllReadyInterval);
				_workerAllReadyInterval = undefined;
			}
		}
		
		/** 处理背景线程发过来的状态信息 **/
		private function bgWorkerStateChannelMsgHandler(evt:Event):void
		{
			var state:Array = _bgWorkerStateChannel.receive() as Array;
			//trace("bg worker state-->", state[0]);
			if(state)
			{
				switch(state[0])
				{
					case "bg_worker_ready":
						_isBgWorkerReady = true;
						break;
					case "start_load_media":
						dispatchEvt(StreamStatus.START_LOAD_MEDIA);
						dispatchMediaStateEvt(PlayerState.BUFFERING);
						break;
					case "load_media_progress":
						(_mediaBytesLen == 0) && (_mediaBytesLen = state[2]);
						if(!_isSeeked) //没有拖动过
						{
							(_duration == 0) ? (_bufferDuration = 0) : (_bufferDuration = state[1] * _duration);  
							!_posInterval && (_posInterval = setInterval(positionInterval, 100));
							_stream.appendBytes(state[3]);		
						}													
						break;
					case "load_media_complete":
						_isLoadComplete = true;
						_totalByteArray.shareable = false;
						_bufferDuration = _duration;
						destroyBGWorker();		
						break;
					case "error":
						dispatchEvt(StreamStatus.HANDLE_ENCRYPTED_MEDIA_ERROR);
						break;
					default:
						break;					
				}
			}
		}
		
		/** 处理Seeking线程发过来的状态信息 **/
		private function seekingWorkerStateChannelMsgHandler(evt:Event):void
		{
			var state:Array = _seekingWorkerStateChannel.receive() as Array;
			//trace("seeking worker state", state[0], _kfFilePos, state[1], state[2]);
			if(state)
			{
				switch(state[0])
				{
					case "seeking_worker_ready":
						_isSeekingWorkerReady = true;
						break;
					case "seeking_load_progress":
						if(_kfFilePos+state[2] == _mediaBytesLen+13) //需要判断数据是否有效
						{
							(_duration==0) ? (_bufferDuration=0): (_bufferDuration=_kfTime+state[1]*(_duration-_kfTime));
							!_posInterval && (_posInterval = setInterval(positionInterval, 100));
							_stream.appendBytes(state[3]);
						}		
						else
						{
							dispatchMediaStateEvt(PlayerState.BUFFERING);
						}
						break;
					case "seeking_load_complete":	
						break;
					case "seeking_error":
						dispatchEvt(StreamStatus.HANDLE_ENCRYPTED_MEDIA_ERROR);
						break;
				}
			}
		}
		
		/** 清理背景worker **/
		private function destroyBGWorker():void
		{			
			if(_bgWorker)
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
		}
		
		private function destroySeekingWorker():void
		{
			if(_seekingWorker)
			{
				_seekingWorkerStateChannel.close();
				_seekingWorkerStateChannel.removeEventListener(Event.CHANNEL_MESSAGE, seekingWorkerStateChannelMsgHandler);
				_seekingWorkerStateChannel = null;
				
				_seekingWorkerCmdChannel.close();
				_seekingWorkerCmdChannel = null;
				
				_seekingWorker.terminate();
				_seekingWorker.removeEventListener(Event.WORKER_STATE, seekingWorkerStateHandler);
				_seekingWorker = null;
			}		
		}
		
		override protected function netStatusHandler(evt:NetStatusEvent):void
		{
			trace("status----->", evt.info.code);
			switch(evt.info.code)
			{
				case StreamStatus.SEEK_NOTIFY:
					if(_isLoadComplete)
					{					
						destroySeekingWorker();
						_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);					
						_totalByteArray.position = _kfFilePos;					
						var bytes: ByteArray = new ByteArray();
						_totalByteArray.readBytes(bytes);
						_stream.appendBytes(bytes);
					}					
					break;
				case StreamStatus.BUFFER_FULL:
					if(_seekFlag)
					{
						_seekFlag = false;
						play();
					}	
					dispatchMediaStateEvt(PlayerState.PLAYING);
					break;
				case StreamStatus.BUFFER_EMPTY:
					_isBufferEmpty = true;
					if(!_isComplete)
					{
						dispatchMediaStateEvt(PlayerState.BUFFERING);
					}			
					else
					{
						dispatchMediaStateEvt(PlayerState.IDLE);
					}
					break;
				default:
					break;
			}
		}
		
		/** 时间定时器处理函数 **/
		private function positionInterval():void
		{
			if(_stream.time > 0)
			{				
				EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_TIME, 
					{
						position: _stream.time + _kfTime, 
						duration: _duration, 
						bufferDuration: _bufferDuration
					}));
				
				if((_stream.time + _kfTime >= _duration) || (_isBufferEmpty && (_duration-_stream.time-_kfTime<=0.2)))
				{	
					playComplete();
				}
				else
				{
					checkIsNearlyComplete(_duration, _stream.time + _kfTime);
				}
			}			
		}
		
		/** seek handler **/
		override public function seek(sec : Number) : void 
		{			
			_kfFilePos = getOffset(sec, false);
			_kfTime = getOffset(sec, true);
			_isSeeked = true;
			
			if(_isLoadComplete)
			{
				_seekFlag = true;
				destroyPosTimer();				
				checkIsNearlyComplete(_duration, sec, true);				
				_stream.seek(_kfTime);
			}
			else
			{	
				_seekingWorkerStateChannel.removeEventListener(Event.CHANNEL_MESSAGE, seekingWorkerStateChannelMsgHandler);
				
				_stream.seek(0); //清空缓冲区数据				
				_stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);				

				_seekingWorkerStateChannel.addEventListener(Event.CHANNEL_MESSAGE, seekingWorkerStateChannelMsgHandler);
				_seekingWorkerCmdChannel.send(["doSeek", _mediaVO.url, _kfFilePos, _mediaVO.omittedLength, _mediaVO.seed]);				
			}			
		}
		
		override public function play():void
		{
			!_posInterval && (_posInterval = setInterval(positionInterval, 100));			
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