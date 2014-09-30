package com.xinguoedu.evt.view
{
	import flash.events.Event;
	
	/**
	 * view事件类 
	 * @author yatsen_yang
	 * 
	 */	
	public class ViewEvt extends Event
	{
		public static const PLAY:String = "play_ve";
		public static const PAUSE:String = "pause_ve";
		public static const PLAY_NEXT:String = "playnext_ve";
		public static const FULLSCREEN:String = "fullscreen_ve";
		public static const NORMAL:String = "normal_ve";
		public static const MUTE:String = "mute_ve";
		public static const TIME:String = "time_se";
		public static const VOLUME:String = "volume_se";
		public static const VIDEOADS_COMPLETE:String = "videoads_complete_ve";
		/**
		 * 拖动timeslider icon移动 
		 */		
		public static const DRAG_TIMESLIDER_MOVING:String = "drag_timeslider_moving";
		/**
		 * 按下键盘空格键 
		 */		
		public static const KEYDOWN_SPACE:String = "keydown_space_ve";
		
		public static const SHOW_CONTROLBAR:String = "show_controlbar_ve";
		
		public static const HIDE_CONTROLBAR:String = "hide_controlbar_ve";
		
		public var data:*;
		
		public function ViewEvt(type:String, data:*=null,  bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		override public function clone():Event
		{
			return new ViewEvt(type, data, bubbles, cancelable);
		}
	}
}