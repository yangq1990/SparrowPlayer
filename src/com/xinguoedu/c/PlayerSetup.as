package com.xinguoedu.c
{
	import cn.wecoding.utils.YatsenLog;
	
	import com.xinguoedu.m.Model;
	import com.xinguoedu.m.skin.BaseSkin;
	import com.xinguoedu.m.skin.DefaultSkin;
	import com.xinguoedu.utils.Configger;
	import com.xinguoedu.utils.JSONUtil;
	import com.xinguoedu.v.View;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * 为sparrow player准备需要的数据 
	 * @author yatsen_yang
	 * 
	 */	
	public class PlayerSetup extends EventDispatcher
	{
		private var _taskQueue:TaskQueue;
		private var _m:Model;
		private var _v:View;
		
		public function PlayerSetup(m:Model, v:View)
		{
			this._m = m;
			this._v = v;
		}
		
		public function setup():void
		{
			_taskQueue = new TaskQueue();
			_taskQueue.addEventListener(Event.COMPLETE, onTasksCompleteHandler);
			
			_taskQueue.queueTask(loadConfig, loadConfigComplete);
			_taskQueue.queueTask(loadSkin, loadSkinComplete);
			_taskQueue.queueTask(setupView);
			
			_taskQueue.runTasks();
			
		}
		
		private function loadConfig():void
		{
			var configger:Configger = new Configger();
			configger.addEventListener(Event.COMPLETE, _taskQueue.success);
			configger.loadConfig();
		}
		
		/** 加载配置信息complete **/
		private function loadConfigComplete(evt:Event):void
		{
			_m.playerconfig = (evt.target as Configger).config;
			
			//media
			_m.mediaVO.vid = _m.playerconfig.vid;
			_m.mediaVO.type = _m.playerconfig.type;
			_m.mediaVO.url = _m.playerconfig.url;
			//for encrypted video
			_m.mediaVO.omittedLength = _m.playerconfig.omittedLength;
			_m.mediaVO.seed = _m.playerconfig.seed;
			
			//videoad vo
			_m.videoadVO.enabled = int(_m.playerconfig.vads_enabled) ? true : false;
			//不使用默认的JSON包，因为在某些情况下，会出现ReferenceError
			_m.videoadVO.adsArray = (JSONUtil.decode(_m.playerconfig.videoads) as Array);			
			_m.videoadVO.btnurl = _m.playerconfig.learnmore;
			
			//ad
			_m.adVO.url = _m.playerconfig.adurl;
			_m.adVO.link = _m.playerconfig.adlink;
			
			//logo
			_m.logoVO.url = _m.playerconfig.logo.url; //这里应该是logo的url
			_m.logoVO.buttonMode = _m.playerconfig.logo.buttonMode;
			_m.logoVO.margin = _m.playerconfig.logo.margin;
			_m.logoVO.link = _m.playerconfig.logo.link;
			
			//error hint
			_m.errorHintVO.url = _m.playerconfig.errorHint.url;		
		}
		
		/** 加载皮肤 **/
		private function loadSkin():void
		{
			var sparrowSkin:BaseSkin = new DefaultSkin();
			sparrowSkin.addEventListener(Event.COMPLETE, _taskQueue.success);
			sparrowSkin.load();
		}
		
		/** 加载皮肤complete **/
		private function loadSkinComplete(evt:Event):void
		{
			_m.skin = (evt.target as DefaultSkin).skin;
		}
		
		private function setupView():void
		{
			try
			{
				_v.setup();				
			}
			catch(err:Error)
			{
				YatsenLog.error('PlayerSetup', 'setup view出错', err.toString());
			}
		
			_taskQueue.success();
		}
		
		/** 队列里所有任务都已完成 **/
		private function onTasksCompleteHandler(evt:Event):void
		{
			dispatchEvent(evt);
		}
	}
}