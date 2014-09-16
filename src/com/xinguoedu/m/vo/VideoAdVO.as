package com.xinguoedu.m.vo
{
	/**
	 * 视频广告vo 
	 * @author yatsen_yang
	 * 
	 */	
	public class VideoAdVO extends BaseVO
	{
		public function VideoAdVO()
		{
			super();
		}
		
		/**
		 * 是否启用视频广告功能 
		 */		
		public var enabled:Boolean;
		
		/**
		 * 包含视频广告信息的数组
		 */		
		public var adsArray:Array;
		
		/**
		 * 了解详情图片地址 
		 */		
		public var btnurl:String;
	}
}