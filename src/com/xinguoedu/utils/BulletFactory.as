package com.xinguoedu.utils
{
	import com.xinguoedu.v.component.bulletcurtain.Bullet;
	
	import flash.utils.Dictionary;

	/**
	 * 弹幕元素的工厂方法
	 * @author yangq1990
	 * 
	 */	
	public class BulletFactory
	{
		private static var _pool:Dictionary = new Dictionary();		
		
		public function BulletFactory()
		{
		}
		
		/**
		 * 生产Bullet对象 
		 * @param msg Bullet对象的msg
		 * @return 
		 * 
		 */		
		public static function produce(msg:String):Bullet
		{
			_pool[msg] == null && (_pool[msg] = []);
			var bullet:Bullet;
			trace('对象数量', _pool[msg].length);
			if(_pool[msg].length > 0)
			{
				bullet = _pool[msg].pop();
				bullet.msg = msg;
				bullet.alpha = 1;
			}
			else
			{
				bullet = new Bullet(msg);
				_pool[msg].push(bullet);
			}
			return bullet;
		}
		
		/**
		 * 回收Bullet对象 
		 * @param bullet
		 * @param msg
		 * 
		 */		
		public static function reclaim(bullet:Bullet, msg:String):void
		{
			_pool[msg] == null && (_pool[msg] = []);			
			if(_pool[msg].indexOf(bullet) == -1)
			{
				_pool[msg].push(bullet);
			}
		}
		
		/**
		 * 清空对象池 
		 * 
		 */		
		public static function clear():void
		{
			_pool = new Dictionary();
		}
	}
}