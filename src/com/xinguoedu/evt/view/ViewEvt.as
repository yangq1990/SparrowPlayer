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
		public static const NEXT:String = "next_ve";
		public static const FULLSCREEN:String = "fullscreen_ve";
		public static const NORMAL:String = "normal_ve";
		public static const MUTE:String = "mute_ve";
		public static const TIME:String = "time_se";
		public static const VOLUME:String = "volume_se";
		public static const VIDEOADS_COMPLETE:String = "videoads_complete_se";
		
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