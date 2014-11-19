package com.xinguoedu.v.ui
{
	import com.xinguoedu.consts.Font;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * 自定义Button
	 * @author yangq1990
	 * 
	 */	
	public class Button extends Sprite
	{
		private var _func:Function;
		protected var _tf:TextField;		
		protected var _w:Number;
		protected var _h:Number;
		protected var _back:uint;
		protected var _alpha:Number;
		protected var _isRound:Boolean;
		
		/**
		 *  
		 * @param w 宽
		 * @param h 高
		 * @param back 背景色
		 * @param alpha 透明度
		 * @param isRound 是否圆角矩形
		 * 
		 */		
		public function Button(w:Number, h:Number, back:uint, alpha:Number, isRound:Boolean=true)
		{
			super();			
			_w = w;
			_h = h;
			_back = back;
			_alpha = alpha;
			_isRound = isRound;
			
			this.mouseChildren = false;
			this.mouseEnabled = this.buttonMode = true;
			
			initUI();
		}
		
		protected function initUI():void
		{
			var g:Graphics = this.graphics;
			g.beginFill(_back, _alpha);
			if(_isRound)
			{
				g.drawRoundRect(0, 0, _w, _h, 10, 10);
			}
			else
			{
				g.drawRect(0, 0, _w, _h);
			}
			g.endFill();
			
			_tf = new TextField();
			_tf.mouseEnabled = false;
			var format:TextFormat = new TextFormat();
			format.align = "center";
			format.font = Font.YAHEI;
			format.size = Font.SIZE;
			format.color = Font.COLOR;			
			_tf.defaultTextFormat = format;
			addChild(_tf);
		}
		
		/**
		 * 注册回调函数 
		 * @param handler
		 * 
		 */		
		public function registerHandler(handler:Function):void
		{
			_func = handler;
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		private function onMouseClick(evt:MouseEvent):void
		{
			(_func != null) && _func();
		}			

		/**
		 * Button label属性 
		 * @return 
		 * 
		 */		
		public function get label():String
		{
			return _tf.text;
		}

		public function set label(value:String):void
		{
			if(_tf.text != value)
			{
				_tf.text = value;
				adjustTFPos();
			}			
		}
		
		/** 调整文字位置 **/
		private function adjustTFPos():void
		{
			_tf.width = _tf.textWidth + 10;
			_tf.height = _tf.textHeight + 10;
			_tf.x = (_w - _tf.width) >> 1;
			_tf.y = (_h - _tf.height) >> 1;
		}
		
		override public function get width():Number
		{
			return _w;
		}
		
		override public function get height():Number
		{
			return _h;
		}
	}
}