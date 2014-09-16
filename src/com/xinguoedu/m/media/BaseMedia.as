package com.xinguoedu.m.media
{
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.vo.MediaVO;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.clearInterval;

	/**
	 * 媒体基类 
	 * @author yatsen_yang
	 * 
	 */	
	public class BaseMedia extends EventDispatcher
	{
		protected var _display:Sprite;		
		protected var _mediaType:String;
		/** 流的当前位置 **/
		protected var _pos:Number;
		/** 视频时长 **/
		protected var _duration:Number;
		protected var _mediaVO:MediaVO;
		protected var _nc:NetConnection;
		protected var _stream:NetStream;
		/** video对象的引用 **/
		protected var _video:Video;
		/** 视频缓存到本地的比例 **/
		protected var _bufferPercent:Number;
		/** 流播放头位置定时器 **/
		protected var _posInterval:uint;
		/** Object with keyframe times and positions. **/
		protected var _keyframes:Object;
		/** 根据seek时间获取到的关键帧的timestamp **/
		protected var _kfTime:Number=0;
		/** 根据seek时间获取到的关键帧的fileposition **/
		protected var _kfFilePos:Number=0;
		/** 是否mp4文件 **/
		private var _mp4:Boolean;
		
		public function BaseMedia(mediaType:String)
		{
			this._mediaType = mediaType;
			
			_display = new Sprite();
		}
		
		public function init(mediaVO:MediaVO):void
		{
			_mediaVO = mediaVO;
		}
		
		/**
		 * 视频metadata处理函数 
		 * @param info
		 * 
		 */		
		public function onMetaData(info:Object):void
		{
			if (info['seekpoints']) 
			{
				_mp4 = true;
				_keyframes = convertSeekpoints(info['seekpoints']);
			}
			else
			{
				_mp4 = false;
				_keyframes = info['keyframes']; //记录关键帧的位置
			}
			
			_duration = info.duration;
			
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_METADATA, {w:info.width, h:info.height}));
		}
		
		protected function convertSeekpoints(dat:Object):Object 
		{
			var kfr:Object = {};
			kfr.times = [];
			kfr.filepositions = [];
			for (var j:String in dat)
			{
				kfr.times[j] = Number(dat[j]['time']);
				kfr.filepositions[j] = Number(dat[j]['offset']);
			}
			return kfr;
		}
		
		/**
		 * 获得离指定时间最近的关键帧的位置或者时间
		 * @param sec 指定的时间
		 * @param tme true获取时间，false获取位置
		 * @return 
		 * 
		 */		
		protected function getOffset(sec:Number, tme:Boolean=false):Number 
		{
			if (!_keyframes) 
			{
				return 0;
			}
			
			for (var i:Number = 0; i < _keyframes.times.length - 1; i++) 
			{
				if (_keyframes.times[i] <= sec && _keyframes.times[i + 1] >= sec) 
				{
					break;
				}
			}
			
			if(!tme)
			{
				return _keyframes.filepositions[i];
			}
			else
			{
				return _keyframes.times[i];
			}
		}
		
		public function get display():Sprite
		{
			return _display;
		}
		
		public function play():void
		{
			dispatchMediaStateEvt(PlayerState.PLAYING);
		}
		
		public function pause():void
		{
			dispatchMediaStateEvt(PlayerState.PAUSED);
		}
		
		/**
		 * 拖动视频 
		 * @param sec 拖动的秒数
		 * 
		 */		
		public function seek(sec:Number):void
		{
			if(_stream)
			{
				_stream.seek(sec);
			}
		}
		
		/**
		 * 设置视频的音量 
		 * @param volume 音量大小 0~100
		 * 
		 */		
		public function setVolume(volume:int):void
		{
			if(_stream != null && _stream.soundTransform.volume != volume / 100)
			{
				_stream.soundTransform = new SoundTransform(volume / 100);
			}
		}
		
		protected function dispatchEvt(type:String):void
		{
			dispatchEvent(new MediaEvt(MediaEvt.MEDIA_INFO, type));
		}
		
		
		protected function dispatchMediaStateEvt(state:String):void
		{
			dispatchEvent(new MediaEvt(MediaEvt.MEDIA_STATE, state));
		}
		
		protected function destroyPosTimer():void
		{
			if(_posInterval)
			{
				clearInterval(_posInterval);
				_posInterval = undefined;	
			}
		}
		
		/**
		 * 流状态处理函数，交给子类重写 
		 * @param evt
		 * 
		 */		
		protected function netStatusHandler(evt:NetStatusEvent):void
		{
			
		}
	}
}