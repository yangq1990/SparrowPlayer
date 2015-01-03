package com.xinguoedu.v.component.live
{
	import com.greensock.TweenLite;
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.consts.PlayerColor;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.MultifunctionalLoader;
	import com.xinguoedu.utils.UIUtil;
	import com.xinguoedu.v.base.BaseComponent;
	import com.xinguoedu.v.ui.Button;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	/**
	 * 登录组件 
	 * @author yangq1990
	 * 
	 */	
	public class LoginComponent extends BaseComponent
	{
		private var _label:TextField;
		private var _input:TextField;
		private var _loginBtn:Button;
		private const MARGIN:int = 10;
		
		public function LoginComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill(PlayerColor.MAIN_BG, 0.5);
			g.drawRect(0, 0, stageWidth, stageHeight);
			g.endFill();
			
			super.buildUI();
		}
		
		override protected function addListeners():void
		{
			EventBus.getInstance().addEventListener(ViewEvt.SHOW_LOGIN_COMPONENT, showLoginComp);
			EventBus.getInstance().addEventListener(ViewEvt.REMOVE_LOGIN_COMPONENT, removeLoginComp);
		}
		
		private function showLoginComp(evt:ViewEvt):void
		{
			var loader:MultifunctionalLoader = new MultifunctionalLoader();
			loader.registerFunctions(loadGifComplete);
			loader.load('../assets/skin/gif.swf');			
		}
		
		private function removeLoginComp(evt:ViewEvt):void
		{
			this.parent && this.parent.removeChild(this);
		}
		
		private function loadGifComplete(dp:DisplayObject):void 
		{
			var w:Number = dp.width;
			var h:Number = dp.height;
			dp.x = (stageWidth - w) >> 1;
			dp.y = stageHeight * 0.5 - h;
			addChild(dp);		
			
			_label = new TextField();
			_label.defaultTextFormat = UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.SIZE); 
			_label.text = '请输入用户名: ';
			_label.y = dp.y + h + 20;
			addChild(_label);
			UIUtil.adjustTFWidthAndHeight(_label);			
			
			_input = new TextField();
			_input.background = true; //显示背景
			_input.backgroundColor = 0xffffff;
			_input.width = _label.width;
			_input.height = _label.height;
			_label.defaultTextFormat = UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.SIZE); 
			_input.type = TextFieldType.INPUT;
			_input.y = _label.y;
			addChild(_input);
			
			_loginBtn = new Button(80, 35, PlayerColor.MAIN_COLOR, 0.8);
			_loginBtn.label = "进入直播间";
			_loginBtn.y = _input.y - (_loginBtn.height - _input.height) * 0.5;
			_loginBtn.registerHandler(login);
			addChild(_loginBtn);
			
			var ttl:Number = _label.width + _input.width + _loginBtn.width + 20;
			_label.x = (stageWidth - ttl) >> 1;
			_input.x = _label.x + _label.width + 5;
			_loginBtn.x = _input.x + _input.width + 10;
			
			this.visible = true;
			
			TweenLite.from(this, 0.3, {alpha:0.3});
		}
  
		
		private function login():void
		{
			if(_input.text == "")
			{
				ExternalInterface.call('alert', "壮士，请留名!");
				return;
			}
			
			dispatchEvent(new ViewEvt(ViewEvt.ENTER_ROOM, _input.text));
		}
	}
}