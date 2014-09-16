package com.xinguoedu.evt
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * 全局的EventDispatcher 
	 * @author yatsen_yang
	 * 
	 */	
	public class EventBus extends EventDispatcher
	{
		private static var _instance:EventBus;
		
		public function EventBus(target:IEventDispatcher=null)
		{
			super(target);		
		}
		
		public static function getInstance():EventBus
		{
			if(_instance == null)
				_instance = new EventBus();
			
			return _instance;
		}
		
		
	}
}