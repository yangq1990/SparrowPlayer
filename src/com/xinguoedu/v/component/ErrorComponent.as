package com.xinguoedu.v.component
{
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.MultifunctionalLoader;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * 错误提示组件 
	 * @author yatsen_yang
	 * 
	 */	
	public class ErrorComponent extends BaseComponent
	{
		private var _errorIcon:MovieClip;
		private var _errorInfo:TextField;
		
		public function ErrorComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_errorInfo = new TextField();
			_errorInfo.defaultTextFormat = new TextFormat(Font.YAHEI, Font.SIZE, Font.COLOR);
			addChild(_errorInfo);
			
			var loader:MultifunctionalLoader = new MultifunctionalLoader();
			loader.registerFunctions(completeHandler);
			loader.load(_m.errorHintVO.url);
		}
		
		private function completeHandler(dp:DisplayObject):void
		{			
			_errorIcon = dp as MovieClip;
			_errorIcon.cacheAsBitmap = true;
			addChild(_errorIcon);
			
			this.visible = false;
		}
		
		override protected function addListeners():void
		{
			super.addListeners();		
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_ERROR, mediaErrorHandler);
		}
		
		private function mediaErrorHandler(evt:MediaEvt):void
		{
			_errorInfo.text = "无法播放视频，杯了个具";
			_errorInfo.width = _errorInfo.textWidth + 20;
			_errorInfo.height = _errorInfo.textHeight + 20;
			
			this.visible = true;
			
			resize();
		}
		
		override protected function resize():void
		{
			if(this.visible && _errorIcon != null)
			{
				_errorIcon.x = (stageWidth - _errorIcon.width) >> 1;
				_errorIcon.y = 100;
				
				_errorInfo.x = (stageWidth - _errorInfo.width) >> 1;
				_errorInfo.y = _errorIcon.y + _errorIcon.height + 10;
			}
		}
	}
}