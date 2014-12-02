package com.xinguoedu.v.component.settings
{
	import com.greensock.TweenLite;
	import com.xinguoedu.consts.PlayerColor;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.settings.SettingsEvt;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.Graphics;
	
	/**
	 * 设置面板组件 
	 * @author yangq1990
	 * 
	 */	
	public class SettingsComponent extends BaseComponent
	{
		/** 字幕选项 **/
		private var _subtitleItem:SettingItem;		
		/** 存储字幕选项Button Label的数组 **/
		private var _subtitleBtnLabelArray:Array = [
			{
				label:'显示',
				type: SettingsEvt.SHOW_SUBTITLE
			},
			{
				label:'关闭',
				type:SettingsEvt.CLOSE_SUBTITLE
			}
		];
		
		/** 弹幕选项 **/
		private var _bulletcurtainItem:SettingItem;
		private var _bulletcurtainBtnLabelArray:Array = [
			{
				label:'显示',
				type: SettingsEvt.SHOW_BULLETCURTAIN
			},
			{
				label:'关闭',
				type:SettingsEvt.CLOSE_BULLETCURTAIN
			}
		];
		
		/** 画面尺寸选项 **/
		private var _frameItem:SettingItem;
		private var _frameBtnLabelArray:Array = [
			{
				label:'均衡',
				type: SettingsEvt.UNIFORM
			},
			{
				label:'原尺寸',
				type:SettingsEvt.NONE
			},
			{
				label:'铺满',
				type:SettingsEvt.EXACTFIT
			},
			{
				label:'16:9',
				type:SettingsEvt.SIXTEEN_NINE
			}
		];
		
		public function SettingsComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			var g:Graphics = this.graphics;
			g.beginFill(PlayerColor.MAIN_BG, 0.8);
			g.drawRoundRect(0, 0, stageWidth*0.4, stageHeight*0.3, 10, 10);
			g.endFill();
			
			_subtitleItem = new SettingItem('字幕 : ', _subtitleBtnLabelArray);
			_subtitleItem.x = (this.width - _subtitleItem.width) * 0.1;
			_subtitleItem.y = 10;
			_subtitleItem.setEnabled(_subtitleBtnLabelArray[0].label);
			addChild(_subtitleItem);
			
			_bulletcurtainItem = new SettingItem('弹幕 : ', _bulletcurtainBtnLabelArray);
			_bulletcurtainItem.x = (this.width - _bulletcurtainItem.width) * 0.1;
			_bulletcurtainItem.y = _subtitleItem.y + _subtitleItem.height + 10;
			_bulletcurtainItem.setEnabled(_bulletcurtainBtnLabelArray[0].label);
			addChild(_bulletcurtainItem);
			
			_frameItem = new SettingItem('画面 : ', _frameBtnLabelArray);
			_frameItem.x  = _subtitleItem.x; 
			_frameItem.y = _bulletcurtainItem.y + _bulletcurtainItem.height + 10;
			_frameItem.setEnabled(_frameBtnLabelArray[0].label);
			addChild(_frameItem);
			
			drawCloseBtn();
			this.addChild(_closeBtn);	
			_closeBtn.x = stageWidth * 0.4;
			
			super.buildUI();
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(ViewEvt.SETTINGS_COMPONENT, settingsCompHandler);
		}
		
		private function settingsCompHandler(evt:ViewEvt):void
		{
			if(!visible)
			{
				this.visible = true;
				resize();
				TweenLite.from(this, 0.4, {alpha:0.1});
			}
			else
			{
				this.visible = false;
			}
		}
		
		override protected function resize():void
		{
			if(visible)
			{				
				this.x = (stageWidth - this.width) >> 1;
				this.y = (stageHeight - this.height) >> 1;
			}
		}
	}
}