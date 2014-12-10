package com.xinguoedu.consts
{
	/**
	 * 存储与弹幕相关的常量值 
	 * @author yangq1990
	 * 
	 */	
	public class AboutBullet
	{
		public function AboutBullet()
		{
		}
		
		/**
		 * 弹幕信息的边框线条宽度 
		 */		
		public static const LINE_STYLE:int = 2;
	
		/**
		 * 文字移动速度
		 */		
		public static const SPEED:int = 3;
		
		/**
		 * 文字间的行距 
		 */		
		public static const MARGIN:int = 15;
		
		/**
		 * 防止文字锯齿的blurfilter的模糊量 
		 */		
		public static const BLUR_VALUE:int = 1.5;
		
		/**
		 * 信息来源于自己 
		 */		
		public static const FROM_SELF:String = "self";
		
		/**
		 * 信息来源于别人 
		 */		
		public static const FROM_SOMEONE:String = "someone";
	}
}