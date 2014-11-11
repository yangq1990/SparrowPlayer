package com.xinguoedu.v.node
{
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.consts.PlayerColor;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * 显示节点提示信息,带Spt表明此类是一个Sprite 
	 * @author yangq1990
	 * 
	 */	
	public class NodeHintSpt extends Sprite
	{
		private var _tf:TextField;
		
		public function NodeHintSpt()
		{
			super();
			
			_tf = new TextField();
			_tf.width = 150;
			_tf.wordWrap = _tf.multiline = true;
			_tf.mouseEnabled = false;
			_tf.type = TextFieldType.DYNAMIC;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.defaultTextFormat = new TextFormat(Font.YAHEI, 12, 0xffffff);
			addChild(_tf);
		}
		
		public function set hint(str:String):void
		{
			if(_tf.text != str)
			{
				_tf.text = str;
				_tf.height = _tf.textHeight + 5; 
				drawBack();
			}
		}
		
		private function drawBack():void
		{
			var g:Graphics = this.graphics;
			var w:Number = _tf.width;
			var h:Number = _tf.height;

			//画圆角矩形
			g.clear();
			g.beginFill(PlayerColor.MAIN_BG);
			g.drawRoundRect(0, 0, w, h, NumberConst.NODE_HINT_ROUNDED_REC, NumberConst.NODE_HINT_ROUNDED_REC);			
			//画小三角形
			var temp:Number = Math.sqrt(2);
			g.moveTo(w*0.5 - NumberConst.TRIANGLE_SIDE / temp, h);
			g.lineTo(w*0.5, h + NumberConst.TRIANGLE_SIDE / temp);
			g.lineTo(w*0.5 + NumberConst.TRIANGLE_SIDE / temp, h);			
			g.endFill();
		}
		
		public function get hint():String
		{
			return _tf.text;
		}
	}
}