package com.xinguoedu.m
{
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.PlayerStateEvt;
	import com.xinguoedu.evt.media.MediaEvt;
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
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class Model extends EventDispatcher
	{		
		public var playerconfig:Object;
		
		public var media:BaseMedia;
		
		private var _mediaMap:Object = {};
		
		private var _mediaVO:MediaVO = new MediaVO();
		private var _logoVO:LogoVO = new LogoVO();
		private var _errorHintVO:ErrorHintVO = new ErrorHintVO();
		private var _adVO:AdVO = new AdVO();
		private var _videoadVO:VideoAdVO = new VideoAdVO();
		
		private var _skin:MovieClip;
		private var _state:String = PlayerState.IDLE;
		
		public function Model(target:IEventDispatcher=null)
		{
			super(target);
			
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
		}
		
		private function mediaInfoHandler(evt:MediaEvt):void
		{
			switch(evt.data)
			{
				case StreamStatus.START_LOAD_MEDIA:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADED));	
					break;
				case StreamStatus.lOAD_MEDIA_IOERROR:
				case StreamStatus.STREAM_NOT_FOUND:
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_ERROR, evt.data));
					break;
				case StreamStatus.PLAY_START:
					state = PlayerState.PLAYING;
					break;
				case StreamStatus.PAUSE_NOTIFY:
					state = PlayerState.PAUSED;
					break;
				case StreamStatus.UNPAUSE_NOTIFY:
					state = PlayerState.PLAYING;
					break;
				case StreamStatus.BUFFERING:
					state = PlayerState.BUFFERING;
					break;
				case StreamStatus.PLAY_COMPLETE:
					state = PlayerState.IDLE;
					EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_COMPLETE));	
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

	}
}