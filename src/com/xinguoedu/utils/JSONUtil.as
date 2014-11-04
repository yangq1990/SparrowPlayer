package com.xinguoedu.utils
{
	import com.adobe.serialization.json.JSONDecoder;

	/**
	 * 封装了JSON解包的工具类 
	 * @author yatsen_yang
	 * 
	 */	
	public class JSONUtil
	{
		public function JSONUtil()
		{
		}
		
		/**
		 * 解密JSON encode的返回结果 
		 * @param result
		 * @return 
		 * 
		 */		
		public static function decode(result:*):*
		{
			var result:*;
			try
			{
				result = (new JSONDecoder(result, true)).getValue();
			}
			catch(err:Error)
			{
				trace("json string error");
				result = {};
			}
			
			return result;
		}
	}
}