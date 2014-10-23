package com.xinguoedu.evt.media
{
	import flash.events.Event;
	
	/**
	 * 与分段视频有关的事件类 
	 * @author yatsen_yang
	 * 
	 */	
	public class SegmentEvt extends Event
	{		
		public static const LOAD_SEGMENT:String = "load_segment";
		
		/**
		 * 开始播放分段视频 
		 */		
		public static const PLAY_START:String = "segment_play_start";
		
		public static const LOAD_SEGMENT_IOERROR:String = "load_segment_ioerror";
		
		/**
		 * 分段视频的metadata 
		 */		
		public static const METADATA:String = "segment_metadata";
		
		public static const NET_STATUS:String = "net_status";
		
		public static const TIME:String = "segment_time";
		
		public static const PRELOAD_NEXT:String = "preload_next";
		
		/**
		 * 分段播放结束 
		 */		
		public static const COMPLETE:String = "segment_playback_complete";
		
		/**
		 * 切换画面 
		 */		
		public static const SWITCH:String = "switch";
		
		public var data:*;
		
		public function SegmentEvt(type:String, d:*=null,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			data = d;
		}
		
		override public function clone():Event
		{
			return new SegmentEvt(type, data);
		}
	}
}