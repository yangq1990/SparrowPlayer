package com.xinguoedu.v.node
{
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.utils.Strings;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	/**
	 * 节点显示对象 
	 * @author yangq1990
	 * 
	 */	
	public class Node extends Sprite
	{
		private var _obj:Object;
		public function Node(obj:Object)
		{
			super();
			
			_obj = obj;
			
			initUI();
		}
		
		private function initUI():void
		{
			var g:Graphics = this.graphics;
			g.beginFill(0xffffff);
			g.drawCircle(0,0,NumberConst.NODE_RADIUS);
			g.endFill();
		}
		
		/**
		 * 
		 * @return 时间节点的提示信息
		 * 
		 */		
		public function get hint():String
		{
			return Strings.digits(_obj.time) + "  " + _obj.hint;
		}
		
		public function get time():Number
		{
			return _obj.time;
		}
	}
}