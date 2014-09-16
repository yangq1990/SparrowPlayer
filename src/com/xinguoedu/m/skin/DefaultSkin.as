package com.xinguoedu.m.skin
{
	import cn.wecoding.utils.YatsenLog;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.core.MovieClipLoaderAsset;

	/**
	 * 播放器默认皮肤类 
	 * @author yatsen_yang
	 * 
	 */	
	public class DefaultSkin extends BaseSkin
	{
		[Embed(source="../assets/skin/skin.swf")]
		private var EmbeddedSkin:Class;
		
		public function DefaultSkin()
		{
			super();
		}
		
		override public function load():void 
		{
			var skinObj:MovieClipLoaderAsset = new EmbeddedSkin() as MovieClipLoaderAsset;
			var embeddedLoader:Loader = Loader(skinObj.getChildAt(0));
			embeddedLoader.contentLoaderInfo.addEventListener(Event.INIT, loadComplete);
			embeddedLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
		}
		
		protected function loadComplete(evt:Event):void 
		{
			try
			{
				var loader:LoaderInfo = LoaderInfo(evt.target);
				var skinClip:MovieClip = MovieClip(loader.content);
				overwriteSkin(skinClip.getChildByName('player'));
				loader.removeEventListener(Event.INIT, loadComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, loadError);
			}
			catch(err:Error)
			{
				YatsenLog.error('DefaultSkin', '获取皮肤内容出错', evt.toString());
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function loadError(evt:IOErrorEvent):void 
		{
			YatsenLog.error('DefaultSkin','加载默认皮肤出错', evt.toString());
		}
	}
}