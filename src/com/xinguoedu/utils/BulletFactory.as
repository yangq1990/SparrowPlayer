package com.xinguoedu.utils
{
	import com.xinguoedu.v.component.bulletcurtain.Bullet;

	/**
	 * 弹幕元素的工厂方法
	 * @author yangq1990
	 * 
	 */	
	public class BulletFactory
	{
		private static var _pool:Array = [];
		
		public function BulletFactory()
		{
		}
		
		/**
		 * 生产Bullet对象 
		 * @param data {msg, from}
		 * @return 
		 * 
		 */		
		public static function produce(data:Object):Bullet
		{
			var bullet:Bullet;
			if(_pool.length == 0)
			{
				bullet = new Bullet(data.msg, data.from);
			}
			else
			{
				bullet = _pool.pop() as Bullet;
				bullet.reset(data.msg, data.from);
			}
			bullet.cacheAsBitmap = true;
			return bullet;
		}
		
		/**
		 * 回收Bullet对象 
		 * @param bullet
		 * 
		 */		
		public static function reclaim(bullet:Bullet):void
		{
			_pool.push(bullet);
		}
		
		/**
		 * 清空对象池 
		 * 
		 */		
		public static function clear():void
		{
			_pool = [];
		}
	}
}