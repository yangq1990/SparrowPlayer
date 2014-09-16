package com.xinguoedu.utils
{
	import cn.wecoding.utils.YatsenLog;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * 加载显示对象或者文本二进制数据的工具类 
	 * @author yatsen_yang
	 * 
	 */	
	public class MultifunctionalLoader
	{
		private var _func:Function;
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
		
		public function registerCompleteFunc(func:Function):void
		{
			_func = func;	
		}
		
		public function load(url:String):void
		{
			destroy();			
			if(_isDisplayObject)
			{					
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_loader.load(new URLRequest(url));
			}
			else
			{
				_urlLoader = new URLLoader();
				_urlLoader.addEventListener(Event.COMPLETE, completeHandler);
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_urlLoader.load(new URLRequest(url));
			}
		}
		
		private function completeHandler(evt:Event):void
		{
			if(_func != null) 
			{
				_isDisplayObject ? _func.apply(this, [_loader.contentLoaderInfo.content]) : _func.apply(this, [evt.target.data]);
				destroy();
			}
		}
		
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			destroy();
			YatsenLog.error('MultifunctionalLoader', 'io错误', evt.toString());
		}
		
		private function destroy():void
		{
			if(_loader != null)
			{
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_loader = null;
			}
			
			if(_urlLoader != null)
			{
				_urlLoader.removeEventListener(Event.COMPLETE, completeHandler);
				_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_urlLoader = null;
			}
		}
	}
}