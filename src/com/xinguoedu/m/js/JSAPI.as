package com.xinguoedu.m.js
{
	import com.xinguoedu.evt.js.JSEvt;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	/**
	 * JS处理模块，包括注册函数供外部JS调用和调用外部JS函数，单例模式
	 * @author yatsen_yang
	 * 
	 */	
	public class JSAPI extends EventDispatcher
	{
		private static var _instance:JSAPI;
		
		public static function getInstance():JSAPI
		{
			if(_instance == null)
				_instance = new JSAPI();
			return _instance;
		}
		
		public function JSAPI()
		{
			if(available)
			{
				ExternalInterface.addCallback("fl_screenshot", screenshotHandler);
				ExternalInterface.addCallback("fl_qrcode", qrcodeHandler);
			}			
		}
	
		/**
		 * 截图
		 * @param w 截图宽度
		 * @param h 截图高度
		 * 
		 */		
		private function screenshotHandler(w:Number, h:Number):void
		{		
			dispatchEvent(new JSEvt(JSEvt.SCREENSHOT, {'width':w, 'height':h}));
		}
		
		
		private function qrcodeHandler():void
		{
			dispatchEvent(new JSEvt(JSEvt.QRCODE));
		}
		
		/**
		 * 播放下一集 
		 * 
		 */		
		public function playnext():void
		{
			available && ExternalInterface.call('alert', '播放下一集');	
		}
		
		/**
		 * 图片的字符串数据 
		 * @param str
		 * 
		 */		
		public function showScreenshot(str:String):void
		{
			available && ExternalInterface.call('showScreenshot', str);
		}
		
		/** 外部接口是否可用 **/
		private function get available():Boolean
		{
			return ExternalInterface.available;
		}
	}
}