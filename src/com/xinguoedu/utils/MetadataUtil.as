package com.xinguoedu.utils
{
	/**
	 * 处理视频metadata的工具类 
	 * @author yatsen_yang
	 * 
	 */	
	public class MetadataUtil
	{
		public function MetadataUtil()
		{
		}
		
		/**
		 *  
		 * @param data object with keyframe times and positions
		 * @param sec 拖动的时间点
		 * @param tme true 返回离拖动点最近的关键帧的时间点;false 返回离拖动点最近的关键帧的字节偏移量
		 * @return 
		 * 
		 */		
		public static function getOffset(data:Object, sec:Number, tme:Boolean=false):Number 
		{
			if (!data) 
			{
				return 0;
			}
			
			for (var i:Number = 0; i < data.times.length - 1; i++) 
			{
				if (data.times[i] <= sec && data.times[i + 1] >= sec) 
				{
					break;
				}
			}
			
			if(!tme)
			{
				return data.filepositions[i];
			}
			else
			{
				return data.times[i];
			}
		}
	}
}