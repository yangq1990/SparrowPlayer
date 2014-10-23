package com.xinguoedu.utils
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * 加载显示对象或者文本二进制数据的工具类 
	 * @author yatsen_yang
	 * 
	 */	
	public class MultifunctionalLoader
	{
		private var _completeFunc:Function;
		private var _errorFunc:Function;
		private var _loader:Loader;
		private var _urlLoader:URLLoader;
		private var _isDisplayObject:Boolean;
		
		/**
		 * 构造函数
		 * true 表明要加载的是可显示对象  false 表明要加载的是文本、二进制数据 
		 * @param isDisplayObject 默认为true
		 * 
		 */		
		public function MultifunctionalLoader(isDisplayObject:Boolean = true)
		{
			_isDisplayObject = isDisplayObject;
		}
		
		/**
		 * 注册回调函数 
		 * @param completeFunc 加载完成后的回调函数
		 * @param errorFunc 加载出错后的回调函数
		 * 
		 */		
		public function registerFunctions(completeFunc:Function, errorFunc:Function=null):void
		{
			_completeFunc = completeFunc;
			_errorFunc = errorFunc;
		}
		
		public function load(url:String):void
		{
			destroy();			
			if(_isDisplayObject)
			{					
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				_loader.load(new URLRequest(url), new LoaderContext(true));
			}
			else
			{
				_urlLoader = new URLLoader();
				_urlLoader.addEventListener(Event.COMPLETE, completeHandler);
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_urlLoader.load(new URLRequest(url));
			}
		}
		
		private function completeHandler(evt:Event):void
		{
			if(_completeFunc != null) 
			{
				_isDisplayObject ? _completeFunc.apply(this, [_loader.contentLoaderInfo.content]) : _completeFunc.apply(this, [evt.target.data]);
				destroy();
			}
		}
		
		private function errorHandler(evt:Event):void
		{
			destroy();
			if(_errorFunc != null)
			{
				_errorFunc.apply(this, evt.toString());
			}
		}
		
		private function destroy():void
		{
			if(_loader != null)
			{
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				_loader = null;
			}
			
			if(_urlLoader != null)
			{
				_urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
				_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_urlLoader = null;
			}
		}
	}
}