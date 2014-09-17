package com.xinguoedu.utils
{
	import flash.utils.ByteArray;

	/**
	 * 解密算法工具类 
	 * @author yatsen_yang
	 * 
	 */	
	public class Decrypt
	{
		public function Decrypt()
		{
			
		}
		
		/**
		 * 解密数据 
		 * @param bytes 保存加密数据的字节数组
		 * @param omittedLength 忽略的长度，即从这个位置开始解密
		 * @param seed 数据加密算法的种子
		 * 
		 */		
		public static function decrypt(bytes:ByteArray, omittedLength:Number, seed:int):void
		{
			var len:int = bytes.length;
			for(var i:int = omittedLength; i < len; i++)
			{
				bytes[i] -= seed;
			}
		}
	}
}