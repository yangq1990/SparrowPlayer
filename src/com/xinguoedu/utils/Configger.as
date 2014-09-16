package com.xinguoedu.utils
{
	import cn.wecoding.utils.YatsenLog;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	/**
	 * 加载配置信息 
	 * @author yatsen_yang
	 * 
	 */	
	public class Configger extends EventDispatcher
	{
		private var _config:Object = {};		
		private var _videoVO:Object;
		
		public function Configger(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function loadConfig():void
		{
			//先加载配置文件
			var loader:MultifunctionalLoader = new MultifunctionalLoader(false);
			loader.registerCompleteFunc(loadXMLCompleteHandler);
			loader.load("../assets/Config.xml");
		}
		
		private function loadXMLCompleteHandler(data:*):void
		{
			var xml:XML = new XML(data);
			config['version'] = xml.version;			
			var array:Array = [];		
			var length:int = xml.rightclickinfo.item.length();
			for(var i:int = 0; i < length; i++)
			{
				array.push({'title':xml.rightclickinfo.item[i].title, 'url':xml.rightclickinfo.item[i].url});
			}			
			_config['rightclickinfo'] = array;
			
			//logo
			var logo:Object = {};
			logo.url = xml.logo.url;
			logo.buttonMode = int(xml.logo.buttonMode);
			logo.margin = int(xml.logo.margin);
			logo.link = xml.logo.link;
			_config['logo'] = logo;
			
			var errorHint:Object = {};
			errorHint.url = xml.errorHint.url;
			_config['errorHint'] = errorHint;	
			
			_config['learnmore'] = xml.learnmore.url;	
			
			_config['volume'] = int(xml.volume);
			
			loadFlashvars();			
			loadCookies();
		}
		
		/**
		 * 存入数据到本地sharedobject
		 * @param param
		 * @param value
		 * 
		 */		
		public static function saveCookie(param:String, value:*):void 
		{
			try 
			{
				var cookie:SharedObject = SharedObject.getLocal('com.xinguoedu','/');
				cookie.data[param] = value;
				cookie.flush();
			} 
			catch (err:Error) 
			{
				YatsenLog.error('Configger','写入数据到本地sharedobject出错', err.toString());
			}
		}
		
		/** 加载flashvars **/
		private function loadFlashvars():void 
		{
			var params:Object = StageReference.stage.loaderInfo.parameters;
			for (var param:String in params)
			{
				setConfigParam(param, params[param]);
			}
		}
		
		/** 加载本地sharedobject数据 **/
		private function loadCookies():void
		{
			try 
			{
				var cookie:SharedObject = SharedObject.getLocal('com.xinguoedu','/');
				getCookieData(cookie.data);
			} 
			catch (err:Error) 
			{
				YatsenLog.error('Configger','从本地sharedobject读取数据出错',err.toString());
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/** Overwrite cookie data. **/ 
		private function getCookieData(obj:Object):void
		{
			for (var cfv:String in obj) 
			{
				setConfigParam(cfv.toLowerCase(), obj[cfv]); 
			}
		}
		
		private function setConfigParam(name:String, value:String):void 
		{
			if (name != "fullscreen") 
			{
				_config[name.toLowerCase()] = Strings.serialize(Strings.trim(value));
			}
		}
		
		public function get config():Object
		{
			return _config;
		}
	}
}