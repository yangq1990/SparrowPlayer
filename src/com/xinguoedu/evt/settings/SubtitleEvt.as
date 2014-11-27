package com.xinguoedu.evt.settings
{
	import flash.events.Event;
	
	/**
	 * 与字幕相关的事件类 
	 * @author yangq1990
	 * 
	 */	
	public class SubtitleEvt extends Event
	{
		public function SubtitleEvt(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * 显示字幕 
		 */		
		public static const SHOW_SUBTITLE:String = "show_subtitle";
		
		/**
		 * 关闭字幕 
		 */		
		public static const CLOSE_SUBTITLE:String = "close_subtitle";
	}
}