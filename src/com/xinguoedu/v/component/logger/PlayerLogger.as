package com.xinguoedu.v.component.logger
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	/**
	 * 播放器日志组件 
	 * @author yangq1990
	 * 
	 */	
	public class PlayerLogger extends Sprite
	{
		private var _w:Number;
		private var _h:Number;
		private var _back:uint;
		private var _alpha:Number;
		private var _sysTF:TextField;
		private var _errorTF:TextField;
		private var _totalMemory:Number;
		private var _privateMemory:Number;
		private var _interval:uint;
		
		/**
		 * 
		 * @param w 宽
		 * @param h 高
		 * @param back 背景色
		 * @param alpha 透明度
		 * @param align 字体align
		 * @param color 字体颜色
		 * @param font 字体
		 * @param size 字体大小
		 * 
		 */		
		public function PlayerLogger(w:Number, h:Number, back:uint, alpha:Number, align:String, color:uint, font:String, size:int)
		{
			super();
			this.mouseEnabled = this.mouseChildren = true;
			_w = w;
			_h = h;
			_back = back;
			_alpha = alpha;
			
			var format:TextFormat = new TextFormat();
			format.align = align;
			format.color = color;
			format.font = font;
			format.size = size;
			
			_sysTF = new TextField();
			_sysTF.multiline = _sysTF.wordWrap = true;
			_sysTF.width = _w;
			_sysTF.height = _h / 2;
			_sysTF.defaultTextFormat = format;
			addChild(_sysTF);
			
			_errorTF = new TextField();
			_errorTF.width = _w;
			_errorTF.defaultTextFormat = format;
			addChild(_errorTF);
			
			draw();
		}
		
		private function draw():void
		{
			var g:Graphics = this.graphics;
			g.beginFill(_back, _alpha);
			g.drawRect(0, 0, _w, _h);
			g.endFill();
		}
		
		private function showSysInfo(totalMemory:Number, privateMemory:Number):void
		{
			_sysTF.text = "操作系统：" + Capabilities.os + "\n" + 
				"FP版本：" + Capabilities.version + "\n" + 
			    "是否调试版本：" + (Capabilities.isDebugger ? "是" : "否") + "\n" +
			    "浏览器：" + getBrowserInfo() + "\n" +
				"FP当前使用内存：" + (totalMemory / 1024 / 1024) + "M" + "\n" +
				"浏览器当前使用内存：" +  (privateMemory / 1024 / 1024) + "M" + "\n" +
				"--------------------------------------------------" + "\n";
		}
		
		private function getBrowserInfo():String
		{
			var returnValue:String = ExternalInterface.call("function(){return navigator.userAgent;}");
			return (returnValue ? returnValue:"");
		}
		
		/**
		 * 显示组件
		 * @param msg 错误信息
		 * 
		 */		
		public function showLogger(msg:String):void
		{
			showSysInfo(System.totalMemory, System.privateMemory);
			_errorTF.text = msg;			
			_errorTF.y = _sysTF.y + _sysTF.textHeight + 5;
			
			_interval && clearInterval(_interval);
			_interval = setInterval(refresh, 1000);
		}
		
		public function hideLogger():void
		{
			_interval && clearInterval(_interval);
		}
		
		private function refresh():void
		{
			showSysInfo(System.totalMemory, System.privateMemory);
		}
		
		/**
		 * 日志信息 
		 * @return 
		 * 
		 */		
		public function get log():String
		{
			return _sysTF.text + _errorTF.text;
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