package com.xinguoedu.m.vo
{
	/**
	 * 媒体vo  
	 * @author yatsen_yang
	 * 
	 */	
	public class MediaVO extends BaseVO
	{
		public var vid:String;
		
		public var type:String = "http";
		
		/**
		 *  可忽略的长度，被加密的视频的前omittedLength个字节可以不用解密
		 */		
		public var omittedLength:int = 0;
		
		/**
		 * 对视频字节数据进行混淆处理的seed 
		 */		
		public var seed:int;
		
		/**
		 * 是否自动播放 
		 */		
		public var autostart:Boolean = true;
		
		/**
		 * 是否需要检查策略文件，默认为false，因为检查策略文件会占用带宽
		 * 在加载外部视频，和swf不再同一个域，并且需要对视频进行像素级别的访问，需要把此属性设为true
		 * 不然在某些情况下会导致安全沙箱错误 
		 */		
		public var checkPolicyFile:Boolean = false;
		
		/**
		 * 存放多段视频地址的数组 
		 */		
		public var urlArray:Array;
		
		/**
		 * 回放持续时间（以秒为单位）。 允许的值为 -1、0 或正数。
		 * 默认值为 -1，它一直播放完实时流或录制流。 如果为 0，则播放距录制流开始处 start 秒的单个帧。 如果为正数，则播放实时流或录制流 len 秒。  
		 */		
		public var len:Number = -1;
	}
}