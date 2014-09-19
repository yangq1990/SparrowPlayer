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
		
		public var data:*;
		
		public function JSEvt(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		override public function clone():Event
		{
			return new JSEvt(type, data, bubbles, cancelable);
		}
	}
}