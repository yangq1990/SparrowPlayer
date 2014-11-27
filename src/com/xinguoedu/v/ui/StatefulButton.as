package com.xinguoedu.v.ui
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * 有状态的Button，即可以切换 
	 * @author yangq1990
	 * 
	 */	
	public class StatefulButton extends Button
	{
		public function StatefulButton(w:Number, h:Number, back:uint, alpha:Number, isRound:Boolean=true)
		{
			super(w, h, back, alpha, isRound);
		}
		
		override protected function onMouseClick(evt:MouseEvent):void
		{
			(_func != null) && _func.apply(null, [label]);
		}
		
		/**
		 * 设置Button显示状态 
		 * @param enabled
		 * 
		 */		
		public function setState(enabled:Boolean):void
		{
			enabled ? (this.alpha = _alpha) : this.alpha = 0.5;
		}
	}
}