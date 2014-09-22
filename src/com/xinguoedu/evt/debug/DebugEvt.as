package com.xinguoedu.evt.debug
{
	import flash.events.Event;
	
	/**
	 * 与调试有关的事件类 
	 * @author yatsen_yang
	 * 
	 */	
	public class DebugEvt extends Event
	{		
		public static const DEBUG:String = "debug";
		
		public var info:String;
		
		public function DebugEvt(type:String, info:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.info = info;
		}
		
		public override function clone():Event
		{
			return new DebugEvt(type, info, bubbles, cancelable);
		}
	}
}