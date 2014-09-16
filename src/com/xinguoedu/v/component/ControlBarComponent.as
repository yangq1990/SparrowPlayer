package com.xinguoedu.v.component
{
	import com.xinguoedu.consts.Layout;
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.PlayerStateEvt;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.Stacker;
	import com.xinguoedu.utils.StageReference;
	import com.xinguoedu.utils.Strings;
	import com.xinguoedu.v.base.BaseComponent;
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * 底部控制条组件
	 * @author yatsen_yang
	 * 
	 */	
	public class ControlBarComponent extends BaseComponent
	{
		private var _stacker:Stacker;
		private var BUTTONS:Object;
		/** Saving the block state of the controlbar. **/
		private var _blocking:Boolean;		
		/** 时间提示 **/
		private var _timeTip:MovieClip;
		/** 时间提示的tweenlite **/
		private var _tweenLite:TweenLite;
		/** 帮助提示 **/
		private var _helpTip:MovieClip;
		/** 总时间 **/
		private var _totalText:TextField;
		/** 已播放的时间 **/
		private var _elapsedText:TextField;		
		/** 视频时长 **/
		private var _dur:Number;
		/** 播放头位置 **/
		private var _pos:Number;		
		private var _pct:Number;
		/**  **/
		private var _scrubber:MovieClip;
		
		/** 拖动的位置 **/
		private var _draggingPos:Number;
		/** 是否在拖动volumeSlider **/
		private var _draggingVolumeSlider:Boolean = false;		
		/** controlbar tween **/
		private var _controlbarTween:TweenLite;
		/** 计时器  **/
		private var _timeout:uint;
		
		
		public function ControlBarComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			BUTTONS = {
					playButton:ViewEvt.PLAY,
					pauseButton: ViewEvt.PAUSE,
					nextButton: ViewEvt.NEXT,
					fullscreenButton: ViewEvt.FULLSCREEN,
					normalscreenButton: ViewEvt.NORMAL,
					settingButton: "",
					trumpet:ViewEvt.MUTE //喇叭mc
			};
			
			_skin = _m.skin.controlbar as MovieClip;	
			_stacker = new Stacker(_skin);
			_skin.x = _skin.y = 0;
			addChild(_skin);
			
			setTips();
			setTextField();
			setButtons();
			setSliders();
			stateHandler();		
			volumeHandler();
			
			resize();	
		
			_timeout = setTimeout(hideControlbar, NumberConst.DELAY);
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(PlayerStateEvt.PLAYER_STATE_CHANGE, playerStateChangeHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_TIME, timeHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_ERROR, mediaErrorHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_COMPLETE, mediaCompleteHandler);	
			StageReference.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			StageReference.stage.addEventListener(Event.MOUSE_LEAVE, mouseLeftStageHandler);
		}
		
		/** 提示，包括文字提示和时间提示 **/
		private function setTips():void
		{
			_timeTip = _skin.timeTip;
			_timeTip.cacheAsBitmap = true;
			_timeTip.visible = _timeTip.mouseChildren = _timeTip.mouseEnabled =_timeTip.buttonMode = false; 
			
			_helpTip = _skin.helpTip;
			_helpTip.visible = _helpTip.mouseChildren = _helpTip.mouseEnabled = _helpTip.buttonMode = false;			
		}	
		
		/** textfield **/
		private function setTextField():void
		{
			_totalText = _skin.totalText as TextField;
			_elapsedText = _skin.elapsedText as TextField;
		}
		
		/** Clickhandler for all buttons. **/
		private function setButtons():void 
		{
			var dispObj:DisplayObject;
			for (var btn:String in BUTTONS) 
			{
				dispObj = getSkinComponent(_skin, btn);
				if (dispObj) 
				{
					dispObj.addEventListener(MouseEvent.CLICK, clickHandler);
					dispObj.addEventListener(MouseEvent.MOUSE_OVER, overBtnHandler);
					dispObj.addEventListener(MouseEvent.MOUSE_OUT, outBtnHandler);
				}
			}
		}
		
		private function setSliders():void
		{
			timeSlider.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			timeSlider.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			timeSlider.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			timeSlider.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			timeSlider.mouseChildren = false;
			timeSlider.buttonMode = true;
			timeSlider.vline.visible = false; //hide vline
			
			volumeSlider.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			volumeSlider.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			volumeSlider.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			volumeSlider.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			volumeSlider.mouseChildren = false;
			volumeSlider.buttonMode = true;			
		}
		
		private function downHandler(evt:MouseEvent):void 
		{
			_scrubber = MovieClip(evt.target);				
			if (!_blocking) 
			{				
				var rct:Rectangle;
				if(_scrubber.name == 'timeSlider')
				{
					rct = new Rectangle(_scrubber.rail.x+_scrubber.icon.width*0.5, _scrubber.icon.y, _scrubber.rail.width - _scrubber.icon.width, 0);	
					_scrubber.done.width = evt.localX;					
				}
				else if(_scrubber.name == 'volumeSlider')
				{
					rct = new Rectangle(0, -_scrubber.icon.height*0.5, 0, -_scrubber.rail.height+_scrubber.icon.height);
					_scrubber.done.height = Math.abs(evt.localY);						
				}			
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, dragMovingHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
				_scrubber.icon.startDrag(true, rct);
				
			}
			else 
			{
				_scrubber = null;
			}
		}
		
		/** 拖动音量条或者时间进度条时实时反馈 **/
		private function dragMovingHandler(evt:MouseEvent):void
		{
			var pct:Number = 0;
			
			if(_scrubber.name == 'timeSlider')
			{				
				_scrubber.done.width = _scrubber.icon.x;
				pct = (_scrubber.icon.x - _scrubber.icon.width*0.5) / actualWidth * _dur;
				dispatchEvent(new ViewEvt(ViewEvt.TIME, pct));
			}				
			else if(_scrubber.name == 'volumeSlider')
			{
				_draggingVolumeSlider = true;
				_scrubber.done.height = Math.abs(_scrubber.icon.y);
				pct = int((Math.abs(_scrubber.icon.y) - _scrubber.icon.height*0.5) / actualHeight * 100);	
				_scrubber.volumeText.text = pct + "%";
				trumpetHandler(pct);
				//拖着icon移动的时候，没必要不停写入cookie，等mouseup的时候再写入
				dispatchEvent(new ViewEvt(ViewEvt.VOLUME, {'save2cookie':false, 'pct':pct}));				
			}
		
		}
		
		/** Handle mouse releases on sliders. **/
		private function upHandler(evt:MouseEvent):void 
		{
			_scrubber.icon.stopDrag();
			StageReference.stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			StageReference.stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragMovingHandler);	
			
			var pct:Number = 0;			
			if (_scrubber.name == 'timeSlider')
			{
				pct = (_scrubber.icon.x - _scrubber.icon.width*0.5) / actualWidth * _dur;
				_scrubber.done.width = _scrubber.icon.x;	
				_draggingPos = pct;
				dispatchEvent(new ViewEvt(ViewEvt.TIME, pct));
			}
			else if (_scrubber.name == 'volumeSlider') 
			{
				pct = int((Math.abs(_scrubber.icon.y) - _scrubber.icon.height*0.5) / actualHeight * 100);
				_scrubber.done.height = Math.abs(_scrubber.icon.y);
				_scrubber.volumeText.text = int(pct);
				trumpetHandler(pct);
				dispatchEvent(new ViewEvt(ViewEvt.VOLUME, {'save2cookie':true, 'pct':pct}));	
				_draggingVolumeSlider = false;
			}	
			
			_scrubber = null;
		}
		
		private function overHandler(evt:MouseEvent):void 
		{
			var slider:MovieClip = evt.currentTarget as MovieClip;
			if(slider.name != "timeSlider")
				return;		
			
			showTimeTip(this.mouseX);
			showVline(this.mouseX);		
		}
		
		private function outHandler(evt:MouseEvent):void 
		{
			var slider:MovieClip = evt.currentTarget as MovieClip;
			if(slider.name == "volumeSlider")
			{
				slider.visible = false;
				slider.removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
				return;
			}				
			
			timeSlider.vline.visible = _timeTip.visible = false;
			//kill动画
			TweenLite.killTweensOf(_timeTip, true);
			_tweenLite = null;
		}
		
		private function mouseMoveHandler(evt:MouseEvent):void
		{
			var slider:MovieClip = evt.target as MovieClip;
			if(slider.name != "timeSlider")
				return;		
			
			showTimeTip(this.mouseX);
			showVline(this.mouseX);			
		}
		
		/** 显示时间提示 **/
		private function showTimeTip(currentX:Number):void
		{
			_timeTip.x = currentX;
			_timeTip.scaleX = _timeTip.scaleY = _timeTip.alpha = 1;			
			_timeTip.y = stageHeight - _skin.height - _timeTip.height*0.5 - Layout.MARGIN_HINT_TO_CONTROLBAR;		
			
			if(_m.state == PlayerState.IDLE)
			{
				(_timeTip.time as TextField).text = "00:00";
			}
			else
			{				
				(_timeTip.time as TextField).text = Strings.digits((currentX - timeSlider.x) * _dur / timeSlider.rail.width);
			}
			
			//添加到stage
			!StageReference.stage.getChildByName("timeTip") && StageReference.stage.addChild(_timeTip);
			//动画显示
			_timeTip.visible = true;			
			!_tweenLite && (_tweenLite = TweenLite.from(_timeTip, 0.2, {scaleY:0.1, scaleX:0.1, alpha:0.1, y:_timeTip.y-50}));
		}

		/** 显示竖线vline,并且校准位置 **/
		private function showVline(mouseX:Number):void
		{
			timeSlider.vline.x = mouseX - timeSlider.x;
			timeSlider.vline.visible = true;
			if(timeSlider.vline.x >= (timeSlider.x + timeSlider.rail.width))
				timeSlider.vline.x = timeSlider.x + timeSlider.rail.width;
			else if(timeSlider.vline.x <= 0)
				timeSlider.vline.x = 0;
		}
		
		/** Handle clicks from all buttons. **/
		private function clickHandler(evt:MouseEvent):void
		{		
			//播放下一集
			if(evt.target.name == "nextButton")
			{
				//KuaijiJSModel.getInstance().playNext();
				//evt.stopImmediatePropagation();
				return;
			}
			
			//点击设置按钮
			if(evt.target.name == "settingButton")
			{
				//EventBus.getInstance().dispatchEvent(new GlobalEvent(GlobalEvent.SHOW_SETTING_VIEW));
				//evt.stopImmediatePropagation();	
				return;
			}			
			
			if(evt.target.name == "kuaijiLogoButto")
			{
				//navigateToURL(new URLRequest("http://video.kuaiji.com"));
				//evt.stopImmediatePropagation();
				return;
			}				
			
			var act:String = BUTTONS[evt.target.name];			
			var data:Object = null;
			if (!_blocking) 
			{
				if(ViewEvt.MUTE)
				{
					data = Boolean(!_m.playerconfig.mute);
				}

				dispatchEvent(new ViewEvt(act, data));
			}
		}
		
		/** 鼠标移到simplebutton上显示帮助提示 **/
		private function overBtnHandler(evt:MouseEvent):void
		{
			if(evt.target.parent.name == "trumpet")
			{
				StageReference.stage.addChild(volumeSlider);
				volumeSlider.x = evt.target.parent.x;
				volumeSlider.y = stageHeight - _skin.height;
				volumeSlider.visible = true;
				return;
			}
			
			var tf:TextField = _helpTip.help as TextField;
			switch(evt.target.name)
			{
				case "playButton":
					tf.text = "点击播放";
					break;
				case "pauseButton":
					tf.text = "点击暂停";
					break;
				case "nextButton":
					tf.text = "下一集";
					break;
				case "fullscreenButton":
					tf.text = "全屏观看";
					break;
				case "normalscreenButton":
					tf.text = "退出全屏";
					break;
				case "settingButton":
					tf.text = "设置";
					break;
				default:
					break;
			}
			
			_helpTip.x = evt.target.x;
			if(_helpTip.x + _helpTip.width * 0.5 >= stageWidth)
				_helpTip.x = stageWidth - _helpTip.width * 0.5;
			else if(_helpTip.x - _helpTip.width * 0.5 <= 0)
				_helpTip.x =_helpTip.width * 0.5;
			
			_helpTip.visible = true;
			_helpTip.y = stageHeight - _skin.height - _helpTip.height*0.5 - Layout.MARGIN_HINT_TO_CONTROLBAR;
			//添加到stage
			!StageReference.stage.getChildByName("helpTip") && StageReference.stage.addChild(_helpTip);			
		}
		
		private function moveHandler(evt:MouseEvent):void
		{
			if(_controlbarTween != null)
			{
				TweenLite.killTweensOf(_controlbarTween, true);
				_controlbarTween = null;
			}
			
			if(_timeout && _m.state != PlayerState.IDLE)
			{
				clearTimeout(_timeout);
				_timeout = setTimeout(hideControlbar, NumberConst.DELAY);
			}
			
			if(y != stageHeight - _skin.height)
			{
				y = stageHeight - _skin.height;
			}
			
			if(volumeSlider.visible && !_draggingVolumeSlider)
			{
				if((this.mouseY <= trumpet_mc.y + trumpet_mc.height*0.5)
					&& (trumpet_mc.x - trumpet_mc.width * 0.5 <= this.mouseX && this.mouseX <= trumpet_mc.x + trumpet_mc.width*0.5))
				{
					return;	
				}
				
				volumeSlider.visible = false;
			}
		}
		
		/** 鼠标离开simplebutton上隐藏帮助提示 **/
		private function outBtnHandler(evt:MouseEvent):void
		{
			_helpTip.visible = false;
		}
		
		override protected function resize():void
		{
			if(StageReference.stage.displayState == StageDisplayState.NORMAL)
			{
				_skin.fullscreenButton.visible = true;
				_skin.normalscreenButton.visible = false;
			}
			else if(StageReference.stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				_skin.fullscreenButton.visible = false;
				_skin.normalscreenButton.visible = true;
			}
		
			_stacker.rearrange(stageWidth);
			fixTime();
			
			_totalText.x = timeSlider.rail.x + timeSlider.rail.width - _totalText.textWidth;
			
			this.x = 0;
			this.y = stageHeight - _skin.height;
		}
		
		/** Fix the timeline display. **/
		private function fixTime():void 
		{
			var scp:Number = timeSlider.scaleX;
			timeSlider.scaleX = 1;
			//rail
			timeSlider.rail.width *= scp;
			//icon
			timeSlider.icon.x *= scp;
			//mark
			timeSlider.mark.x *= scp;
			timeSlider.mark.width *= scp;
			//done
			timeSlider.done.x *= scp;
			timeSlider.done.width *= scp;
			//hline
			timeSlider.hline.width *= scp;
		}
		
		private function stateHandler():void
		{
			switch(_m.state) 
			{
				case PlayerState.BUFFERING:
					bufferingPlayingHandler();					
					//_positionNodesInterval = setInterval(showTimelineNode, 100);					
					break;
				case PlayerState.PLAYING:
					bufferingPlayingHandler();
					
					/*if(_playbackTime)
					{
						dispatchTimeSeekEvent(_playbackTime);
						_playbackTime = undefined;	
					}*/
					
					break;
				case PlayerState.IDLE:
					timeSlider.done.width = 1;
					timeSlider.mark.width = 1;
					_skin.pauseButton.visible = false;
					_skin.playButton.visible = true;
					break;
				case PlayerState.PAUSED:
					_skin.playButton.visible = true;
					_skin.pauseButton.visible = false;
					break;
			}
		}
		
		/** buffering和playing状态下相同的处理函数 **/
		private function bufferingPlayingHandler():void
		{
			_skin.playButton.visible = false;
			_skin.pauseButton.visible = true;
		}
		
		private function playerStateChangeHandler(evt:PlayerStateEvt):void
		{
			stateHandler();
		}
		
		/** 
		 * evt.data 数据结构,为提高效率，事件直接派发，由controlbarComp接收处理
		 * position 播放头的位置,以秒为单位
		 * duration 视频时长
		 * bufferPercent 视频缓存到本地的比例
		 * 
		 * **/			
		private function timeHandler(evt:MediaEvt):void
		{
			if (evt) 
			{
				_dur = evt.data.duration;
				_pos = evt.data.position;
			}
			
			_dur <= 0 ? (_pct = 0) : (_pct = _pos/_dur);
			
			_totalText.text = Strings.digits(_dur);					
			_elapsedText.text = Strings.digits(_pos); 
			
			bufferHandler(evt); //mark的设置放到前面
			
			//这行代码的用意是这样子的，假如用户seek到20s(_draggingPos), 上一个关键帧的位置在18s
			//那视频是从18s(pos)开始播的，为了增加用户体验，避免给人一种seek不准确的感觉
			//在20s之前，icon一直不动，20s后才开始动，这就给人一种seek准确的感觉
			if(_pos <= _draggingPos)
				return;
			else
				_draggingPos = 0;
			
			//question answer
			/*if(_qaArray != null && _player.state != PlayerState.PAUSED)
			{
				var index:int = _qaArray.indexOf(int(pos)); 
				if(index != -1)
				{
					//index和qavo在qaArray里的索引保持同步
					EventBus.getInstance().dispatchEvent(new GlobalEvent(GlobalEvent.SHOW_QAVIEW, index));
					//暂停
					dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_PAUSE));
				}
				else
				{
					//拖动的时候，还有问题没有回答
					if(pos > _qaArray[0])
					{
						EventBus.getInstance().dispatchEvent(new GlobalEvent(GlobalEvent.SHOW_QAVIEW, 0));
						dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_PAUSE));
					}
				}		
			}*/
			
			
			var xps:Number = _pct * actualWidth;			
			if(xps + timeSlider.icon.width*0.5 >= timeSlider.rail.width)
			{
				timeSlider.icon.x = timeSlider.rail.width - timeSlider.icon.width*0.5;
			}
			else
			{
				timeSlider.icon.x = xps + timeSlider.icon.width*0.5;							
			}	
			
			timeSlider.done.width = timeSlider.icon.x;				
			timeSlider.done.visible = (_m.state != PlayerState.IDLE);
		}
		
		/** 设置timeSlider的mark **/
		private function bufferHandler(evt:MediaEvt):void 
		{			
			if (!evt || evt.data.bufferPercent < 0)
				return;
			
			timeSlider.mark.x = 0;
			if(_m.state == PlayerState.IDLE)
			{
				timeSlider.mark.width = 0;
				timeSlider.mark.visible = false;
			}
			else
			{
				timeSlider.mark.width = evt.data.bufferPercent * timeSlider.rail.width;
				timeSlider.mark.visible = true;
			}
		}
		
		/** Reflect the new volume in the controlbar **/
		private function volumeHandler(evt:MediaEvt=null):void 
		{
			if(evt == null)
			{	
				volumeSlider.done.height =  _m.volume * (volumeSlider.rail.height / 100);
				volumeSlider.icon.y = -volumeSlider.done.height;
				if(volumeSlider.icon.y >= -volumeSlider.icon.height * 0.5)
					volumeSlider.icon.y = -volumeSlider.icon.height * 0.5; //静音时也显示icon
				else if(volumeSlider.icon.y <= -(volumeSlider.rail.height - volumeSlider.icon.height * 0.5))
					volumeSlider.icon.y = -(volumeSlider.rail.height - volumeSlider.icon.height * 0.5);
			}	
			
			trumpetHandler();			
		}
		
		/**
		 * 不传参数或者传入-1, 用播放器记录的音量 
		 * @param vol
		 * 
		 */		
		private function trumpetHandler(vol:int=-1):void
		{
			var volume:int = 0;
			(vol < 0) ?  (volume = _m.volume) : (volume = vol);
		
			if(volume <= 100 && volume > 85)
			{
				trumpet_mc.gotoAndStop(4);
			}
			else if(volume <= 85 && volume >= 21)
			{
				trumpet_mc.gotoAndStop(3);
			}
			else if(volume < 21  && volume >= 1 )
			{
				trumpet_mc.gotoAndStop(2);
			}
			else if(volume <= 0)
			{
				trumpet_mc.gotoAndStop(1);
			}
			
			(volumeSlider.volumeText as TextField).text = volume + "%";
		}
		
		private function mouseLeftStageHandler(evt:Event):void
		{
			if(_timeout)
			{
				clearTimeout(_timeout);
				_timeout = setTimeout(hideControlbar, NumberConst.DELAY);
			}
		}
		
		private function hideControlbar():void
		{
			_controlbarTween = TweenLite.to(this, 0.5, {y:stageHeight});
		}
		
		private function mediaCompleteHandler(evt:MediaEvt):void
		{
			timeSlider.icon.x = timeSlider.icon.width * 0.5;
			timeSlider.done.width = timeSlider.mark.width = 1;
		}
		
		/** 时间进度条实际的宽度，要减去icon所占的宽度 **/
		private function get actualWidth():Number
		{
			return timeSlider.rail.width - timeSlider.icon.width;
		}
		
		/** 音量条实际的高度，减去icon所占的高度 **/
		private function get actualHeight():Number
		{
			return volumeSlider.rail.height - volumeSlider.icon.height;
		}
		
		private function mediaErrorHandler(evt:MediaEvt):void
		{
			_blocking = true;
		}
		
		private function get timeSlider():MovieClip
		{
			return _skin.timeSlider;
		}
		
		private function get volumeSlider():MovieClip
		{
			return _m.skin.volumeSlider;
		}
		
		private function get trumpet_mc():MovieClip
		{
			return _skin.trumpet;
		}
		
		override public function get height():Number
		{
			return _skin.height;
		}
		
	}
}