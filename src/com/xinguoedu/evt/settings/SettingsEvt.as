package com.xinguoedu.evt.settings
{
	import flash.events.Event;
	
	/**
	 * 设置选项事件类 
	 * @author yangq1990
	 * 
	 */	
	public class SettingsEvt extends Event
	{
		
		/////////////////////////////////字幕///////////////////////////////////////
		/**
		 * 显示字幕 
		 */		
		public static const SHOW_SUBTITLE:String = "show_subtitle";
		
		/**
		 * 关闭字幕 
		 */		
		public static const CLOSE_SUBTITLE:String = "close_subtitle";
		
		/////////////////////////////////弹幕///////////////////////////////////////
		
		/**
		 * 显示弹幕 
		 */		
		public static const SHOW_BULLETCURTAIN:String = "show_bulletcurtain";		
		
		/**
		 * 关闭弹幕
		 */		
		public static const CLOSE_BULLETCURTAIN:String = "close_bulletcurtain";
		
		/////////////////////////////////画面///////////////////////////////////////
		
		/**
		 * 均衡 
		 */		
		public static var UNIFORM:String = "uniform";
		
		/**
		 *  原尺寸
		 */		
		public static var NONE:String = "none";
		
		/**
		 * 铺满 
		 */		
		public static var EXACTFIT:String = "exactfit";
		
		/**
		 * 16:9 
		 */		
		public static var SIXTEEN_NINE:String = '16:9';
		
		
		public function SettingsEvt(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}