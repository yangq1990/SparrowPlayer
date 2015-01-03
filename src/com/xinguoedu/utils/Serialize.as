package com.xinguoedu.utils
{
	/**
	 * 数据处理类 
	 * @author YatSen
	 * 
	 */	
	public class Serialize
	{
		public function Serialize()
		{
		}
		
		public static function serialize(sourceObj:Object, resultObj:*):*
		{
			try
			{
				for (var item:* in sourceObj)
				{
					resultObj[item] = sourceObj[item];
				}
			}
			catch(err:Error)
			{
				Logger.error('Serialize', err.toString());
				resultObj = null;
			}		
			
			return resultObj;
		}
	}
}