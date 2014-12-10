package com.xinguoedu.v.component.bulletcurtain
{
	import com.xinguoedu.consts.AboutBullet;
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.consts.PlayerColor;
	import com.xinguoedu.utils.UIUtil;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	
	/**
	 * 吐槽显示对象 
	 * @author yangq1990
	 * 
	 */	
	public class Bullet extends Sprite
	{
		private var _tf:TextField;
		
		public function Bullet(msg:String, from:String)
		{
			super();
			
			_tf = new TextField();
			_tf.text = msg;
			_tf.mouseWheelEnabled = _tf.mouseEnabled = _tf.selectable = false;
			_tf.setTextFormat(UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.DEFAULT_SUBTITLE_SIZE));
			UIUtil.adjustTFWidthAndHeight(_tf);
			
			(from == AboutBullet.FROM_SELF) && drawBorder(); //自己说的msg显示边框
			_tf.filters = [new BlurFilter(AboutBullet.BLUR_VALUE, AboutBullet.BLUR_VALUE)]; //抗锯齿	
			addChild(_tf);
		}
		
		public function reset(msg:String, from:String):void
		{
			if(_tf.text != msg)
			{
				_tf.text = msg;
				_tf.setTextFormat(UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.DEFAULT_SUBTITLE_SIZE));
				UIUtil.adjustTFWidthAndHeight(_tf);
			}
			
			(from == AboutBullet.FROM_SELF) ? drawBorder() : this.graphics.clear();
		}
		
		/** 画边框 **/
		private function drawBorder():void
		{
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill(0x000000, 0);
			g.lineStyle(AboutBullet.LINE_STYLE, PlayerColor.MAIN_COLOR);
			g.drawRect(-AboutBullet.LINE_STYLE, -AboutBullet.LINE_STYLE, _tf.width+AboutBullet.LINE_STYLE, _tf.height+AboutBullet.LINE_STYLE);
			g.endFill();
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