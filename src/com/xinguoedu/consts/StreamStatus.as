package com.xinguoedu.consts
{
	/**
	 * 流状态类 
	 * @author yatsen_yang
	 * 
	 */	
	public class StreamStatus
	{
		public static const START_LOAD_MEDIA:String = "start_load_media";
		
		public static const LOAD_MEDIA_IOERROR:String = "load_media_ioerror";
		
		public static const PLAY_START:String = "NetStream.Play.Start";
		
		public static const PLAY_STOP:String = "NetStream.Play.Stop";
		
		public static const PAUSE_NOTIFY:String = "NetStream.Pause.Notify";
		
		public static const UNPAUSE_NOTIFY:String = "NetStream.Unpause.Notify";
		
		public static const BUFFER_FULL:String = "NetStream.Buffer.Full";
		
		public static const BUFFER_EMPTY:String = "NetStream.Buffer.Empty";
		
		public static const BUFFERING:String = "NetStream.Buffering";
		
		public static const STREAM_NOT_FOUND:String = "NetStream.Play.StreamNotFound";
		
		public static const SEEK_NOTIFY:String = "NetStream.Seek.Notify";
		
		public static const SEEK_COMPLETE:String = "NetStream.Seek.Complete";
		
		public static const PLAY_COMPLETE:String = "media_play_complete";
		
		/**
		 * 流快要结束 
		 */		
		public static const PLAY_NEARLY_COMPLETE:String = "play_nearly_complete";
		
		/**
		 * 流播放位置未到快要结束界限，比如距离播放结束40s以内认为是play_nearly_complete
		 * 距离播放结束超过40s就是not_nearly_complete 
		 */		
		public static const NOT_NEARLY_COMPLETE:String = "not_nearly_complete";
		
	}
}