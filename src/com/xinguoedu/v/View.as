package com.xinguoedu.v
{
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.StageReference;
	import com.xinguoedu.v.base.BaseComponent;
	import com.xinguoedu.v.component.AdComponent;
	import com.xinguoedu.v.component.BottomHintComponent;
	import com.xinguoedu.v.component.ControlBarComponent;
	import com.xinguoedu.v.component.DisplayComponent;
	import com.xinguoedu.v.component.ErrorComponent;
	import com.xinguoedu.v.component.LogoComponent;
	import com.xinguoedu.v.component.QrcodeComponent;
	import com.xinguoedu.v.component.StateHintComponent;
	import com.xinguoedu.v.component.SubtitleComponent;
	import com.xinguoedu.v.component.VideoAdsComponent;
	import com.xinguoedu.v.component.VideoComponent;
	import com.xinguoedu.v.component.bulletcurtain.BulletcurtainComponent;
	import com.xinguoedu.v.component.live.LiveStatusComponent;
	import com.xinguoedu.v.component.live.LoginComponent;
	import com.xinguoedu.v.component.live.UserOnOffLineComponent;
	import com.xinguoedu.v.component.logger.LoggerComponent;
	import com.xinguoedu.v.component.settings.SettingsComponent;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	public class View extends EventDispatcher
	{
		private var _m:Model;
		
		/** 界面显示组件的父容器 **/
		private var _root:Sprite; 
		
		private var _videoComp:BaseComponent;
		
		private var _displayComp:BaseComponent;
		
		private var _controlbarComp:BaseComponent;
		
		private var _subtitleComp:BaseComponent;
		
		private var _bulletcurtainComp:BaseComponent;
		
		private var _logoComp:BaseComponent;	
		
		private var _adComp:BaseComponent;
		
		private var _qrcodeComp:BaseComponent;
		
		private var _stateHintComp:BaseComponent;
		
		private var _errorHintComp:BaseComponent;
		
		private var _videoadsComp:VideoAdsComponent;
		
		private var _bottomHintComp:BaseComponent;
		
		private var _settingsComp:BaseComponent;
		
		private var _loginComp:BaseComponent;
		
		private var _liveStatusComp:BaseComponent;
		
		private var _userOnOffLineComp:BaseComponent;
		
		private var _loggerComp:BaseComponent;
		
		public function View(m:Model)
		{
			super();
			
			this._m = m;		
		}		
		
		public function setup():void
		{
			_root = new Sprite();
			_root.name = 'root';
			//_root.mouseEnabled = false; 设置为false会导致自定义右键菜单无法显示
			StageReference.stage.addChildAt(_root, 0);
			
			
			_videoComp = new VideoComponent(_m);
			_videoComp.name = 'videoComp';
			_root.addChild(_videoComp);
			
			_displayComp = new DisplayComponent(_m);
			_displayComp.name = 'displayComp';
			_root.addChild(_displayComp);
			
			if(_m.subtitleVO.url)
			{
				_subtitleComp = new SubtitleComponent(_m);
				_subtitleComp.name = 'subtitleComp';
				_root.addChild(_subtitleComp);
			}
			
			_bulletcurtainComp = new BulletcurtainComponent(_m);
			_bulletcurtainComp.name = 'bulletcurtainComp';
			_root.addChild(_bulletcurtainComp);
			
			_bottomHintComp = new BottomHintComponent(_m);
			_bottomHintComp.name = 'bottomHintComp';
			_root.addChild(_bottomHintComp);
			
			_controlbarComp = new ControlBarComponent(_m);
			_controlbarComp.name = 'controlbarComp';
			_root.addChild(_controlbarComp);		
			
			_adComp = new AdComponent(_m);
			_adComp.name = 'adComp';
			_root.addChild(_adComp);
			
			_qrcodeComp = new QrcodeComponent(_m);
			_qrcodeComp.name = 'qrcodeComp';
			_root.addChild(_qrcodeComp);
			
			_stateHintComp = new StateHintComponent(_m);
			_stateHintComp.name = 'stateHintComp';
			_root.addChild(_stateHintComp);
			
			_errorHintComp = new ErrorComponent(_m);
			_errorHintComp.name = 'errorHintComp';
			_root.addChild(_errorHintComp);
			
			if(_m.videoadVO.enabled)
			{
				_videoadsComp = new VideoAdsComponent(_m);
				_videoadsComp.name = 'videoadsComp';
				_root.addChild(_videoadsComp);
			}					
			
			_settingsComp = new SettingsComponent(_m);
			_settingsComp.name = 'settingComp';
			_root.addChild(_settingsComp);
			
			_loginComp = new LoginComponent(_m);
			_loginComp.name = 'loginComp';
			_root.addChild(_loginComp);
			
			_liveStatusComp = new LiveStatusComponent(_m);
			_liveStatusComp.name = 'liveStatusComp';
			_root.addChild(_liveStatusComp);
			
			_userOnOffLineComp = new UserOnOffLineComponent(_m);
			_userOnOffLineComp.name = "userOnOffLineComp";
			_root.addChild(_userOnOffLineComp);
			
			_loggerComp = new LoggerComponent(_m);
			_loggerComp.name = 'loggerComp';
			_root.addChild(_loggerComp);
			
			_logoComp = new LogoComponent(_m);
			_logoComp.name = 'logoComp';
			_root.addChild(_logoComp);
			
			var rightclickmenu:RightClickMenu = new RightClickMenu(_m, _root);
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
			_controlbarComp.addEventListener(ViewEvt.MOUSEDOWN_TO_SEEK, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.SEEK, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.FULLSCREEN, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.NORMAL, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.VOLUME, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.MUTE, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.KEYDOWN_SPACE, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.PLAY_NEXT, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_controlbarComp.addEventListener(ViewEvt.DRAG_TIMESLIDER_MOVING, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			
			_videoComp.addEventListener(ViewEvt.PAUSE, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_videoComp.addEventListener(ViewEvt.PLAY, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_videoComp.addEventListener(ViewEvt.NORMAL, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			_videoComp.addEventListener(ViewEvt.FULLSCREEN, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			
			_loginComp.addEventListener(ViewEvt.ENTER_ROOM, function(evt:ViewEvt):void{ dispatchEvent(evt); });
			
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