package com.xinguoedu.consts
{
	/**
	 * 字体常量类 
	 * @author yatsen_yang
	 * 
	 */	
	public class Font
	{
		public function Font()
		{
		}
		
		/**
		 * 有些浏览器能识别微软雅黑
		 * 有些浏览器能识别Microsoft YaHei UI
		 * 这样写可保证在不同的浏览器上字体显示的一致性
		 */		
		public static const YAHEI:String = "Microsoft YaHei UI,微软雅黑";
		
		/**
		 * 文字默认大小 
		 */		
		public static const SIZE:int = 14;
		
		/**
		 * 文字默认颜色 
		 */		
		public static const COLOR:uint = 0xffffff;
		
		/**
		 * 普通状态下默认字幕的字体大小 
		 */		
		public static const DEFAULT_SUBTITLE_SIZE:int = 22;
		
		/**
		 * 全屏状态下默认字幕的字体大小 
		 */		
		public static const DEFAULT_SUBTITLE_SIZE_FULLSCREEN:int = 36;
		
		/**
		 *  普通状态下第二字幕（如果有的话）的字体大小
		 */		
		public static const SECOND_SUBTITLE_SIZE:int = 18;
		
		/**
		 *  全屏状态下第二字幕（如果有的话）的字体大小
		 */		
		public static const SECOND_SUBTITLE_SIZE_FULLSCREEN:int = 28;
	}
}