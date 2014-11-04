package com.xinguoedu.v.component
{
	import com.greensock.TweenLite;
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.evt.PlayerStateEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.Logger;
	import com.xinguoedu.utils.MultifunctionalLoader;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * 广告组件 
	 * @author yatsen_yang
	 * 
	 */	
	public class AdComponent extends BaseComponent
	{
		/** 装广告的容器 **/
		private var _ad:Sprite;		
		/** 当前广告在广告数组里的索引**/
		private var _currentIndex:int = 0;
		/** 广告是否加载完 **/
		private var _isLoadComplete:Boolean = false;
		/** 广告动画的引用 **/
		private var _tween:TweenLite;
		
		public function AdComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_ad = new Sprite();
			_ad.buttonMode = true;
			_ad.addEventListener(MouseEvent.CLICK, clickHandler);
			addChild(_ad);
			
			super.buildUI();
		}
	
		override protected function playerStateChangeHandler(evt:PlayerStateEvt):void
		{
			switch(_m.state) 
			{
				case PlayerState.BUFFERING:
				case PlayerState.PLAYING:
					this.visible = false;
					if(_tween != null)
					{
						TweenLite.killTweensOf(this, true);
						_tween = null;
					}
					break;
				case PlayerState.PAUSED:	
					showAd();
				default:
					break;
			}
		}
		
		private function showAd():void
		{
			if(ads_num==0)
				return;
			
			var index:int = int(Math.random() * ads_num);	
			if(_isLoadComplete && _currentIndex == index)
			{
				tween();
				return;
			}
			
			_currentIndex = index;
			loadAdvertisement(index);
		}
		
		private function tween():void
		{
			visible = true;
			resize();
			_tween = TweenLite.from(this, 0.4, {alpha:0, scaleX:0.3, scaleY:0.3});			
		}
		
		//加载广告
		private function loadAdvertisement(index:int):void
		{			
			var loader:MultifunctionalLoader = new MultifunctionalLoader();
			loader.registerFunctions(completeHandler);
			loader.load(_m.adVO.adArray[index].url);
		}	
		
		private function completeHandler(dp:DisplayObject):void
		{
			_isLoadComplete = true;
			while(_ad.numChildren) //remove all children
			{
				_ad.removeChildAt(0);
			}
			dp.x = -dp.width * 0.5;
			dp.y = -dp.height * 0.5;
			(dp is Bitmap) && (Bitmap(dp).smoothing = true);//如果是图片，设置smoothing
			_ad.addChild(dp);		
				
			(_closeBtn == null) && drawCloseBtn();
			_closeBtn.x = dp.x + dp.width;
			_closeBtn.y = dp.y;
			
			if(_m.state == PlayerState.PAUSED)
			{
				tween();
			}			
		}
		
		override protected function resize():void
		{
			if(this.visible)
			{
				this.x = stageWidth >> 1;
				this.y = stageHeight >> 1;
			}
		}
		
		private function clickHandler(evt:MouseEvent):void
		{
			navigateToURL(new URLRequest(_m.adVO.adArray[_currentIndex].link));
		}
		
		/** 此视频对应的广告数 **/
		private function get ads_num():int
		{			
			var num:int = 0;
			try
			{
				num =  _m.adVO.adArray.length;
			}
			catch(err:Error)
			{
				_m.developermode && (Logger.error("AdComponent","获取广告数组length失败"));
				num = 0;
			}
			return num;
		}
	}
}