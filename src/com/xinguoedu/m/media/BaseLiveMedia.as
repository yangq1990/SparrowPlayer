package com.xinguoedu.m.media
{
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.ModuleEvt;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.vo.BaseVO;
	import com.xinguoedu.m.vo.MediaVO;
	import com.xinguoedu.m.vo.MsgVO;
	import com.xinguoedu.m.vo.UserVO;
	import com.xinguoedu.utils.Logger;
	import com.xinguoedu.utils.Serialize;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.system.SecurityPanel;

	/**
	 * 直播媒体基类 
	 * @author yangq1990
	 * 
	 */	
	public class BaseLiveMedia extends BaseMedia
	{
		protected var _outgoingStream:NetStream;		
		protected var _incomingStream:NetStream;
		protected var _userVO:UserVO;
		protected var _camera:Camera;	
		
		public function BaseLiveMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function init(mediaVO:MediaVO):void
		{
			super.init(mediaVO);
			
			_isLive = true;
			
			_nc = new NetConnection();
			_nc.client = this;
			_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_nc.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_nc.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			
			EventBus.getInstance().dispatchEvent(new ViewEvt(ViewEvt.SHOW_LOGIN_COMPONENT));
		}
		
		override public function connectToMediaServer(vo:BaseVO=null):void
		{
			if(vo == null)
			{
				Logger.error('live', '不允许匿名登录');
				return;
			}
			
			_userVO = vo as UserVO;
		}
		
		protected function errorHandler(evt:Event):void
		{
			Logger.error('BaseLiveMedia', evt.toString());
		}
		
		/** 状态处理函数 **/
		protected function statusHandler(evt:NetStatusEvent):void
		{
			
		}
		
		protected function connectServerSuccess():void
		{
			_isConnected = true;
			super.getVideo(640, 480);
			_display.addChild(_video);		
			EventBus.getInstance().dispatchEvent(new ViewEvt(ViewEvt.REMOVE_LOGIN_COMPONENT));
			super.dispatchLiveStatus('连接服务器成功');
		}
		
		protected function publishStream():void
		{		
			if (Camera.isSupported)
			{
				_camera = Camera.getCamera();
				if (!_camera) 
				{
					super.dispatchLiveStatus('没有安装摄像头，无法直播!!!')	
				}
				else if (_camera.muted)
				{
					Security.showSettings(SecurityPanel.PRIVACY);
					_camera.addEventListener(StatusEvent.STATUS, cameraStatusHandler);
				}
				else 
				{
					attachCameraAndPublish();
				}		
			}
			else 
			{
				Logger.info('P2PLiveMedia', "The Camera class is not supported on this device.");
			}
		}
		
		private function cameraStatusHandler(evt:StatusEvent):void
		{
			if (evt.code == "Camera.Unmuted") 
			{
				attachCameraAndPublish(); 
				_camera.removeEventListener(StatusEvent.STATUS, statusHandler);
			}
		}
		
		/** 连接到摄像头发布视频 **/
		protected function attachCameraAndPublish():void
		{
			_camera.setMode(_video.width,_video.height,15);
			_video.attachCamera(_camera);
			_outgoingStream.attachCamera(_camera);
			_outgoingStream.publish("liveshow");	
		}
		
		/** 播放流 **/
		protected function playStream():void
		{			
			_incomingStream.play('liveshow');			
			_video.attachNetStream(_incomingStream);
		}
		
		/**
		 * 消息回调 
		 * @param data
		 * 
		 */		
		public function messageCallBack(data:*):void
		{			
			if(!data['moduleID'])
			{
				Logger.error('MainConnection', 'callback--没有模块');
				return;
			}			
			
			var msgVO:MsgVO = Serialize.serialize(data, new MsgVO());
			EventBus.getInstance().dispatchEvent(new ModuleEvt(ModuleEvt.INCOMING_MSG, msgVO.moduleID , msgVO));
		}
		
		public function close():void
		{
			
		}		
	}
}