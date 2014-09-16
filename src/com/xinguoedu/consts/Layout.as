package com.xinguoedu.consts
{
	/**
	 * 与布局相关的常量值类
	 * @author yatsen_yang
	 * 
	 */	
	public class Layout
	{
		public function Layout()
		{
		}
		
		/**
		 * 推荐视频单元格宽度 
		 */		
		public static const CELL_W:int = 200;
		
		/**
		 * 推荐视频单元格高度 
		 */		
		public static const CELL_H:int = 120;
		
		/**
		 * 底部提示区域高度 
		 */		
		public static const HINT_AREA_HEIGHT:int = 30;
		
		/**
		 * 全屏界面下提示界面与controlbar的间距 
		 */		
		public static const FULLSCREEN_MARGIN:int = 10;
		
		/**
		 * 出现问答提示界面时，类似于遮罩效果的临时sprite的name 
		 */		
		public static const TEMPVIEW:String = "tempView";
		
		/**
		 * playbutton, pausebutton, fullscreenbutton距离舞台边缘的距离
		 * playbutton, pausebutton右边到timeslider左边的距离
		 */		
		public static const MARGIN_TO_STAGEBORDER:int = 10;
		
		
		/**
		 * controlbar按钮的间距 
		 */		
		public static const MARGIN_BETWEEN_BUTTON:int = 20;
		
		/**
		 * 时间提示，文字提示bottom到controlbar的margin 
		 */		
		public static const MARGIN_HINT_TO_CONTROLBAR:int = 4;
	}
}