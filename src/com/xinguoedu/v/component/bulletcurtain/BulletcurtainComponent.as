package com.xinguoedu.v.component.bulletcurtain
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Circ;
	import com.xinguoedu.consts.AboutBullet;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.js.JSEvt;
	import com.xinguoedu.evt.settings.SettingsEvt;
	import com.xinguoedu.evt.view.BulletEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.BulletFactory;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	 * 弹幕组件 
	 * @author yangq1990
	 * 
	 */	
	public class BulletcurtainComponent extends BaseComponent
	{
		/** 缓存弹幕的仓库，根据需要将信息显示到舞台上 **/
		private var _repo:Array = [];
		/** 可显示弹幕信息的行数 **/
		private var _rows:int = 0;
		/**
		 * 存储每行是否可添加新字幕的开关
		 * key是每行的行号，从1到_rows
		 * value是0或1，1表示可以添加新字幕 0表示不可以
		 */		
		private var _rowOnOffDict:Object;
		/**
		 * 记录舞台上弹幕信息的数组
		 * 元素数据结构 {dispatched:, bullet:, row:}
		 */		
		private var _bulletsOnStageArray:Array = [];
		
		
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
			this.addEventListener(BulletEvt.ADD_NEW_BULLET, addNewBulletHandler);
		}
		
		private function showBulletcurtain(evt:JSEvt):void
		{
			if(!this.visible)
				return;			
			
			var random:Number = Math.random();
			var bullet:Bullet = BulletFactory.produce(evt.data);
		
			//栅格化显示区域，计算显示区域可以显示多少行弹幕信息
			(_rows == 0) && (_rows = Math.floor((this.height - bullet.height) / (bullet.height + AboutBullet.MARGIN)));
			
			if(_rowOnOffDict == null) //初始化
			{
				_rowOnOffDict = {};
				for(var i:int = 1; i <= _rows; i++)
				{
					_rowOnOffDict[i] = 1;
				}
			}
			
			var saveToRepo:Boolean = true;
			for(var k:int=1; k <= _rows; k++)
			{
				if(_rowOnOffDict[k])
				{					
					saveToRepo = false;
					_rowOnOffDict[k] = 0;
					addBulletToStage(bullet, k);					
					break;
				}
			}			
			
			saveToRepo && _repo.push(bullet);
		}
		
		private function enterFrameHandler(evt:Event=null):void
		{
			var len:int = _bulletsOnStageArray.length;
			if(len == 0)
			{
				BulletFactory.clear();
				return;
			}
			
			var bullet:Bullet;
			var row:int;
			var scale:Number;
			for(var i:int = len-1; i >= 0; i--)
			{
				bullet = _bulletsOnStageArray[i].dp as Bullet;
				if(bullet == null)
					return;
				
				row = _bulletsOnStageArray[i].row;
				bullet.x -= AboutBullet.SPEED;					
				if(!_rowOnOffDict[row]) //!0为true
				{
					scale = int(this.width / bullet.width) >= 2 ? 0.5 : 0.1;
					if(bullet.x < this.width*scale && !_bulletsOnStageArray[i].dispatched)
					{			
						_bulletsOnStageArray[i].dispatched = true;
						_rowOnOffDict[row] = 1;
						//如果_rowOnOffDict[_bulletsOnStageArray[i].row] = 1放到dispatchEvent下面
						//事件处理函数的执行在_rowOnOffDict[_bulletsOnStageArray[i].row] = 1之前
						dispatchEvent(new BulletEvt(BulletEvt.ADD_NEW_BULLET, row));										
					}
				}
				
				if(bullet.x < -bullet.width) //bullet离开舞台，回收到对象池
				{
					bullet.parent && bullet.parent.removeChild(bullet);
					_bulletsOnStageArray.splice(i, 1);		
					BulletFactory.reclaim(bullet);	
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
		
		private function addNewBulletHandler(evt:BulletEvt):void
		{
			if(_repo.length == 0)
				return;
			
			var bullet:Bullet = _repo.shift() as Bullet;
			if(bullet == null)
				return;
			
			var row:int = evt.data;
			if(_rowOnOffDict[row])
			{				
				_rowOnOffDict[row] = 0;
				addBulletToStage(bullet, row);				
			}					
		}		
		
		/**
		 * 添加bullet到舞台 
		 * @param bullet
		 * @param row bullet要添加到的行
		 * 
		 */		
		private function addBulletToStage(bullet:DisplayObject, row:int):void
		{
			var scale:Number = int(this.width/bullet.width) >= 2 ? 0.7 : 1.08;
			bullet.x = this.width*scale - bullet.width;
			TweenLite.from(bullet, 0.3, 
				{
					x:this.width, 
					ease:Circ.easeOut
				});			
			_bulletsOnStageArray.push({dispatched:false, dp:bullet, row:row});
			bullet.y = AboutBullet.MARGIN * row + (row - 1) * bullet.height;
			addChild(bullet);
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