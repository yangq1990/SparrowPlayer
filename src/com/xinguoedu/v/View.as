package com.xinguoedu.v
{
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.StageReference;
	import com.xinguoedu.v.base.BaseComponent;
	import com.xinguoedu.v.component.AdComponent;
	import com.xinguoedu.v.component.ControlBarComponent;
	import com.xinguoedu.v.component.ErrorComponent;
	import com.xinguoedu.v.component.LogoComponent;
	import com.xinguoedu.v.component.StateHintComponent;
	import com.xinguoedu.v.component.VideoAdsComponent;
	import com.xinguoedu.v.component.VideoComponent;
	
	import flash.display.Sprite;
	
	public class View extends Sprite
	{
		private var _m:Model;
		
		/** 界面显示组件的父容器 **/
		private var _root:Sprite; 
		
		private var _videoComp:BaseComponent;
		
		private var _controlbarComp:BaseComponent;
		
		private var _logoComp:BaseComponent;	
		
		private var _adComp:BaseComponent;
		
		private var _stateHintComp:BaseComponent;
		
		private var _errorHintComp:BaseComponent;
		
		private var _videoadsComp:VideoAdsComponent;
		
		public function View(m:Model)
		{
			super();
			
			this._m = m;		
		}		
		
		public function setup():void
		{
			_root = new Sprite();
			StageReference.stage.addChildAt(_root, 0);
			
			
			_videoComp = new VideoComponent(_m);
			_root.addChild(_videoComp);
			
			_controlbarComp = new ControlBarComponent(_m);
			_root.addChild(_controlbarComp);			
			
			_logoComp = new LogoComponent(_m);
			_root.addChild(_logoComp);
			
			_adComp = new AdComponent(_m);
			_root.addChild(_adComp);
			
			_stateHintComp = new StateHintComponent(_m);
			_root.addChild(_stateHintComp);
			
			_errorHintComp = new ErrorComponent(_m);
			_root.addChild(_errorHintComp);
			
			if(_m.videoadVO.enabled)
			{
				_videoadsComp = new VideoAdsComponent(_m);			
				_root.addChild(_videoadsComp);
			}			
			
			var rightclickmenu:RightClickMenuView = new RightClickMenuView(_m, _root);
			rightclickmenu.initializeMenu();
			
			addListeners();
		}
		
		/**
		 * 播放视频广告 
		 * 
		 */		
		public function playVideoAds():void
		{
			_videoadsComp.play();
		}
		
		private function addListeners():void
		{
			_controlbarComp.addEventListener(ViewEvt.PAUSE, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.PLAY, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.TIME, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.FULLSCREEN, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.NORMAL, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.VOLUME, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.KEYDOWN_SPACE, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			
			_videoComp.addEventListener(ViewEvt.PAUSE, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_videoComp.addEventListener(ViewEvt.PLAY, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_videoComp.addEventListener(ViewEvt.NORMAL, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_videoComp.addEventListener(ViewEvt.FULLSCREEN, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			
			if(_m.videoadVO.enabled)
			{
				_videoadsComp.addEventListener(ViewEvt.VIDEOADS_COMPLETE, videoadsCompleteHandler);
			}		
		}
		
		private function videoadsCompleteHandler(evt:ViewEvt):void
		{
			_videoadsComp.removeEventListener(ViewEvt.VIDEOADS_COMPLETE, videoadsCompleteHandler);
			_root.removeChild(_videoadsComp);
			_videoadsComp = null;
			
			dispatchEvent(evt);
		}
	}
}