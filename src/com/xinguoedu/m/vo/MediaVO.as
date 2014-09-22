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
	}
}