package com.xinguoedu.utils
{
	import flash.utils.ByteArray;

	/**
	 * 解密算法工具类 
	 * @author yatsen_yang
	 * 
	 */	
	public class DecryptFlv
	{
		public function DecryptFlv()
		{
		}
		
		/** 解密视频的算法 **/
		public static function decrypt(bytes:ByteArray):ByteArray
		{
			var i:int = bytes.length;
			while (i--)
			{
				bytes[i] -= 128;
			}
			
			return bytes;
		}
	}
}