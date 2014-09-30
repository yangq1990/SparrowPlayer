package com.xinguoedu.m
{
	import cn.wecoding.utils.YatsenLog;
	
	import com.adobe.images.PNGEncoder;
	import com.hurlant.util.Base64;
	import com.xinguoedu.consts.DebugConst;
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.PlayerStateEvt;
	import com.xinguoedu.evt.debug.DebugEvt;
	import com.xinguoedu.evt.js.JSEvt;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.js.JSAPI;
	import com.xinguoedu.m.media.BaseMedia;
	import com.xinguoedu.m.media.HLSMedia;
	import com.xinguoedu.m.media.HttpEMedia;
	import com.xinguoedu.m.media.HttpMedia;
	import com.xinguoedu.m.vo.AdVO;
	import com.xinguoedu.m.vo.ErrorHintVO;
	import com.xinguoedu.m.vo.LogoVO;
	import com.xinguoedu.m.vo.MediaVO;
	import com.xinguoedu.m.vo.VideoAdVO;
	import com.xinguoedu.utils.Configger;
	import com.xinguoedu.utils.StageReference;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.utils.ByteArray;
	
	public class Model
	{		
		public var playerconfig:Object;		
		public var js:JSAPI = JSAPI.getInstance();
		
		public var media:BaseMedia;		
		private var _mediaMap:Object = {};		
		private var _mediaVO:MediaVO = new MediaVO();
		private var _logoVO:LogoVO = new LogoVO();
		private var _errorHintVO:ErrorHintVO = new ErrorHintVO();
		private var _adVO:AdVO = new AdVO();
		private var _videoadVO:VideoAdVO = new VideoAdVO();
		/** 播放器皮肤 **/
		private var _skin:MovieClip;
		private var _state:String = PlayerState.IDLE;
		private var _isMute:Boolean = false;
		
		public function Model()
		{
			setMedia();
		}		
		
		private function setMedia():void
		{
			_mediaMap[MediaType.HTTP] = new HttpMedia(MediaType.HTTP);			
			_mediaMap[MediaType.HLS] = new HLSMedia(MediaType.HLS);
			_mediaMap[MediaType.HTTPE] = new HttpEMedia(MediaType.HTTPE);			
		}
		
		private function addListeners():void
		{
			media.addEventListener(MediaEvt.MEDIA_INFO, mediaInfoHandler);
			media.addEventListener(MediaEvt.MEDIA_STATE, mediaStateHandler);
			js.addEventListener(JSEvt.SCREENSHOT, screenshotHandler);
			js.addEventListener(JSEvt.QRCODE, qrcodeHandler);
		}
		
		private function mediaInfoHandler(evt:MediaEvt):void
		{
			YatsenLog.info('Model', evt.data);
			switch(evt.data)
			{
				case StreamStatus.START_LOAD_MEDIA:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADED));	
					break;
				case StreamStatus.LOAD_MEDIA_IOERROR:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_ERROR, evt.data));
					EventBus.getInstance().dispatchEvent(new DebugEvt(DebugEvt.DEBUG, DebugConst.LOAD_MEDIA_IOERROR + ":" + mediaVO.url));
					break;
				case StreamStatus.STREAM_NOT_FOUND:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_ERROR, evt.data));
					EventBus.getInstance().dispatchEvent(new DebugEvt(DebugEvt.DEBUG, DebugConst.STREAM_NOT_FOUND + ":" + mediaVO.url));
					break;
				case StreamStatus.PLAY_START:
					state = PlayerState.PLAYING;
					break;
				case StreamStatus.PAUSE_NOTIFY: //不再处理这个状态
					//state = PlayerState.PAUSED;
					break;
				case StreamStatus.UNPAUSE_NOTIFY:
					state = PlayerState.PLAYING;
					break;
				case StreamStatus.BUFFERING:
					state = PlayerState.BUFFERING;
					break;
				case StreamStatus.BUFFER_FULL:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_BUFFER_FULL));	
					break;
				case StreamStatus.PLAY_COMPLETE:
					state = PlayerState.IDLE; 
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_COMPLETE));	
					break;
				case StreamStatus.PLAY_NEARLY_COMPLETE:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_NEARLY_COMPLETE));
					break;
				default:
					break;
			}
		}
		
		/** 流状态发生变化 **/
		private function mediaStateHandler(evt:MediaEvt):void
		{
			state = evt.data;
		}
		
		/** 截图处理 **/
		private function screenshotHandler(evt:JSEvt):void
		{
			media.pause();
			var bitmapData:BitmapData;
			var screenshotByteArray:ByteArray;
			try
			{
				bitmapData = new BitmapData(evt.data.width, evt.data.height ,true, 0);
				bitmapData.draw(media.display);
				
				screenshotByteArray = PNGEncoder.encode(bitmapData);
				var imgstr:String = "data:image/png;base64," + (Base64.encodeByteArray(screenshotByteArray));
				js.showScreenshot(imgstr);
			}
			catch(err:Error)
			{
				YatsenLog.error("Model", "截图出错",  err.toString());
				
				if(bitmapData != null)
				{
					bitmapData.dispose(); //释放内存
					bitmapData = null;
				}
				
				if(screenshotByteArray != null)
				{
					screenshotByteArray.clear(); //释放内存
					screenshotByteArray = null;
				}
				
				media.play();
			}
		}
		
		private function qrcodeHandler(evt:JSEvt):void
		{
			EventBus.getInstance().dispatchEvent(evt);
		}
										   
		
		/**
		 * 根据媒体类型 激活相应的媒体模块 
		 * @param mediaType 媒体类型
		 * 
		 */		
		public function setActiveMedia():void
		{
			if(!hasMedia(_mediaVO.type))
				_mediaVO.type = MediaType.HTTP;
			
			media = _mediaMap[_mediaVO.type];			
			addListeners();			
			media.init(_mediaVO);
		}
		
		private function hasMedia(mediaType:String):Boolean
		{
			return (_mediaMap[mediaType] is BaseMedia);
		}
			
		public function get mediaVO():MediaVO
		{
			return _mediaVO;
		}

		public function get logoVO():LogoVO
		{
			return _logoVO;
		}
		
		public function get errorHintVO():ErrorHintVO
		{
			return _errorHintVO;
		}	
		
		public function set skin(mc:MovieClip):void
		{
			_skin = mc;
		}

		public function get skin():MovieClip
		{
			return _skin;
		}

		public function get state():String
		{
			return _state;
		}
		
		public function get adVO():AdVO
		{
			return _adVO;
		}
		
		public function set volume(vol:int):void
		{
			if(playerconfig.volume != vol)
			{
				playerconfig.volume = vol;
				Configger.saveCookie("volume", vol);
			}
		}
		
		public function get volume():int
		{
			return playerconfig.volume;
		}

		public function set state(value:String):void
		{
			if(_state != value)
			{
				_state = value;
				EventBus.getInstance().dispatchEvent(new PlayerStateEvt(PlayerStateEvt.PLAYER_STATE_CHANGE));
			}			
		}		

		public function get videoadVO():VideoAdVO
		{
			return _videoadVO;
		}

		public function set videoadVO(value:VideoAdVO):void
		{
			_videoadVO = value;
		}
		
		/**
		 * 是否开启调试模式 
		 * @return 
		 * 
		 */		
		public function get debugmode():Boolean
		{
			return playerconfig.debugmode;
		}
		
		/**
		 * 版本号 
		 * @return 
		 * 
		 */		
		public function get version():String
		{
			return playerconfig.version;
		}
		
		
		/**
		 * 在normal screen的情况下，计时器时间到后是否自动隐藏controlbar 
		 * @return 
		 * 
		 */		
		public function get autohide():Boolean
		{
			if(int(playerconfig.autohide))
				return true;
			else
				return	false;
		}
		
		/**
		 * 是否全屏 
		 * @return 
		 * 
		 */		
		public function get isFullScreen():Boolean
		{
			return StageReference.stage.displayState == StageDisplayState.FULL_SCREEN;
		}
		
		/**
		 * 视频是否播放完 
		 * @return 
		 * 
		 */		
		public function get isMediaComplete():Boolean
		{
			return media.isComplete;
		}

		/**
		 * 视频是否处在静音状态 
		 * @return 
		 * 
		 */		
		public function get isMute():Boolean
		{
			return _isMute;
		}

		public function set isMute(value:Boolean):void
		{
			_isMute = value;
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_MUTE));
		}
	}
}