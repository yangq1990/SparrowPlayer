package com.xinguoedu.evt.js
{
	import flash.events.Event;
	
	/**
	 * 与JS有关的事件类 
	 * @author yatsen_yang
	 * 
	 */	
	public class JSEvt extends Event
	{
		/**
		 * 截图 
		 */		
		public static const SCREENSHOT:String = "screenshot";
		
		public function JSEvt(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}