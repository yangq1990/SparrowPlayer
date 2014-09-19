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
		
		public static const SIZE:int = 14;
		
		public static const COLOR:uint = 0xffffff;
	}
}