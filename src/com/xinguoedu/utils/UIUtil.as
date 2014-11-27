package com.xinguoedu.utils
{
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * 构建UI元素的工具类 
	 * @author yangq1990
	 * 
	 */	
	public class UIUtil
	{
		public function UIUtil()
		{
		}
		
		public static function getTextFormat(family:String, color:uint, size:int, align:String='center'):TextFormat
		{
			var format:TextFormat = new TextFormat();
			format.font = family;
			format.color = color;
			format.size = size;			
			format.align = align;
			return format;
		}
		
		/**
		 * 调整textfield的宽度和高度值
		 * @param tf
		 * @param value tf.width = tf.textWidth + value; tf.height = tf.textHeight + value;
		 * 
		 */		
		public static function adjustTFWidthAndHeight(tf:TextField, value:int = 5):void
		{
			tf.width = tf.textWidth + value;
			tf.height = tf.textHeight + value;
		}
	}
}