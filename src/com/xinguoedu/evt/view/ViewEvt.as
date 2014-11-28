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
		/**
		 * 播放 
		 */		
		public static const PLAY:String = "play_ve";
		/**
		 * 暂停 
		 */		
		public static const PAUSE:String = "pause_ve";
		/**
		 * 播放下一集 
		 */		
		public static const PLAY_NEXT:String = "playnext_ve";
		/**
		 * 全屏 
		 */		
		public static const FULLSCREEN:String = "fullscreen_ve";
		/**
		 * 退出全屏 
		 */		
		public static const NORMAL:String = "normal_ve";
		/**
		 * 静音 
		 */		
		public static const MUTE:String = "mute_ve";
		/**
		 * 拖动 
		 */		
		public static const SEEK:String = "seek_se";
		/**
		 * 音量 
		 */		
		public static const VOLUME:String = "volume_se";
		/**
		 * 广告视频结束 
		 */		
		public static const VIDEOADS_COMPLETE:String = "videoads_complete_ve";
		/**
		 * 拖动timeslider icon移动 
		 */		
		public static const DRAG_TIMESLIDER_MOVING:String = "drag_timeslider_moving_ve";
		/**
		 * 按下键盘空格键 
		 */		
		public static const KEYDOWN_SPACE:String = "keydown_space_ve";
		
		/**
		 * 显示controlbar 
		 */		
		public static const SHOW_CONTROLBAR:String = "show_controlbar_ve";
		
		/**
		 * 隐藏controlbar 
		 */		
		public static const HIDE_CONTROLBAR:String = "hide_controlbar_ve";
		
		/**
		 * mouse down timeslider, 准备拖动 
		 */		
		public static const MOUSEDOWN_TO_SEEK:String = "mousedown_to_seek_ve";
		
		/**
		 * 显示日志组件 
		 */		
		public static const SHOW_LOGGER_COMPONENT:String = "show_logger_component_ve";
		
		/**
		 * 显示或隐藏设置组件 
		 */		
		public static const SETTINGS_COMPONENT:String = "settings_component_ve";
		
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