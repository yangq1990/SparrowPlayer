package com.xinguoedu.v.base
{
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.UIUtil;
	
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	/**
	 * 提示信息组件基类 
	 * @author yangq1990
	 * 
	 */	
	public class BaseHintComponent extends BaseComponent
	{
		public function BaseHintComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{			
			_hint = new TextField();
			_hint.defaultTextFormat = UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.SIZE);
			this.addChild(_hint);
			
			_repo = [];
			
			super.buildUI();
		}
		
		protected function startTimer():void
		{
			!_timeout && (_timeout = setTimeout(timeoutHandler, NumberConst.LIVE_STATUS_SWITCH));
		}
		
		protected function timeoutHandler():void
		{
			super.destroyTimer();
			if(_repo.length == 0)
			{			
				this.visible = false;
				return;
			}
			
			setHintTxt(_repo.shift());
			_timeout = setTimeout(timeoutHandler, NumberConst.LIVE_STATUS_SWITCH);			
		}
		
		protected function setHintTxt(txt:String):void
		{
			_hint.text = txt;
			UIUtil.adjustTFWidthAndHeight(_hint);
			resize();
		}
	}
}