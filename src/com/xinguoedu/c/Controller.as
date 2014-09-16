package com.xinguoedu.c
{
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.StageReference;
	import com.xinguoedu.v.View;
	
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class Controller extends EventDispatcher
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
			_v.addEventListener(ViewEvt.TIME, seekHandler);
			_v.addEventListener(ViewEvt.FULLSCREEN, fullScreenHandler);
			_v.addEventListener(ViewEvt.NORMAL, normalHandler);
			_v.addEventListener(ViewEvt.VOLUME, volumeHandler);
			_v.addEventListener(ViewEvt.VIDEOADS_COMPLETE, videoadsCompleteHandler);
		}
		
		private function playHandler(evt:ViewEvt):void
		{
			_m.media.play();
		}
		
		private function pauseHandler(evt:ViewEvt):void
		{
			_m.media.pause();
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
		
		
		
	}
}