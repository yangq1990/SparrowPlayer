package com.xinguoedu.v.component
{
	import com.xinguoedu.consts.Layout;
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.Logger;
	import com.xinguoedu.utils.MultifunctionalLoader;
	import com.xinguoedu.utils.Stretcher;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	/**
	 * 视频广告组件 
	 * @author yatsen_yang
	 * 
	 */	
	public class VideoAdsComponent extends BaseComponent
	{
		private var _container:Sprite;	
		private var _nc:NetConnection;
		private var _stream:NetStream;		
		private var _video:Video;
		/** 了解详情按钮 **/
		private var _learnmoreBtn:Sprite;
		/** 广告视频在数组里的索引 **/
		private var _index:int = 0;
		/** 当前视频的时长 **/
		private var _dur:Number = 0;
		/** 广告总时长 **/
		private var _totalDur:int = 0;
		/** Object with keyframe times and positions. **/
		private var _keyframes:Object;
		/** 是否mp4文件 **/
		private var _mp4:Boolean;		
		/** 剩余时间 **/
		private var _secText:TextField;
		/** 静音 **/
		private var _muteMC:MovieClip;
		/** 会员去广告 **/
		private var _noadMC:Sprite;
		/** 计时器 **/
		private var _interval:uint;
		/** **/
		private var _isPlaying:Boolean;
		private var _isSeeking:Boolean;
		private var _isSeeked:Boolean;
		/** 是否所有的广告视频都已播放完成 **/
		private var _isAllCompleted:Boolean;
		/** 视频是否在静音状态 **/
		private var _isMute:Boolean;
		/** 视频音量 **/
		private var _vol:Number;
		
		private var _timeBeforeSeeking:Number = 0;
		private var _timeWhenSeekComplete:Number = 0;
		
		
		public function VideoAdsComponent(m:Model)
		{
			super(m);		
		}
		
		override protected function buildUI():void
		{			
			_container = new Sprite();
			var g:Graphics = _container.graphics;
			g.beginFill(0x000000);
			g.drawRect(0, 0, stageWidth, stageHeight);
			g.endFill();
			addChild(_container);
			
			_video = new Video();
			_video.smoothing = true;
			addChild(_video);			
			
			_skin = _m.skin.videoad as MovieClip;
			_skin.x = stageWidth - _skin.width*0.5 - Layout.MARGIN_TO_STAGEBORDER;
			_skin.y = Layout.MARGIN_TO_STAGEBORDER + _skin.height * 0.5;
			addChild(_skin);
			
			_secText = _skin.secTip.secText as TextField;
			
			_muteMC = _skin.mute_mc as MovieClip;
			_muteMC.mouseChildren = false;
			_muteMC.buttonMode = true;
			_muteMC.addEventListener(MouseEvent.CLICK, mutemcClickHandler);
			
			_noadMC = _skin.noad_mc as MovieClip;
			_noadMC.mouseChildren = false;
			_noadMC.buttonMode = true;
			_noadMC.addEventListener(MouseEvent.CLICK, noadmcClickHandler);
			
			_learnmoreBtn = new Sprite();
			_learnmoreBtn.buttonMode = true;
			_learnmoreBtn.addEventListener(MouseEvent.CLICK, learnmoreHandler);		
			
			super.buildUI();
		}
		
		public function play():void
		{
			for each(var item:Object in (_m.videoadVO.adsArray))
			{
				_totalDur += item.duration;
			}
			_secText.text = (Math.ceil(_totalDur)).toString();
			_interval = setInterval(countdownHandler, NumberConst.COUNTDOWN_INTERVAL);
			
			var loader:MultifunctionalLoader = new MultifunctionalLoader();
			loader.registerFunctions(loadCompleteHandler);
			loader.load(_m.videoadVO.btnurl);
			
			_nc = new NetConnection();
			_nc.connect(null);
			
			_stream = getStream();		
			_stream.play(_m.videoadVO.adsArray[_index].url);			
			
			_video.attachNetStream(_stream);			
			
			this.visible = true;
		}
		
		private function loadCompleteHandler(dp:DisplayObject):void
		{
			_learnmoreBtn.addChild(dp);
			_learnmoreBtn.x = stageWidth - dp.width - Layout.MARGIN_TO_STAGEBORDER;
			_learnmoreBtn.y = stageHeight - dp.height - Layout.MARGIN_TO_STAGEBORDER;
			addChild(_learnmoreBtn); //添加到最上层
		}
		
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			_m.developermode && (Logger.error('VideoAdsComponent', '加载视频ioError', evt.toString()));
		}
		
		private function statusHandler(evt:NetStatusEvent):void
		{
			_m.developermode && (Logger.info('VideoAdsComponent', evt.info.code + '--' + _stream.time + '--' + _dur));
			switch(evt.info.code)
			{
				case StreamStatus.PLAY_START:
				case StreamStatus.BUFFER_FULL:
					_isPlaying = true;
					break;
				case StreamStatus.BUFFERING:
					_isPlaying = false;
					break;
				case StreamStatus.PLAY_STOP: 
					break;
				case StreamStatus.BUFFER_EMPTY://播放结束
					check();
					break;
				case StreamStatus.SEEK_COMPLETE:
					_timeWhenSeekComplete = _stream.time;
					_isSeeking = false;
					_isSeeked = true;
					break;
				default:
					break;
			}
		}
		
		public function onMetaData(info:Object):void
		{
			_video.width = info.width;
			_video.height = info.height;
			_dur = info.duration;
			Stretcher.stretch(_video, stageWidth, stageHeight);
		}
		
		private function convertSeekpoints(dat:Object):Object 
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
		 * @return 
		 * 
		 */		
		public function getOffset(sec:Number):Number 
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
			
			return _keyframes.times[i+1];
		}
		
		/**
		 *  Receive NetStream playback codes
		 *  
		 * */
		public function onPlayStatus(... rest):void 
		{
			for each (var dat:Object in rest) 
			{
				if (dat && dat.hasOwnProperty('code') && dat.code == "NetStream.Play.Complete") 
				{
					check();
				}
			}
		}	
		
		/** 检查视频是否播放完 **/
		private function check():void
		{
			if(_stream.time < _dur && (_dur - _stream.time) > 1) //播放过程中停止播放
			{
				_timeBeforeSeeking = _stream.time;
				_isSeeking = true;
				_stream.seek(_stream.time+1);
			}
			else
			{
				complete(); //播放完
			}
		}
		
		private function complete():void
		{
			_index += 1;
			if(_index >= _m.videoadVO.adsArray.length) //视频广告已播放完
			{
				_isAllCompleted = true;
				if(_totalDur > 1) //倒计时时间还没走完
					return;
				
				destroyAndDispatch();	
			}
			else
			{
				destroyOldStream();			
				
				//_stream指向新的NetStream对象
				_stream = getStream();				
				_stream.play(_m.videoadVO.adsArray[_index].url);
				_video.clear();
				_video.attachNetStream(_stream);
			}
		}
		
		/**  **/
		private function mutemcClickHandler(evt:MouseEvent):void
		{			
			if(_stream != null)
			{
				if(!_isMute)
				{
					_vol = _stream.soundTransform.volume;
					_stream.soundTransform = new SoundTransform(0);
					_isMute = true;
					_muteMC.gotoAndStop(2);
				}
				else
				{
					_stream.soundTransform = new SoundTransform(_vol);
					_isMute = false;
					_muteMC.gotoAndStop(1);
				}
			}
		}
		
		/** 会员去广告 **/
		private function noadmcClickHandler(evt:MouseEvent):void
		{
			
		}
		
		/** 跳到指定的链接 **/
		private function learnmoreHandler(evt:Event):void
		{
			navigateToURL(new URLRequest(_m.videoadVO.adsArray[_index].link));
		}
		
		/** 倒计时处理函数 **/
		private function countdownHandler():void
		{
			if(!_isAllCompleted)
			{
				if(!_isPlaying)
					return;
				
				if(_isSeeking)
					return;
				
				if(_isSeeked)
				{
					_totalDur -= Math.ceil(_timeWhenSeekComplete - _timeBeforeSeeking);
					_timeWhenSeekComplete = 0;
					_timeBeforeSeeking = 0;
					_isSeeked = false;
				}
				else
				{
					_totalDur -= 1;
				}
			}		
			else
			{
				_totalDur -= 1;
			}			
	
			(_totalDur <= 0) ? destroyAndDispatch() : (_secText.text = _totalDur.toString());			
		}
		
		/** 释放所占资源，并且派发视频广告播放完事件 **/
		private function destroyAndDispatch():void
		{
			if(_interval)
			{
				clearInterval(_interval);
				_interval = undefined;
			}
			
			//destroy skin
			_muteMC.removeEventListener(MouseEvent.CLICK, mutemcClickHandler);
			_noadMC.removeEventListener(MouseEvent.CLICK, noadmcClickHandler);
			removeChild(_skin);
			_skin = null;
			
			//destroy learnmore button
			_learnmoreBtn.removeEventListener(MouseEvent.CLICK, learnmoreHandler);
			removeChild(_learnmoreBtn);
			_learnmoreBtn = null;	
			
			//destroy stream
			destroyOldStream();			
			
			//destroy video
			_video.clear();
			_video.attachNetStream(null);
			removeChild(_video);
			_video = null;
			
			_nc = null;
			
			removeChild(_container);
			_container = null;			
			
			dispatchEvent(new ViewEvt(ViewEvt.VIDEOADS_COMPLETE));
		}
		
		/** 生成新的netstream **/
		private function getStream():NetStream
		{
			var stream:NetStream = new NetStream(_nc);
			stream.client = this;
			//bufferTime 指定在开始显示流之前需要多长时间将消息存入缓冲区。 
			//如果这个值设的小，会导致有些视频播放过程中派发NetStream.play.complete
			stream.bufferTime = 15;
			stream.addEventListener(NetStatusEvent.NET_STATUS,statusHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			return stream;
		}
		
		/** destroy old netstream **/
		private function destroyOldStream():void
		{
			if(_stream != null)
			{
				_stream.close();
				_stream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_stream.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
				_stream = null;
			}
		}
	}
}