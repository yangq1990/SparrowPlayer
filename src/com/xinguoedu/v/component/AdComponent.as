package com.xinguoedu.v.component
{
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.evt.PlayerStateEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.MultifunctionalLoader;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * 广告组件 
	 * @author yatsen_yang
	 * 
	 */	
	public class AdComponent extends BaseComponent
	{
		private var _ad:Sprite;
		
		public function AdComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_ad = new Sprite();
			_ad.buttonMode = true;
			_ad.addEventListener(MouseEvent.CLICK, clickHandler);
			addChild(_ad);
			
			this.visible = false;
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
		}
		
		override protected function playerStateChangeHandler(evt:PlayerStateEvt):void
		{
			switch(_m.state) 
			{
				case PlayerState.BUFFERING:
				case PlayerState.PLAYING:
					this.visible = false;
					break;
				case PlayerState.IDLE:
					break;
				case PlayerState.PAUSED:
					
					if(!_ad.numChildren)
					{
						var loader:MultifunctionalLoader = new MultifunctionalLoader();
						loader.registerCompleteFunc(completeHandler);
						loader.load(_m.adVO.url);
					}
					else
					{
						this.visible = true;
						resize();
					}
					break;
			}
		}
		
		private function completeHandler(dp:DisplayObject):void
		{
			_ad.addChild(dp);			
			
			drawCloseBtn();
			this.addChild(_closeBtn);
			this.visible = true;
			
			resize();
		}
		
		override protected function resize():void
		{
			if(this.visible)
			{
				_ad.x = (stageWidth - _ad.width) >> 1;
				_ad.y = (stageHeight - _ad.height) >> 1;
				
				_closeBtn.x = _ad.x + _ad.width;
				_closeBtn.y = _ad.y;
			}
		}
		
		private function clickHandler(evt:MouseEvent):void
		{
			navigateToURL(new URLRequest(_m.adVO.link));
		}
	}
}