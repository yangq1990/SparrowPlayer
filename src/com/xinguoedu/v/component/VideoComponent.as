package com.xinguoedu.v.component
{
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.Stretcher;
	import com.xinguoedu.v.base.BaseComponent;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * 视频组件，负责视频的显示 
	 * @author yatsen_yang
	 * 
	 */	
	public class VideoComponent extends BaseComponent
	{
		private var _media:Sprite;
		private var _tweenLite:TweenLite;
		/** 是否双击 **/
		private var _doubleClicked:Boolean = false;
		
		public function VideoComponent(m:Model)
		{
			super(m);			
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_LOADED, onMediaLoadedHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_METADATA, onMediaMetaDataHandler);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);	
		}
		
		private function onMediaLoadedHandler(evt:MediaEvt):void
		{
			_media = _m.media.display;
			addChild(_media);
			
			this.mouseChildren = false;//_media包含着video, 需要禁掉_media的鼠标事件，否则无法触发双击
			this.doubleClickEnabled = true; 
		}
		
		/** 收到视频的metadata信息后调整视频 **/
		private function onMediaMetaDataHandler(evt:MediaEvt):void
		{
			Stretcher.stretch(_media, stageWidth, stageHeight);
		}
		
		override protected function resize():void
		{
			Stretcher.stretch(_media, stageWidth, stageHeight);
			
			if(_tweenLite != null)
			{
				TweenLite.killTweensOf(_media, true);
				_tweenLite = null;
			}
			
			if(displayState == StageDisplayState.NORMAL)
			{
				_tweenLite = TweenLite.from(_media, 0.3, {z:-200, alpha:0.3});
			}
			else if(displayState == StageDisplayState.FULL_SCREEN)
			{
				_tweenLite = TweenLite.from(_media, 0.3, {z:250, alpha:0.3});
			}
		}	
		
		private function clickHandler(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation();
			
			_doubleClicked = false;
			var timer:Timer = new Timer(260,1);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();				
		}
		
		private function onTimer(evt:TimerEvent):void
		{
			(evt.target as Timer).removeEventListener(TimerEvent.TIMER, onTimer);
			
			if(!_doubleClicked)
			{
				if(_m.state == PlayerState.PLAYING || _m.state == PlayerState.BUFFERING)
					dispatchEvent(new ViewEvt(ViewEvt.PAUSE));
				else if(_m.state == PlayerState.PAUSED)
					dispatchEvent(new ViewEvt(ViewEvt.PLAY));
			}
		}
		
		//鼠标双击，进入全屏或者退出全屏
		private function doubleClickHandler(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation();			
			
			_doubleClicked = true;		
			if(displayState == StageDisplayState.FULL_SCREEN)
				dispatchEvent(new ViewEvt(ViewEvt.NORMAL));
			else if(displayState == StageDisplayState.NORMAL)
				dispatchEvent(new ViewEvt(ViewEvt.FULLSCREEN));			
		}
	}
}