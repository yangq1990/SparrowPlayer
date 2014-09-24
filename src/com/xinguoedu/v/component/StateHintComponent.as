package com.xinguoedu.v.component
{
	import com.greensock.TweenLite;
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.evt.PlayerStateEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.MovieClip;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * 播放和暂停状态提示组件 
	 * @author yatsen_yang
	 * 
	 */	
	public class StateHintComponent extends BaseComponent
	{
		private var _tweenlite:TweenLite;
		
		public function StateHintComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_skin = _m.skin.statehint as MovieClip;
			_skin.x = stageWidth * 0.5; //注册点与中心点重合
			_skin.y = stageHeight - NumberConst.STATEHINT_TO_STAGEBOTTOM;
			addChild(_skin);	
			
			super.buildUI();
		}
		
		override protected function playerStateChangeHandler(evt:PlayerStateEvt):void
		{
			destroy();
			
			if(_m.state == PlayerState.PLAYING || _m.state == PlayerState.BUFFERING)
				_skin.gotoAndStop(2);
			else if(_m.state == PlayerState.PAUSED)
				_skin.gotoAndStop(1);
			
			this.visible = true;
			resize();
						
			_timeout = setTimeout(timeoutHandler, NumberConst.STATEHINT_DELAY);
		}
		
		private function timeoutHandler():void
		{
			_tweenlite = TweenLite.to(this, 0.5, {alpha:0.1, onComplete:tweenCompleteHandler});
		}
		
		private function tweenCompleteHandler():void
		{
			this.alpha = 1;
			this.visible = false;
		}
		
		override protected function resize():void
		{
			if(this.visible)
			{
				_skin.x = stageWidth * 0.5; //注册点与中心点重合
				_skin.y = stageHeight - NumberConst.STATEHINT_TO_STAGEBOTTOM;
			}
		}
		
		private function destroy():void
		{
			if(_timeout)
			{
				clearTimeout(_timeout);
				_timeout = undefined;
			}
			
			if(_tweenlite != null)
			{
				TweenLite.killTweensOf(this, true);
				_tweenlite = null;
				this.alpha = 1;
			}
		}
	}
}