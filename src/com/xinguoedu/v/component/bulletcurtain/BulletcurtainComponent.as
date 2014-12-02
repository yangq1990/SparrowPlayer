package com.xinguoedu.v.component.bulletcurtain
{
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.js.JSEvt;
	import com.xinguoedu.evt.settings.SettingsEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.BulletFactory;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.events.Event;
	
	/**
	 * 弹幕组件 
	 * @author yangq1990
	 * 
	 */	
	public class BulletcurtainComponent extends BaseComponent
	{
		private static var _pool:Array = [];
		public static const SPEED:int = 8;
		
		public function BulletcurtainComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			this.visible = true;
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(JSEvt.BULLETCURTAIN, showBulletcurtain);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			EventBus.getInstance().addEventListener(SettingsEvt.SHOW_BULLETCURTAIN, settingEvtHandler);
			EventBus.getInstance().addEventListener(SettingsEvt.CLOSE_BULLETCURTAIN, settingEvtHandler);
		}
		
		private function showBulletcurtain(evt:JSEvt):void
		{
			if(!this.visible)
				return;
			
			var bullet:Bullet = BulletFactory.produce(evt.data);
			bullet.x = Math.random() * (this.width - bullet.width);
			bullet.y = this.height - controlbarHeight - bullet.height;
			this.addChild(bullet);
			_pool.push(bullet);			
		}
		
		private function enterFrameHandler(evt:Event):void
		{
			var len:int = _pool.length;
			if(len == 0)
			{
				BulletFactory.clear();
				return;
			}
			
			var bullet:Bullet;
			for(var i:int = len-1; i >= 0; i--)
			{
				bullet = _pool[i] as Bullet;
				bullet.y -= SPEED; 
				bullet.alpha -= 0.003;
				if(bullet.y <= -_pool[i].width)
				{
					bullet.parent && bullet.parent.removeChild(bullet);
					BulletFactory.reclaim(bullet, bullet.msg);
					_pool.splice(i, 1);
				}
			}
		}
		
		private function settingEvtHandler(evt:SettingsEvt):void
		{
			if(evt.type == SettingsEvt.SHOW_BULLETCURTAIN)
			{
				if(!this.visible)
				{
					this.visible = true;
					!hasEventListener(Event.ENTER_FRAME) && addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				}				
			}
			else if(evt.type == SettingsEvt.CLOSE_BULLETCURTAIN)
			{
				this.visible = false;
				hasEventListener(Event.ENTER_FRAME) && removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				BulletFactory.clear();
			}
		}
		
		override public function get width():Number
		{
			return stageWidth;
		}
		
		override public function get height():Number
		{
			return stageHeight - controlbarHeight;
		}
	}
}