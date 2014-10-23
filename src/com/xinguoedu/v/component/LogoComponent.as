package com.xinguoedu.v.component
{
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.MultifunctionalLoader;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * Logo组件 
	 * @author yatsen_yang
	 * 
	 */	
	public class LogoComponent extends BaseComponent
	{
		private var _logo:Sprite;
		
		
		public function LogoComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void			
		{			
			var loader:MultifunctionalLoader = new MultifunctionalLoader();
			loader.registerFunctions(completeHandler);
			loader.load(_m.logoVO.url);
		}
		
		private function completeHandler(dp:DisplayObject):void
		{
			_logo = new Sprite();
			_logo.addChild(dp);
			addChild(_logo);
			
			if(_m.logoVO.buttonMode)
			{
				_logo.buttonMode = true;
				_logo.addEventListener(MouseEvent.CLICK, clickLogoHandler);
			}
			
			resize();
		}
		
		private function clickLogoHandler(evt:MouseEvent):void
		{
			navigateToURL(new URLRequest(_m.logoVO.link));
		}
		
		override protected function resize():void
		{
			if(_logo && _logo.visible)
			{
				this.x = stageWidth - _m.logoVO.margin - _logo.width;
				this.y = _m.logoVO.margin;
			}		
		}
		
	}
}