package com.xinguoedu.m.media
{
	import com.xinguoedu.consts.ConnectionStatus;
	import com.xinguoedu.consts.ModuleID;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.consts.module.ChatModuleEvtType;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.vo.BaseVO;
	import com.xinguoedu.m.vo.MsgVO;
	import com.xinguoedu.utils.Logger;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;

	/**
	 * 基于rtmp协议的直播 
	 * @author yangq1990
	 * 
	 */	
	public class RtmpLiveMedia extends BaseLiveMedia
	{
		public function RtmpLiveMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function connectToMediaServer(vo:BaseVO=null):void
		{
			super.connectToMediaServer(vo);
			_nc.connect("rtmp://" + _mediaVO.url, _userVO);
		}
		
		/** 状态处理函数 **/
		override protected function statusHandler(evt:NetStatusEvent):void
		{
			Logger.info('rtmp live status', evt.info.code);
			
			switch(evt.info.code)
			{
				//handle netconnection status
				case ConnectionStatus.SUCCESS:		
					super.connectServerSuccess();
					
					_outgoingStream = new NetStream(_nc);
					_outgoingStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);		
					_outgoingStream.client = this;
					
					_incomingStream  = new NetStream(_nc);
					_incomingStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);					
					_incomingStream.client = this;
					
					if(_userVO.name == "sparrowplayer")
					{
						super.publishStream();
					}
					else
					{
						super.playStream();
					}					
					
					super.dispatchEvt(StreamStatus.LIVE_STREAM);
					super.dispatchMetaData({w:_video.width, h:_video.height});
					break;
				case ConnectionStatus.REJECTED:
					super.dispatchLiveStatus('连接服务器被拒');
					break;
				case ConnectionStatus.CLOSED:
					super.dispatchLiveStatus('连接关闭');					
					break;
				default:
					break;
			}
		}
		
		override public function sendChatMsg(name:String, msg:String):void
		{
			var msgVO:MsgVO = new MsgVO();
			msgVO.type = ChatModuleEvtType.TO_ALL_MESSAGE;
			msgVO.content = name + "说：" + msg;
			msgVO.moduleID = ModuleID.CHAT;
	
			_nc.call('sendMessage', null, msgVO); 	//发送给服务器广播			
		}
	}
}