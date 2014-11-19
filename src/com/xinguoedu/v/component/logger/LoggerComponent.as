package com.xinguoedu.v.component.logger
{
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.consts.PlayerColor;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.debug.DebugEvt;
	import com.xinguoedu.evt.view.ViewEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.v.base.BaseComponent;
	import com.xinguoedu.v.ui.Button;
	
	import flash.system.System;
	
	/**
	 * 日志组件
	 * @author yangq1990
	 * 
	 */	
	public class LoggerComponent extends BaseComponent
	{
		private var _playerLogger:PlayerLogger;
		private var _copyButton:Button;
		private var _closeButton:Button;
		private var _debugInfo:String = "";
		
		public function LoggerComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_playerLogger = new PlayerLogger(stageWidth, stageHeight, PlayerColor.MAIN_BG, 0.5, "left", Font.COLOR, Font.YAHEI, Font.SIZE);
			addChild(_playerLogger);
			
			_copyButton = new Button(70, 43, PlayerColor.MAIN_COLOR, 0.8);
			_copyButton.label = "复制信息";
			_copyButton.registerHandler(copyBtnClickHandler);
			addChild(_copyButton);
			
			_closeButton = new Button(70, 43, PlayerColor.MAIN_COLOR, 0.8);
			_closeButton.label = "关闭";
			_closeButton.registerHandler(closeBtnClickHandler);
			addChild(_closeButton);
			
			_copyButton.y = _closeButton.y = stageHeight - _closeButton.height - 100;
			_copyButton.x = (stageWidth - (_copyButton.width + _closeButton.width + 40) ) * 0.5;
			_closeButton.x = _copyButton.x + _copyButton.width + 40;
			
			super.buildUI();
		}
		
		private function copyBtnClickHandler():void
		{
			System.setClipboard(_playerLogger.log);
		}
		
		private function closeBtnClickHandler():void
		{
			visible = false;
			_playerLogger.hideLogger();
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(DebugEvt.DEBUG, debugHandler);
			EventBus.getInstance().addEventListener(ViewEvt.SHOW_LOGGER_COMPONENT, showLoggerHandler);
		}
		
		private function debugHandler(evt:DebugEvt):void
		{			
			_debugInfo = new Date().toString() + '->' + evt.info;
			_playerLogger.showLogger(_debugInfo);
		}
		
		private function showLoggerHandler(evt:ViewEvt):void
		{
			_playerLogger.showLogger(_debugInfo);
			visible = true;
			resize();
		}
		
		override protected function resize():void
		{
			if(visible)
			{
				this.x = (stageWidth - _playerLogger.width) >> 1;
				this.y = (stageHeight - _playerLogger.height) >> 1;
			}
		}		
	}
}