package com.xinguoedu.v.base
{
	import com.greensock.TweenLite;
	import com.xinguoedu.consts.ModuleID;
	import com.xinguoedu.consts.PlayerColor;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.ModuleEvt;
	import com.xinguoedu.evt.PlayerStateEvt;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.m.vo.MsgVO;
	import com.xinguoedu.utils.ShapeFactory;
	import com.xinguoedu.utils.StageReference;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	
	/**
	 * 可显示组件的基类 
	 * @author yatsen_yang
	 * 
	 */	
	public class BaseComponent extends Sprite
	{
		protected var _m:Model;
		/** 组件对应的皮肤 **/
		protected var _skin:MovieClip;		
		/** 关闭按钮 **/
		protected var _closeBtn:Sprite;
		private var _defaultShape:Shape;
		private var _overShape:Shape;
		/** 关闭按钮tweenlite对象的引用 **/
		private var _btnTween:TweenLite;
		/** 组件的tweenlite对象引用 **/
		protected var _compTween:TweenLite;
		/** 超时计时器 **/
		protected var _timeout:uint;
		protected var _dict:Dictionary = new Dictionary();
		/** 缓存数据的仓库 **/
		protected var _repo:Array;
		/** 提示信息 **/
		protected var _hint:TextField;
		
		public function BaseComponent(m:Model)
		{
			super();			
			this._m = m;		
			buildUI();
			registerCallback();
			addListeners();
		}
		
		protected function buildUI():void
		{
			this.visible = false;
		}
		
		protected function addListeners():void
		{
			StageReference.stage.addEventListener(Event.RESIZE, resizeHandler);
			EventBus.getInstance().addEventListener(PlayerStateEvt.PLAYER_STATE_CHANGE, playerStateChangeHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_COMPLETE, mediaCompleteHandler);
			EventBus.getInstance().addEventListener(ModuleEvt.INCOMING_MSG, moduleMsgHandler);
		}
		
		private function resizeHandler(evt:Event):void
		{
			resize();
		}
		
		/**
		 * 播放器状态处理函数 交给子类重写
		 * @param evt
		 * 
		 */		
		protected function playerStateChangeHandler(evt:PlayerStateEvt):void
		{
			
		}
		
		/**
		 * 视频播放完成处理函数 交给子类重写 
		 * @param evt
		 * 
		 */		
		protected function mediaCompleteHandler(evt:MediaEvt):void
		{
			
		}												
		
		protected function getSkinComponent(skin:MovieClip, compName:String):DisplayObject
		{
			return skin.getChildByName(compName);
		}
		
		/** 交给子类重写 **/
		protected function resize():void
		{
			
		}
		
		/**
		 * 舞台宽度
		 * @return 
		 * 
		 */		
		protected function get stageWidth():Number
		{
			return StageReference.stage.stageWidth;
		}
		
		/**
		 * 舞台高度
		 * @return 
		 * 
		 */		
		protected function get stageHeight():Number
		{
			return StageReference.stage.stageHeight;
		}
		
		protected function get controlbarHeight():Number
		{
			return _m.skin.controlbar.height;
		}
		
		/**
		 * StageDisplayState 
		 * @return 
		 * 
		 */		
		protected function get displayState():String
		{
			return StageReference.stage.displayState;
		}
		
		/**
		 * 画关闭按钮 
		 * @param showCircle 是否显示背景圆，默认显示
		 * 
		 */		
		protected function drawCloseBtn(showCircle:Boolean=true):void
		{
			_defaultShape = ShapeFactory.getShapeByColor(PlayerColor.MAIN_BG);
			_defaultShape.name = "default";
			
			_overShape = ShapeFactory.getShapeByColor(PlayerColor.MAIN_COLOR);
			_overShape.name = "over";
			
			_closeBtn = new Sprite();
			_closeBtn.mouseChildren = false;
			_closeBtn.buttonMode = true;
			_closeBtn.name = "close";
			_closeBtn.addChild(_overShape);
			_overShape.visible = false;
			_closeBtn.addChild(_defaultShape);			
			_closeBtn.addEventListener(MouseEvent.CLICK, clickCloseBtnHandler);	
			if(showCircle)
			{
				_closeBtn.filters = [new GlowFilter(PlayerColor.GLOW_FILTER_COLOR,1,8.0,8.0)];	
				_closeBtn.addEventListener(MouseEvent.MOUSE_OVER, overCloseBtnHandler);
				_closeBtn.addEventListener(MouseEvent.MOUSE_OUT, outCloseBtnHandler);
			}
			addChild(_closeBtn);
		}
		
		private function overCloseBtnHandler(evt:MouseEvent):void
		{
			evt.stopPropagation();
			_overShape.visible = true;		
			_defaultShape.visible = false;
			destroyBtnTween();			
			_btnTween = TweenLite.from(_overShape, 0.3,{rotation:-90}); //旋转效果			
		}
		
		private function outCloseBtnHandler(evt:MouseEvent):void
		{
			evt.stopPropagation();
			destroyBtnTween();			
			_overShape.visible = false;
			_defaultShape.visible = true;
		}
		
		protected function clickCloseBtnHandler(evt:MouseEvent):void
		{			
			evt.stopPropagation();
			hide();
		}
		
		/** 隐藏自己 **/
		protected function hide():void
		{
			destroyCompTween();
			destroyTimer();
			visible = false;			
		}
		
		private function destroyBtnTween():void
		{
			if(_btnTween != null)
			{
				TweenLite.killTweensOf(_btnTween, true);
				_btnTween = null;
				_overShape.rotation = 0;
			}
		}
		
		/** 清除组件缓动的引用 **/
		private function destroyCompTween():void
		{
			if(_compTween != null)
			{
				TweenLite.killTweensOf(_compTween, true);
				_compTween = null;
			}
		}
		
		/** 清除超时的计时器 **/
		protected function destroyTimer():void
		{
			if(_timeout)
			{
				clearTimeout(_timeout);
				_timeout = undefined;
			}		
		}
		
		protected function registerCallback():void
		{
			_dict[ModuleID.USER] = usrModuleHandler;
		}
		
		protected function usrModuleHandler(data:MsgVO):void
		{
			
		}		
		
		private function moduleMsgHandler(evt:ModuleEvt):void
		{
			if(_dict[evt.moduleID] is Function)
			{
				_dict[evt.moduleID](evt.data);
			}
		}	
		
	}
}