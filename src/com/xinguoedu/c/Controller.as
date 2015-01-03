package com.xinguoedu.c
{
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.StageReference;
	import com.xinguoedu.v.View;
	
	import flash.display.StageDisplayState;
	import flash.events.Event;

	public class Controller
	{
		private var _playersetup:PlayerSetup;
		private var _v:View;
		private var _m:Model;
		
		public function Controller(v:View, m:Model)
		{
			this._v = v;
			this._m = m;
			
			addListeners();
		}
		
		private function addListeners():void
		{
			_v.addEventListener(ViewEvt.PLAY, playHandler);
			_v.addEventListener(ViewEvt.PAUSE, pauseHandler);
			_v.addEventListener(ViewEvt.MOUSEDOWN_TO_SEEK, mouseDownToSeekHandler);
			_v.addEventListener(ViewEvt.SEEK, seekHandler);
			_v.addEventListener(ViewEvt.FULLSCREEN, fullScreenHandler);
			_v.addEventListener(ViewEvt.NORMAL, normalHandler);
			_v.addEventListener(ViewEvt.VOLUME, volumeHandler);
			_v.addEventListener(ViewEvt.VIDEOADS_COMPLETE, videoadsCompleteHandler);
			_v.addEventListener(ViewEvt.KEYDOWN_SPACE, keyDownSpaceHandler);
			_v.addEventListener(ViewEvt.PLAY_NEXT, playnextHandler);
			_v.addEventListener(ViewEvt.DRAG_TIMESLIDER_MOVING, dragTimeSliderMovingHandler);
			_v.addEventListener(ViewEvt.MUTE, muteHandler);
			_v.addEventListener(ViewEvt.ENTER_ROOM, enterRoomHandler);
		}
		
		private function playHandler(evt:ViewEvt):void
		{
			if(!_m.mediaVO.autostart && _m.state == PlayerState.IDLE)
			{
				_m.media.startLoadAndPlay();
			}				
			else
			{
				_m.media.play();
			}
		}
		
		private function pauseHandler(evt:ViewEvt):void
		{
			_m.media.pause();
		}
		
		private function mouseDownToSeekHandler(evt:ViewEvt):void
		{
			_m.media.mouseDownToSeek();
			_m.state = PlayerState.PLAYING; //拖动时播放器状态设置为播放
		}
		
		private function seekHandler(evt:ViewEvt):void
		{
			_m.media.seek(evt.data);
		}
		
		private function fullScreenHandler(evt:ViewEvt):void
		{
			StageReference.stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		private function normalHandler(evt:ViewEvt):void
		{
			StageReference.stage.displayState = StageDisplayState.NORMAL;
		}
		
		/**
		 * 此时evt.data是一个object,包含
		 * save2cookie true立即写入sharedobject
		 * pct         音量值
		 * @param evt
		 * 
		 */		
		private function volumeHandler(evt:ViewEvt):void
		{
			evt.data.save2cookie && (_m.volume = evt.data.pct);
			_m.media.setVolume(evt.data.pct);
		}
		
		public function setupPlayer():void
		{
			_playersetup = new PlayerSetup(_m, _v);
			_playersetup.addEventListener(Event.COMPLETE, setupPlayerComplete);
			_playersetup.setup();
		}
		
		private function setupPlayerComplete(evt:Event):void
		{
			if(!_m.videoadVO.enabled)
				_m.setActiveMedia();
			else
				_v.playVideoAds();
		}
		
		private function videoadsCompleteHandler(evt:ViewEvt):void
		{
			_m.setActiveMedia();
		}
		
		/** 处理按下空格键 **/
		private function keyDownSpaceHandler(evt:ViewEvt):void
		{
			if(_m.state == PlayerState.IDLE || _m.state == PlayerState.PAUSED)
			{
				_m.media.play();
			}
			else if(_m.state == PlayerState.PLAYING || _m.state == PlayerState.BUFFERING)
			{
				_m.media.pause();
			}
		}
		
		/** 播放下一集 **/
		private function playnextHandler(evt:ViewEvt):void			
		{
			_m.js.playnext();
		}		
		
		/** 拖着timeslider icon移动  **/
		private function dragTimeSliderMovingHandler(evt:ViewEvt):void
		{
			_m.media.dragTimeSliderMoving(evt.data);
		}
		
		/** 静音或者取消静音 **/
		private function muteHandler(evt:ViewEvt):void
		{
			_m.media.mute(evt.data, _m.volume);
			_m.isMute = evt.data;
		}
		
		/** 用户尝试登录直播房间 **/
		private function enterRoomHandler(evt:ViewEvt):void
		{
			_m.userVO.name = evt.data;
			_m.media.connectToMediaServer(_m.userVO);
		}
	}
}