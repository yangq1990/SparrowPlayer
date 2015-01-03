package com.xinguoedu.v.component.bulletcurtain
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Circ;
	import com.xinguoedu.consts.AboutBullet;
	import com.xinguoedu.consts.ModuleID;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.settings.SettingsEvt;
	import com.xinguoedu.evt.view.BulletEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.m.vo.MsgVO;
	import com.xinguoedu.utils.BulletFactory;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * 弹幕组件 
	 * @author yangq1990
	 * 
	 */	
	public class BulletcurtainComponent extends BaseComponent
	{
		/** 可显示弹幕信息的行数 **/
		private var _rows:int = 0;
		/**
		 * 存储每行是否可添加新字幕的开关
		 * key是每行的行号，从1到_rows
		 * value是 {on, endX} on的值0或1，1表示可以添加新字幕 0表示不可以; endX，是同行上一条字幕跨过临界线时的(x + width)
		 */		
		private var _rowOnOffDict:Dictionary;
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
			_repo = [];
			this.visible = true;		
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(BulletEvt.ADD_NEW_BULLET, addNewBulletHandler);
			
			EventBus.getInstance().addEventListener(SettingsEvt.SHOW_BULLETCURTAIN, settingEvtHandler);
			EventBus.getInstance().addEventListener(SettingsEvt.CLOSE_BULLETCURTAIN, settingEvtHandler);
			EventBus.getInstance().addEventListener(BulletEvt.CHAT_MSG_INCOMING, chatMsgIncomingHandler);
		}
		
		override protected function registerCallback():void
		{
			_dict[ModuleID.CHAT] = chatModuleHandler;
		}
		
		private function chatModuleHandler(data:MsgVO):void
		{
			var obj:Object = {};
			obj.msg = data.content;
			obj.from = AboutBullet.FROM_SOMEONE;
			showBulletcurtain(obj);
		}
		
		private function chatMsgIncomingHandler(evt:BulletEvt):void
		{
			showBulletcurtain(evt.data);
		}
		
		private function showBulletcurtain(data:Object):void
		{
			if(!this.visible)
				return;			
			
			var bullet:Bullet = BulletFactory.produce(data);	
			//栅格化显示区域，计算显示区域可以显示多少行弹幕信息
			(_rows == 0) && (_rows = Math.floor((this.height - bullet.height) / (bullet.height + AboutBullet.MARGIN)));
			
			if(_rowOnOffDict == null) //初始化
			{
				_rowOnOffDict = new Dictionary();
				for(var i:int = 1; i <= _rows; i++)
				{
					_rowOnOffDict[i] = {'on':1, 'endX':0};
				}
			}
			
			var saveToRepo:Boolean = true;
			for(var k:int=1; k <= _rows; k++)
			{
				if(_rowOnOffDict[k].on)
				{			
					saveToRepo = false;
					_rowOnOffDict[k].on = 0;
					addBulletToStage(bullet, k, _rowOnOffDict[k].endX);						
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
				if(!_rowOnOffDict[row].on)
				{
					scale = int(this.width / bullet.width) >= 2 ? 0.5 : 0.1;
					if(bullet.x < this.width*scale && !_bulletsOnStageArray[i].dispatched)
					{		
						var endX:Number = bullet.x + bullet.width;
						_bulletsOnStageArray[i].dispatched = true;
						_rowOnOffDict[row].on = 1;
						_rowOnOffDict[row].endX = endX;
						//如果_rowOnOffDict[_bulletsOnStageArray[i].row] = 1放到dispatchEvent下面
						//事件处理函数的执行在_rowOnOffDict[_bulletsOnStageArray[i].row] = 1之前
						dispatchEvent(new BulletEvt(BulletEvt.ADD_NEW_BULLET, {'row': row, 'endX':endX}));						
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
			
			var row:int = evt.data.row;
			if(_rowOnOffDict[row].on)
			{				
				_rowOnOffDict[row].on = 0;
				addBulletToStage(bullet, row, evt.data.endX);				
			}					
		}		
		
		/**
		 * 添加bullet到舞台 
		 * @param bullet
		 * @param row bullet要添加到的行
		 * 
		 */		
		private function addBulletToStage(bullet:DisplayObject, row:int, endX:Number=0):void
		{
			var scale:Number = int(this.width/bullet.width) >= 2 ? 0.5 : 1;
			if(endX == 0)
			{
				bullet.x = this.width*scale - bullet.width;
			}
			else
			{
				bullet.x = endX + 10;
			}
				
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