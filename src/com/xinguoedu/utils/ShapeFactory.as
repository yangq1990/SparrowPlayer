package com.xinguoedu.utils
{
	import flash.display.Shape;

	/**
	 * 广告或者问卷右上角的关闭图形
	 * @author yatsen_yang
	 * 
	 */	
	public class ShapeFactory
	{
	
		private static const WIDTH:uint = 10;
		private static const HEIGHT:uint = 10;
		
		/** 广告关闭按钮的半径  **/
		public static const RADIUS:uint = 11;
		
		public function ShapeFactory()
		{
			throw new Error("no need");
		}
		
		/**
		 * 根据不同的颜色值，生成不同颜色的叉号Shape 
		 * @param bgColor 图形背景颜色
		 * @return Shape
		 * 
		 */		
		public static function getShapeByColor(bgColor:uint):Shape			
		{
			var t_shape:Shape = new Shape();	
			
			t_shape.graphics.beginFill(bgColor);
			t_shape.graphics.drawCircle(0,0,RADIUS);
			t_shape.graphics.endFill();	
			
			t_shape.graphics.lineStyle(2,0xffffff);
			t_shape.graphics.moveTo(-WIDTH/2,-HEIGHT/2);
			t_shape.graphics.lineTo(WIDTH/2,HEIGHT/2);
			
			t_shape.graphics.moveTo(WIDTH/2,-HEIGHT/2);
			t_shape.graphics.lineTo(-WIDTH/2,HEIGHT/2);
			
			return t_shape;
		}
	}
}