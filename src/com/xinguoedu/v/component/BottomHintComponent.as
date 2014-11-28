package com.xinguoedu.v.component
{
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.consts.PlayerColor;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	/**
	 * 底部提示信息组件，比如视频快结束时的提示语，和上次的播放记录提示 
	 * @author yatsen_yang
	 * 
	 */	
	public class BottomHintComponent extends BaseComponent
	{
		/** 背景图形 **/
		private var _back:Shape;
		/** 提示信息 **/
		private var _hint:TextField;		
		
		public function BottomHintComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_back = new Shape();
			this.addChild(_back);
			
			_hint = new TextField();
			_hint.defaultTextFormat = new TextFormat(Font.YAHEI, Font.SIZE, Font.COLOR);
			this.addChild(_hint);
			
			super.buildUI();
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_NEARLY_COMPLETE, nearlyCompleteHandler);
			EventBus.getInstance().addEventListener(MediaEvt.NOT_NEARLY_COMPLETE, notNearlyCompleteHandler);
			EventBus.getInstance().addEventListener(ViewEvt.HIDE_CONTROLBAR, hideControlbarHandler);
			EventBus.getInstance().addEventListener(ViewEvt.SHOW_CONTROLBAR, showControlbarHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_PREVIEW_HINT, mediaPreviewHintHandler);
		}
		
		private function nearlyCompleteHandler(evt:MediaEvt):void
		{
			_hint.text = "当前视频即将播放完";
			showSelf();
		}
		
		private function notNearlyCompleteHandler(evt:MediaEvt):void
		{
			this.visible && hide();
		}
		
		override protected function mediaCompleteHandler(evt:MediaEvt):void
		{
			this.visible && hide();
		}
		
		private function mediaPreviewHintHandler(evt:MediaEvt):void
		{
			_hint.text = evt.data;			
			showSelf();
		}
		
		private function showSelf():void
		{
			if(_closeBtn == null)
			{
				drawCloseBtn(false);
				this.addChild(_closeBtn);
			}
			
			this.visible = true;
			resize();
			
			super.destroyTimer();
			_timeout = setTimeout(timeoutHandler, NumberConst.BOTTOMHINT_DELAY);
		}
		
		override protected function resize():void
		{
			if(this.visible)
			{
				_hint.width = _hint.textWidth + 10;
				_hint.height = _hint.textHeight + 10;
				_hint.x = (stageWidth - _hint.width) * 0.5;
				_hint.y = 3;
				
				var g:Graphics = _back.graphics;
				g.clear();
				g.beginFill(PlayerColor.MAIN_BG, 0.8); //跟controlbar的背景色保持一致
				g.drawRect(0, 0, stageWidth, _hint.height);
				g.endFill();	
				
				_closeBtn.x = stageWidth -_closeBtn.width;
				_closeBtn.y = _hint.height * 0.5;
				
				this.y = stageHeight - controlbarHeight - _hint.height;
			}
		}
		
		private function timeoutHandler():void
		{
			super.hide();
		}
		
		private function hideControlbarHandler(evt:ViewEvt):void
		{
			if(this.visible)
			{
				this.y = stageHeight - _hint.height;				
			}
		}
		
		private function showControlbarHandler(evt:ViewEvt):void
		{
			if(this.visible)
			{
				this.y = stageHeight - controlbarHeight - _hint.height;
			}
		}
	}
}