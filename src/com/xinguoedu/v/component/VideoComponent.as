package com.xinguoedu.v.component
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.consts.StretcherType;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.evt.settings.SettingsEvt;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.Stretcher;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.Graphics;
	import flash.display.Shape;
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
		/** 背景 **/
		private var _back:Shape;
		/** 媒体 **/
		private var _media:Sprite;
		/** 是否双击 **/
		private var _doubleClicked:Boolean = false;
		/** 存储视频原始宽高的关联数组, 数据结构{w:Number, h:Number} **/
		private var _widHeiDict:Object;
		/** 当前画面调整规则 **/
		private var _stretcherType:String = StretcherType.UNIFORM;
		/** 是否直播媒体 **/
		private var _isLive:Boolean;
		
		public function VideoComponent(m:Model)
		{
			super(m);			
		}
		
		override protected function buildUI():void
		{
			_back = new Shape();
			drawBack();
			this.addChild(_back);
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(MediaEvt.LOAD_MEDIA, mediaLoadedHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_METADATA, mediaMetaDataHandler);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);	
			EventBus.getInstance().addEventListener(SettingsEvt.UNIFORM, resizeFrameHandler);
			EventBus.getInstance().addEventListener(SettingsEvt.NONE, resizeFrameHandler);
			EventBus.getInstance().addEventListener(SettingsEvt.EXACTFIT, resizeFrameHandler);
			EventBus.getInstance().addEventListener(SettingsEvt.SIXTEEN_NINE, resizeFrameHandler);	
			EventBus.getInstance().addEventListener(MediaEvt.IS_LIVE_MEDIA, liveMediaHandler);
		}
		
		private function mediaLoadedHandler(evt:MediaEvt):void
		{
			show();
		}
		
		private function liveMediaHandler(evt:MediaEvt):void
		{
			_isLive = true;
			show();	
		}
		
		private function show():void
		{
			_media = _m.media.display;
			addChild(_media);
			
			this.mouseChildren = false;//_media包含着video, 需要禁掉_media的鼠标事件，否则无法触发双击
			this.doubleClickEnabled = true; 
		}
		
		/** 收到视频的metadata信息后调整视频 **/
		private function mediaMetaDataHandler(evt:MediaEvt):void
		{
			_widHeiDict = evt.data;
			stretchMedia(_stretcherType, true, _isLive);	
		}
		
		override protected function resize():void
		{
			drawBack();			
			stretchMedia(_stretcherType, false);	
		}	
		
		/**
		 * 调整画面尺寸 
		 * @param type 调整规则
		 * @param needTween 调整后是否需要缓动效果
		 * @param isLvie 是否直播，直播的时候controlbar隐藏，根据stageHeight调整视频的位置
		 */		
		private function stretchMedia(type:String, needTween:Boolean=true, isLive:Boolean=false):void
		{
			if(!_widHeiDict)
				return;

			//拉伸前的宽高
			var w:Number = _media.width;
			var h:Number = _media.height;
			
			if(isLive || _m.autohide || (!_m.autohide && _m.isFullScreen))
			{
				Stretcher.stretch(_media, stageWidth, stageHeight, _widHeiDict, type);	
			}
			else
			{
				Stretcher.stretch(_media, stageWidth, stageHeight - controlbarHeight, _widHeiDict, type);
			}
			
			needTween && TweenLite.from(_media, 0.4, {scaleX:w/_media.width, scaleY:h/_media.height, ease:Cubic.easeOut});
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
		
		private function resizeFrameHandler(evt:SettingsEvt):void
		{
			switch(evt.type)
			{
				case SettingsEvt.UNIFORM:
					_stretcherType = StretcherType.UNIFORM; 
					break;
				case SettingsEvt.NONE:
					_stretcherType = StretcherType.NONE; 
					break;
				case SettingsEvt.EXACTFIT:
					_stretcherType = StretcherType.EXACTFIT;
					break;
				case SettingsEvt.SIXTEEN_NINE:
					_stretcherType = StretcherType.SIXTEEN_NINE					
					break;
			}
			stretchMedia(_stretcherType);
		}
		
		/** 画背景图形 **/
		private function drawBack():void
		{
			var g:Graphics = _back.graphics;
			g.clear();
			g.beginFill(0x000000);
			g.drawRect(0, 0, stageWidth, stageHeight);
			g.endFill();
		}
	}
}