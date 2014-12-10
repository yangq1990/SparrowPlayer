package com.xinguoedu.v.component
{
	import com.greensock.TweenLite;
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
	import com.xinguoedu.v.node.Node;
	import com.xinguoedu.v.node.NodeHintSpt;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
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
		/** 拖动的mc **/
		private var _scrubber:MovieClip;		
		/** 拖动的位置 **/
		private var _draggingPos:Number;
		/** 是否在拖动volumeSlider **/
		private var _draggingVolumeSlider:Boolean = false;	
		/** identify mouseover controlbar **/
		private var _isMouseOverControlbar:Boolean;
		/** identify mouseover volumeSlider **/
		private var _isMouseOverVolumeSlider:Boolean;		
		/** volumeslider icon y坐标**/
		private var _iconY:Number;
		/** 节点是否已放置好 **/
		private var _isNodePlaced:Boolean;
		/** 放置节点时用的定时器，因为buffering的时候不一定能取到视频的长度，所以需要定时去查询	 **/
		private var _positionNodesInterval:uint;
		/** 显示节点信息的spt **/
		private var _nodeHintSpt:NodeHintSpt;
		
		public function ControlBarComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			this.focusRect = false;
			BUTTONS = {
					playButton:ViewEvt.PLAY,
					pauseButton: ViewEvt.PAUSE,
					nextButton: ViewEvt.PLAY_NEXT,
					fullscreenButton: ViewEvt.FULLSCREEN,
					normalscreenButton: ViewEvt.NORMAL,
					settingButton: ViewEvt.SETTINGS_COMPONENT,
					trumpet:ViewEvt.MUTE //喇叭mc
			};
			
			_skin = _m.skin.controlbar as MovieClip;	
			_stacker = new Stacker(_skin);
			_skin.x = _skin.y = 0;
			addChild(_skin);
			
			setTips();
			setTextField();
			setButtons();
			stateHandler();		
			setSliders();			
			volumeHandler();
			
			_nodeHintSpt = new NodeHintSpt();
			_nodeHintSpt.visible = false;
			!_positionNodesInterval && (_positionNodesInterval = setInterval(showTimelineNode, 500));
			
			resize();		
		
			if(_m.autohide || _m.isFullScreen)
			{
				_timeout = setTimeout(hideControlbar, NumberConst.DELAY);
			}				
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_TIME, timeHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_ERROR, mediaErrorHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_MUTE, mediaMuteHandler);
			StageReference.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			StageReference.stage.addEventListener(Event.MOUSE_LEAVE, mouseLeftStageHandler);
			StageReference.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			StageReference.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverControlbarHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutControlbarHandler);			
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
					if(_m.state == PlayerState.IDLE)
						return;
					
					rct = new Rectangle(_scrubber.rail.x+_scrubber.icon.width*0.5, _scrubber.icon.y, _scrubber.rail.width - _scrubber.icon.width, 0);	
					_scrubber.mark.width = _scrubber.done.width = evt.localX;		
					dispatchEvent(new ViewEvt(ViewEvt.MOUSEDOWN_TO_SEEK));
				}
				else if(_scrubber.name == 'volumeSlider')
				{
					rct = new Rectangle(0, -_scrubber.icon.height*0.5, 0, -_scrubber.rail.height+_scrubber.icon.height);
					_scrubber.done.height = Math.abs(evt.localY);						
				}			
				
				StageReference.stage.addEventListener(MouseEvent.MOUSE_MOVE, dragMovingHandler);
				StageReference.stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
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
				_scrubber.mark.width = _scrubber.done.width = _scrubber.icon.x;
				pct = (_scrubber.icon.x - _scrubber.icon.width*0.5) / actualWidth * _dur;
				dispatchEvent(new ViewEvt(ViewEvt.DRAG_TIMESLIDER_MOVING, pct));
			}				
			else if(_scrubber.name == 'volumeSlider')
			{
				_draggingVolumeSlider = true;
				pct = int((Math.abs(_scrubber.icon.y) - _scrubber.icon.height*0.5) / actualHeight * 100);					
				volumeChangeHandler(_scrubber.icon.y, pct,false);
			}		
		}
		
		/** Handle mouse releases on sliders. **/
		private function upHandler(evt:MouseEvent):void 
		{
			if(_scrubber != null)
			{
				_scrubber.icon.stopDrag();
				StageReference.stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
				StageReference.stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragMovingHandler);
			}				
			
			var pct:Number = 0;			
			if (_scrubber.name == 'timeSlider')
			{
				pct = (_scrubber.icon.x - _scrubber.icon.width*0.5) / actualWidth * _dur;
				_scrubber.mark.width = _scrubber.done.width = _scrubber.icon.x;	
				_draggingPos = pct;
				dispatchEvent(new ViewEvt(ViewEvt.SEEK, pct));
			}
			else if (_scrubber.name == 'volumeSlider') 
			{
				pct = int((Math.abs(_scrubber.icon.y) - _scrubber.icon.height*0.5) / actualHeight * 100);				
				volumeChangeHandler(_scrubber.icon.y, pct, true);
				_draggingVolumeSlider = false;
			}	
			
			_scrubber = null;
		}
		
		private function overHandler(evt:MouseEvent):void 
		{
			var slider:MovieClip = evt.currentTarget as MovieClip;
			if(slider.name == "volumeSlider")
			{
				_isMouseOverVolumeSlider = true;
				return;		
			}				
			
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
			var name:String = evt.currentTarget.name;
			//点击设置按钮
			if(name == "settingButton")
			{
				EventBus.getInstance().dispatchEvent(new ViewEvt(BUTTONS[evt.currentTarget.name]));
				evt.stopImmediatePropagation();	
				return;
			}			
			
			if(name == "kuaijiLogoButto")
			{
				//navigateToURL(new URLRequest("http://video.kuaiji.com"));
				//evt.stopImmediatePropagation();
				return;
			}				
			
			var act:String = BUTTONS[name];			
			var data:Object = null;
			if (!_blocking) 
			{
				if(act == ViewEvt.MUTE)
				{
					data = Boolean(!_m.isMute);
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
				
				if(stage.focus == null || stage.focus is SimpleButton) //修复鼠标over trumpt时监听不到键盘事件的bug
				{
					stage.focus = this;
				}
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
			Mouse.show();
			if(_m.autohide || _m.isFullScreen)
			{				
				if(_compTween != null)
				{
					TweenLite.killTweensOf(_compTween, true);
					_compTween = null;
				}
				
				if(_timeout && _m.state != PlayerState.IDLE)
				{
					clearTimeout(_timeout);
				}
				_timeout = setTimeout(hideControlbar, NumberConst.DELAY);
				
				if(y != stageHeight - _skin.height)
				{
					y = stageHeight - _skin.height;
					EventBus.getInstance().dispatchEvent(new ViewEvt(ViewEvt.SHOW_CONTROLBAR));
				}
			}			
			
			if(volumeSlider.visible && !_draggingVolumeSlider)
			{
				if((this.mouseY <= trumpet_mc.y + trumpet_mc.height*0.5)
					&& (trumpet_mc.x - trumpet_mc.width * 0.5 <= this.mouseX && this.mouseX <= trumpet_mc.x + trumpet_mc.width*0.5))
				{
					return;	
				}
				
				volumeSlider.visible = false;
				_isMouseOverVolumeSlider = false;
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
			//fixTime();
			
			_totalText.x = timeSlider.x + timeSlider.rail.width - _totalText.width;
			
			this.x = 0;
			this.y = stageHeight - _skin.height;
			
			replaceNodes();
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
				case PlayerState.PLAYING:
					pausePlayBtnVisibleHandler(true);		
					break;
				case PlayerState.IDLE:
					timeSlider.done.width = 1;
					timeSlider.mark.width = 1;
					pausePlayBtnVisibleHandler(false);		
					break;
				case PlayerState.PAUSED:
					pausePlayBtnVisibleHandler(false);		
					break;
			}
		}
		
		/** 显示时间线节点 **/
		private function showTimelineNode():void
		{
			if(!_isNodePlaced)
			{
				if(_m.nodeVO.nodeArray == null || _m.nodeVO.nodeArray.length == 0) //没有节点
					return;
				
				var ratio:Number = widthDurationScale;
				if(!ratio)
					return;
				
				var length:int = _m.nodeVO.nodeArray.length;			
				var node:Node; 
				for(var i:int=0; i < length; i++)
				{
					node = new Node(_m.nodeVO.nodeArray[i]);
					node.x = _m.nodeVO.nodeArray[i].time * ratio + timeSlider.x;
					node.y = timeSlider.y;
					node.mouseChildren = false;
					node.buttonMode = true;
					node.addEventListener(MouseEvent.MOUSE_OVER, mouseOverNodeHandler);
					node.addEventListener(MouseEvent.MOUSE_OUT, mouseOutNodeHandler);
					node.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownNodeHandler);
					_skin.addChild(node);
				}
				
				_isNodePlaced = true;
			}	
			else
			{
				if(_positionNodesInterval)
				{
					clearInterval(_positionNodesInterval);
					_positionNodesInterval = undefined;
				}
			}
		}
		
		/** 鼠标over到node上，显示提示文字 **/
		private function mouseOverNodeHandler(evt:MouseEvent):void
		{
			evt.stopPropagation();
			if(_nodeHintSpt && !_nodeHintSpt.visible)
			{	
				var node:Node = evt.currentTarget as Node;				
				_nodeHintSpt.hint= node.hint;
				_nodeHintSpt.x = node.x - _nodeHintSpt.width * 0.5;				
				_nodeHintSpt.y = StageReference.stage.stageHeight - _skin.height - _nodeHintSpt.height - 2;
				StageReference.stage.addChild(_nodeHintSpt);
				_nodeHintSpt.visible = true;
			}
		}
		
		private function mouseOutNodeHandler(evt:MouseEvent):void
		{
			(_nodeHintSpt != null) && (_nodeHintSpt.visible = false);			
		}
		
		private function mouseDownNodeHandler(evt:MouseEvent):void
		{
			timeSlider.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));	
		}
		
		/** 界面resize的时候，重新计算node位置 **/
		private function replaceNodes():void
		{
			var ratio:Number = widthDurationScale;
			if(!ratio)
				return;
			
			var num:int = _skin.numChildren;
			var child:DisplayObject;
			for(var i:int = 0; i < num; i++)
			{
				child = _skin.getChildAt(i);
				(child is Node) && (child.x = Node(child).time * ratio + timeSlider.x);
			}
		}
		
		override protected function playerStateChangeHandler(evt:PlayerStateEvt):void
		{
			stateHandler();
		}
		
		/** 
		 * evt.data 数据结构,为提高效率，事件直接在BaseMedia的子类中派发，由controlbarComp接收处理
		 * position 播放头的位置,以秒为单位
		 * duration 视频总时长
		 * bufferDuration 视频缓存到本地的时长
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
			
			bufferHandler(evt);
			
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
			if (!evt)
				return;
		
			timeSlider.mark.x = 0;
			if(_m.state == PlayerState.IDLE)
			{
				timeSlider.mark.width = 0;
				timeSlider.mark.visible = false;
			}
			else
			{
				timeSlider.mark.width = evt.data.bufferDuration * widthDurationScale;
				timeSlider.mark.visible = true;
			}
		}
		
		/** 每秒对应的宽度 **/
		private function get widthDurationScale():Number
		{
			return timeSlider.rail.width / _dur;
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
				
				_iconY = volumeSlider.icon.y;
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
			if(!_m.autohide && !_m.isFullScreen)
				return;
			
			if(_timeout)
			{
				clearTimeout(_timeout);
				_timeout = setTimeout(hideControlbar, NumberConst.DELAY);
			}
		}
		
		private function keyDownHandler(evt:KeyboardEvent):void
		{
			switch(evt.keyCode)
			{
				case Keyboard.SPACE:
					dispatchEvent(new ViewEvt(ViewEvt.KEYDOWN_SPACE));
					break;
				case Keyboard.UP: //向上调节音量
					keydownVolumeHandler('+');					
					break;
				case Keyboard.DOWN: //向下调节音量
					keydownVolumeHandler('-');
					break;
				/*case Keyboard.LEFT: //快退	
					keydownTimeHandler('-');
					break;
				case Keyboard.RIGHT: //快进
					keydownTimeHandler('+');
					break;*/
				default:
					break;
					
			}
		}
		
		private function keyUpHandler(evt:KeyboardEvent):void
		{
			switch(evt.keyCode)
			{
				case Keyboard.UP: //向上调节音量
					keydownVolumeHandler('+', true);					
					break;
				case Keyboard.DOWN: //向下调节音量
					keydownVolumeHandler('-', true);
					break;
			}
		}
		
		/** 鼠标over controlbar **/
		private function mouseOverControlbarHandler(evt:MouseEvent):void
		{
			_isMouseOverControlbar = true;
		}
		
		/** 鼠标out controlbar **/
		private function mouseOutControlbarHandler(evt:MouseEvent):void
		{
			_isMouseOverControlbar = false;
		}
		
		/**
		 * 处理键盘按下音量的加减 
		 * @param operator
		 * @param save2Cookie 是否立即将音量值写入cookie
		 * + 表示增加音量
		 * - 表示减小音量
		 */		
		private function keydownVolumeHandler(operator:String, save2Cookie:Boolean=false):void
		{
			if(!save2Cookie) //key up时不需要继续调整icon位置
			{
				var pct:int = 0;
				if(operator == '+')
				{
					volumeSlider.icon.y -= NumberConst.VOLUME_STEP_SIZE;				
					if(volumeSlider.icon.y <= -volumeSlider.rail.height + volumeSlider.icon.height*0.5)
						volumeSlider.icon.y = -volumeSlider.rail.height + volumeSlider.icon.height*0.5;
				}
				else if(operator == '-')
				{
					volumeSlider.icon.y += NumberConst.VOLUME_STEP_SIZE;
					if(volumeSlider.icon.y >= -volumeSlider.icon.height*0.5)
						volumeSlider.icon.x = -volumeSlider.icon.height*0.5;
				}					
			}
			pct = int((Math.abs(volumeSlider.icon.y) - volumeSlider.icon.height*0.5)  / actualHeight * 100);
			volumeChangeHandler(volumeSlider.icon.y, pct, save2Cookie);
		}
		
		
		/**
		 * 音量发生改变后的处理函数
		 * @param iconY icon的y坐标
		 * @param pct 音量值
		 * @param save2cookie 是否立即写入cookie
		 * 
		 */		
		private function volumeChangeHandler(iconY:Number, pct:int, save2cookie:Boolean):void
		{
			_iconY = iconY;
			volumeSlider.done.height = Math.abs(iconY);
			trumpetHandler(pct);
			dispatchEvent(new ViewEvt(ViewEvt.VOLUME, {'save2cookie':save2cookie, 'pct':pct}));	
		}
		
		
		private function hideControlbar():void
		{
			if(_m.state == PlayerState.PAUSED)
				return;
			
			if(!_m.autohide && !_m.isFullScreen)
				return;
			
			if(!_isMouseOverControlbar && !_isMouseOverVolumeSlider)
			{
				Mouse.hide();
				EventBus.getInstance().dispatchEvent(new ViewEvt(ViewEvt.HIDE_CONTROLBAR));
				_compTween = TweenLite.to(this, 0.5, {y:stageHeight});
			}
		}
		
		/** 视频播放完 **/
		override protected function mediaCompleteHandler(evt:MediaEvt):void
		{
			timeSlider.icon.x = timeSlider.icon.width * 0.5;
			timeSlider.done.width = timeSlider.mark.width = 1;
			_elapsedText.text = Strings.digits(0); 
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
		
		/** 播放器静音状态改变处理函数 **/
		private function mediaMuteHandler(evt:MediaEvt):void
		{
			if(_m.isMute)
			{
				trumpetHandler(0);
				volumeSlider.icon.y = -volumeSlider.icon.height*0.5;
				volumeSlider.done.height = 0;
			}
			else
			{
				volumeSlider.icon.y = _iconY;
				volumeSlider.done.height = Math.abs(_iconY);;
				trumpetHandler(_m.volume);
			}
		}		
		
		/**
		 * 处理播放暂停显示的函数 
		 * @param pauseBtnVisible 是否显示暂停按钮
		 * 
		 */		
		private function pausePlayBtnVisibleHandler(pauseBtnVisible:Boolean=true):void
		{
			pauseBtnVisible ? (_skin.pauseButton.visible = true) : _skin.pauseButton.visible = false;
			_skin.playButton.visible = !_skin.pauseButton.visible;
		}
	}
}