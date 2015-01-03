package com.xinguoedu.m.media
{
	import com.xinguoedu.consts.AboutBullet;
	import com.xinguoedu.consts.ConnectionStatus;
	import com.xinguoedu.consts.GroupStatus;
	import com.xinguoedu.consts.P2PStreamStatus;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.view.BulletEvt;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.vo.BaseVO;
	import com.xinguoedu.utils.Logger;
	
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;
	import flash.net.NetStream;

	/**
	 * p2p直播 
	 * @author yangq1990
	 * 
	 */	
	public class P2PLiveMedia extends BaseLiveMedia
	{
		private var _netGroup:NetGroup;		
		private var _groupSpec:GroupSpecifier;
		private var _isAddedToGroup:Boolean;
		
		public function P2PLiveMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function connectToMediaServer(vo:BaseVO=null):void
		{
			super.connectToMediaServer(vo);
			_nc.connect("rtmfp://" + _mediaVO.url, _userVO);
		}
		
		/** 状态处理函数 **/
		override protected function statusHandler(evt:NetStatusEvent):void
		{
			Logger.info('p2plive status', evt.info.code);
			
			switch(evt.info.code)
			{
				//handle netconnection status
				case ConnectionStatus.SUCCESS:		
					super.connectServerSuccess();
					initNetGroup();					
					break;
				case ConnectionStatus.REJECTED:
					super.dispatchLiveStatus('连接服务器被拒');
					break;
				case ConnectionStatus.CLOSED:
					super.dispatchLiveStatus('连接关闭');					
					break;				
				//handle netgroup status
				case GroupStatus.SUCCESS:
					_isAddedToGroup = true;
					//创建同级对同级发行者连接
					_outgoingStream = new NetStream(_nc, _groupSpec.groupspecWithAuthorizations());
					_outgoingStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);		
					
					_incomingStream  = new NetStream(_nc, _groupSpec.groupspecWithAuthorizations());
					_incomingStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
					super.dispatchLiveStatus('加入组成功');
					break;			
				case GroupStatus.POSTING_NOTIFY: //收到消息
					EventBus.getInstance().dispatchEvent(new BulletEvt(BulletEvt.CHAT_MSG_INCOMING, {msg:evt.info.message.msg, from:AboutBullet.FROM_SOMEONE}));
					break;				
				//handler p2pstream status
				case P2PStreamStatus.SUCCESS:
					_outgoingStream.client = this;
					_incomingStream.client = this;
					
					if(_userVO.name == "sparrowplayer")
					{
						publishStream();
					}
					else
					{
						playStream();
					}					
					super.dispatchEvt(StreamStatus.LIVE_STREAM);
					super.dispatchMetaData({w:_video.width, h:_video.height});
					super.dispatchLiveStatus('建立p2p连接成功');
					break;				
				default:
					break;
			}
		}
	
		private function initNetGroup():void
		{
			_groupSpec = new GroupSpecifier(_userVO.groupName);
			_groupSpec.multicastEnabled = true; //为 NetGroup 启用流
			_groupSpec.postingEnabled = true; //为 NetGroup 启用发布
			_groupSpec.serverChannelEnabled = true; // NetGroup 的成员可以打开到服务器的通道
			
			_netGroup = new NetGroup(_nc, _groupSpec.groupspecWithAuthorizations());
			_netGroup.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
		}			
		
		override public function sendChatMsg(name:String, msg:String):void
		{
			var data:Object = {};
			data.msg = name + "说：" + msg;
			data.sender = _nc.nearID;			
			_netGroup.post(data);
		}
	}
}