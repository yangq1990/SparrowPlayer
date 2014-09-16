package com.xinguoedu.v.base
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * 初始化基类 
	 * @author yatsen_yang
	 * 
	 */	
	public class BaseInitView extends Sprite
	{
		public function BaseInitView()
		{
			super();
			
			stage ? init() : this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler(evt:Event):void			
		{
			init();
		}
		
	    protected function init():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
	}
}