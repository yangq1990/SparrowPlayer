package com.xinguoedu.v.component.settings
{
	import com.greensock.TweenLite;
	import com.xinguoedu.consts.PlayerColor;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.settings.SubtitleEvt;
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
		private var _subtitleItem:SettingItem;		
		/** 存储字幕选项Button Label的数组 **/
		private var _subtitleBtnLabelArray:Array = [
			{
				label:'显示',
				type: SubtitleEvt.SHOW_SUBTITLE
			},
			{
				label:'关闭',
				type:SubtitleEvt.CLOSE_SUBTITLE
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
			g.drawRoundRect(0, 0, stageWidth*0.3, stageHeight*0.3, 10, 10);
			g.endFill();
			
			_subtitleItem = new SettingItem('字幕 : ', _subtitleBtnLabelArray);
			_subtitleItem.x = (this.width - _subtitleItem.width) >> 1;
			_subtitleItem.y = 10;
			_subtitleItem.setEnabled(_subtitleBtnLabelArray[0].label);
			addChild(_subtitleItem);
			
			drawCloseBtn();
			this.addChild(_closeBtn);	
			_closeBtn.x = stageWidth * 0.3;
			
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