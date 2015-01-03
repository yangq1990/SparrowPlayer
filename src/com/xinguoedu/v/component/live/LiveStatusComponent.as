package com.xinguoedu.v.component.live
{
	import com.greensock.TweenLite;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.v.base.BaseHintComponent;
	
	/**
	 * 直播状态组件 
	 * @author yangq1990
	 * 
	 */	
	public class LiveStatusComponent extends BaseHintComponent
	{		
		public function LiveStatusComponent(m:Model)
		{
			super(m);
		}	
		
		override protected function addListeners():void
		{
			EventBus.getInstance().addEventListener(MediaEvt.LIVE_STATUS, liveStatusHandler);
		}
		
		private function liveStatusHandler(evt:MediaEvt):void
		{
			if(!this.visible)
			{
				this.visible = true;
				super.setHintTxt(evt.data);
				TweenLite.from(this, 0.4, {alpha:0.4, y:stageHeight, onComplete:super.startTimer});
			}
			else
			{
				_repo.push(evt.data);
				super.startTimer();
			}
		}
		
		override protected function resize():void
		{
			if(this.visible)
			{
				this.x = (stageWidth - this.width) >> 1;
				this.y = stageHeight - this.height;
			}
		}		
		
		override public function get width():Number
		{
			return _hint.width;
		}
		
		override public function get height():Number
		{
			return _hint.height;
		}
	}
}