package com.xinguoedu.m.media.httpm
{
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.consts.StreamStatus;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.evt.media.SegmentEvt;
	import com.xinguoedu.m.media.BaseMedia;
	import com.xinguoedu.m.vo.MediaVO;
	import com.xinguoedu.utils.Logger;
	
	import flash.net.NetConnection;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	/**
	 * 播放多段拼接起来的视频 
	 * @author yatsen_yang
	 * 
	 */	
	public class HttpMMedia extends BaseMedia
	{
		/** 分段视频总时长 **/
		private var _totalDuration:Number = 0;
		/** 当前分段的索引 **/		
		private var _currentIndex:int = 0;
		/** 存储分段对象引用的字典 **/
		private var _dict:Dictionary;
		
		public function HttpMMedia(mediaType:String)
		{
			super(mediaType);
		}
		
		override public function init(mediaVO:MediaVO):void
		{
			super.init(mediaVO);
			
			_nc = new NetConnection();
			_nc.connect(null);
			
			_dict = new Dictionary();			
			var len:int = mediaVO.urlArray.length;
			for(var i:int = 0; i < len; i++)
			{
				_dict[i] = new Segment(_nc, mediaVO.urlArray[i].url);
			}			
			addSegmentListeners(currentSegment);			
			
			super.getVideo();
			_video.attachNetStream(currentSegment.stream);			
			_display.addChild(_video);
			
			getTotalDuration();
			
			if(mediaVO.autostart)
			{
				currentSegment.isActive = true;
				currentSegment.load();	
			}
		}
		
		/** 为当前segment对象注册监听器 **/
		private function addSegmentListeners(segment:Segment):void
		{
			currentSegment.addEventListener(SegmentEvt.LOAD_SEGMENT, loadSegmentHandler);
			currentSegment.addEventListener(SegmentEvt.METADATA, segmentMetadataHandler);
			currentSegment.addEventListener(SegmentEvt.PLAY_START, segmentPlayStartHandler);
			currentSegment.addEventListener(SegmentEvt.LOAD_SEGMENT_IOERROR, loadSegmentIOErrorHandler);
			currentSegment.addEventListener(SegmentEvt.NET_STATUS, segmentNetStatusHandler);
			currentSegment.addEventListener(SegmentEvt.TIME, segmentTimeHandler);
			currentSegment.addEventListener(SegmentEvt.SWITCH, segmentSwitchHandler);
			currentSegment.addEventListener(SegmentEvt.PRELOAD_NEXT, preloadNextHandler);
			currentSegment.addEventListener(SegmentEvt.COMPLETE, segmentCompleteHandler);
		}
		
		/** 移除当前segment对象注册的监听器 **/
		private function removeSegmentListeners(segment:Segment):void
		{
			currentSegment.removeEventListener(SegmentEvt.LOAD_SEGMENT, loadSegmentHandler);
			currentSegment.removeEventListener(SegmentEvt.METADATA, segmentMetadataHandler);
			currentSegment.removeEventListener(SegmentEvt.PLAY_START, segmentPlayStartHandler);
			currentSegment.removeEventListener(SegmentEvt.LOAD_SEGMENT_IOERROR, loadSegmentIOErrorHandler);
			currentSegment.removeEventListener(SegmentEvt.NET_STATUS, segmentNetStatusHandler);
			currentSegment.removeEventListener(SegmentEvt.TIME, segmentTimeHandler);
			currentSegment.removeEventListener(SegmentEvt.SWITCH, segmentSwitchHandler);
			currentSegment.removeEventListener(SegmentEvt.PRELOAD_NEXT, preloadNextHandler);
			currentSegment.removeEventListener(SegmentEvt.COMPLETE, segmentCompleteHandler);
		}
		
		private function loadSegmentHandler(evt:SegmentEvt):void
		{
			dispatchEvt(StreamStatus.START_LOAD_MEDIA);
			currentSegment.setVolume(_volume);
		}
		
		private function segmentMetadataHandler(evt:SegmentEvt):void
		{
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_METADATA, evt.data));
		}
		
		/** 从play start到bull full， 视频处在加载状态 buffer full之后视频才开始真正播放 **/
		private function segmentPlayStartHandler(evt:SegmentEvt):void
		{
			dispatchMediaStateEvt(PlayerState.BUFFERING);
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_LOADING, {percent:evt.data/100}));
		}
		
		private function loadSegmentIOErrorHandler(evt:SegmentEvt):void
		{
			super.ioErrorHandler();
		}
		
		private function segmentNetStatusHandler(evt:SegmentEvt):void
		{
			dispatchEvt(evt.data);
		}
		
		private function segmentTimeHandler(evt:SegmentEvt):void
		{
			/** 
			 * position 播放头的位置,以秒为单位
			 * duration 视频总时长
			 * bufferDuration 视频缓存到本地的时长
			 * **/						
			var obj:Object =  {};
			obj.position = elapsedDuration + evt.data.position;
			obj.duration = _totalDuration;
			obj.bufferDuration = elapsedDuration + evt.data.bufferDuration;
			EventBus.getInstance().dispatchEvent(new MediaEvt(MediaEvt.MEDIA_TIME, obj));
			
			checkIsNearlyComplete(_totalDuration, obj.position);		
		}
		
		private function segmentSwitchHandler(evt:SegmentEvt):void
		{
			switchFrame();
		}
		
		private function preloadNextHandler(evt:SegmentEvt):void
		{
			Logger.info("HttpMMedia", _mediaVO.urlArray[_currentIndex].url + "即将播放完");
			if(_currentIndex >= _mediaVO.urlArray.length-1)
				return;
			
			var segment:Segment = _dict[_currentIndex+1] as Segment;
			segment.load();			
			Logger.info("HttpMMedia", _mediaVO.urlArray[_currentIndex+1].url + "开始后台加载");
		}
		
		private function segmentCompleteHandler(evt:SegmentEvt=null):void
		{
			currentSegment.destroy();
			removeSegmentListeners(currentSegment);
			
			if(_currentIndex >= _mediaVO.urlArray.length-1)
			{
				Logger.info("HttpMMedia", "all complete");
				_video.clear();
				_currentIndex = 0;
				currentSegment.isToSwitch = true;
				addSegmentListeners(currentSegment);
				_isComplete = true;
				dispatchEvt(StreamStatus.PLAY_COMPLETE);
			}
			else
			{
				_currentIndex += 1;
				addSegmentListeners(currentSegment);
				currentSegment.isActive = currentSegment.isToSwitch = true;
			}
		}
		
		/** video切换画面 **/
		private function switchFrame():void
		{
			//_video.attachNetStream(null); 可能有bug，所以就注释掉了
			_video.clear();
			
			//12ms后video attach 新的netstream,
			//这样做的目的是as3底层需要大概10ms来准备播放需要的context
			//如果video.clear()后直接attach, 可能会导致屏幕突然卡顿一下			
			setTimeout(function() {
				_video.attachNetStream(currentSegment.stream);
				currentSegment.setVolume(_volume);
			}, 12);			
		}
		
		
		/** 当前Segment对象的引用 **/
		private function get currentSegment():Segment
		{
			return _dict[_currentIndex] as Segment;
		}
		
		/** 获取分段视频的总时长 **/
		private function getTotalDuration():void
		{
			for each(var item:Object in _mediaVO.urlArray)
			{
				_totalDuration += item.duration;
			}
		}
		
		/** 获取当前视频之前的分段视频的总时长 **/
		private function get elapsedDuration():Number
		{
			var elapsedDuration:Number = 0;
			if(_currentIndex == 0)
				elapsedDuration = 0;
			else
			{
				for(var i:int = 0; i < _currentIndex; i++)
				{
					elapsedDuration += _mediaVO.urlArray[i].duration;
				}
			}
			return elapsedDuration;				
		}
		
		override public function play():void
		{			
			currentSegment.play();
			super.play();
		}
		
		override public function pause():void
		{
			currentSegment.pause();
			super.pause(); //防止出现netstatusHandler不被触发时导致无法暂停的问题
		}
		
		override public function mouseDownToSeek():void
		{
			currentSegment.mouseDownToSeek();
		}
		
		override public function seek(sec:Number):void
		{
			checkIsNearlyComplete(_totalDuration, sec, true);
			var index:int = findIndex(sec);
			if(index == _currentIndex)
			{
				currentSegment.seek(sec - elapsedDuration);
			}
			else
			{
				currentSegment.destroy();
				removeSegmentListeners(currentSegment);		
			
				_currentIndex = index;
				
				addSegmentListeners(currentSegment);	
				currentSegment.isActive = currentSegment.isToSwitch = true;
				currentSegment.load(sec - elapsedDuration);
			}		
		}
		
		/** 找到拖动的时间点所在分段的索引 **/
		private function findIndex(sec:Number):int
		{
			var result:int = 0;
			var nowIndex:int = _currentIndex;
			var now:Number = getSegmentsDuration(nowIndex);
			var len:int = _mediaVO.urlArray.length;
			
			if(sec >= now)
			{
				for(var i:int = nowIndex+1; i < len; i++)
				{
					if(sec <= getSegmentsDuration(i))
					{
						result = i;
						break;
					}
				}
			}
			else
			{
				for(var j:int = nowIndex; j>0; j--)
				{
					if(sec >= getSegmentsDuration(j-1))
					{
						result = j;
						break;
					}
				}
			}
			
			return result;
		}
		
		/**
		 * 获取从0到index共(index+1)个分段视频的时长之和 
		 * @param index
		 * @return 
		 * 
		 */		
		private function getSegmentsDuration(index:int):Number
		{
			var sum:Number = 0;
			for(var i:int=0; i <= index; i++)
			{
				sum += _mediaVO.urlArray[i].duration;
			}
			return sum;
		}
		
		/**
		 * 设置视频的音量 
		 * @param volume 音量大小 0~100
		 * 
		 */		
		override public function setVolume(volume:int):void
		{
			_volume = volume;
			currentSegment.setVolume(volume);
		}
	}
}