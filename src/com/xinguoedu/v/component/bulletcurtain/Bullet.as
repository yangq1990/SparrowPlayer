package com.xinguoedu.v.component.bulletcurtain
{
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.utils.UIUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * 吐槽显示对象 
	 * @author yangq1990
	 * 
	 */	
	public class Bullet extends Sprite
	{
		private var _tf:TextField;
		
		public function Bullet(msg:String)
		{
			super();
			
			_tf = new TextField();
			_tf.text = msg;
			_tf.mouseEnabled = _tf.selectable = false;
			_tf.setTextFormat(UIUtil.getTextFormat(Font.YAHEI, Math.random() * Font.COLOR, Font.DEFAULT_SUBTITLE_SIZE_FULLSCREEN));
			UIUtil.adjustTFWidthAndHeight(_tf);
			addChild(_tf);
		}
		
		/**
		 * 吐槽的文字 
		 * @return 
		 * 
		 */		
		public function get msg():String
		{
			return _tf.text;
		}
		
		public function set msg(txt:String):void
		{
			if(_tf.text != txt)
			{
				_tf.text = txt;
				UIUtil.adjustTFWidthAndHeight(_tf);
			}
		}
		
		override public function get width():Number
		{
			return _tf.width;
		}
		
		override public function get height():Number
		{
			return _tf.height;	
		}
	}
}