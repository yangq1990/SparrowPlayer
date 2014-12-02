/**
 * Simple class that handles stretching of displayelements.
 **/
package com.xinguoedu.utils
{
	import com.xinguoedu.consts.StretcherType;
	
	import flash.display.DisplayObject;

	public class Stretcher 
	{

		/**
		 * Resize a displayobject to the display, depending on the stretching.
		 *
		 * @param clp	The display element to resize.
		 * @param wid	The target width.
		 * @param hei	The target height.
		 * @param widHeiDict 存储视频原始宽高的关联数组，数据结构 {w: Number, h:Number}
		 * @param typ	The stretching type.
		 **/
		public static function stretch(clp:DisplayObject, wid:Number, hei:Number, widHeiDict:Object, typ:String='uniform'):void 
		{			
			switch (typ) {
				case StretcherType.EXACTFIT:
					clp.width = wid;
					clp.height = hei;
					break;
				case StretcherType.NONE:
					clp.scaleX = 1;
					clp.scaleY = 1;
					clp.width = widHeiDict.w;
					clp.height = widHeiDict.h;
					break;
				case StretcherType.UNIFORM:
					var xsc:Number = wid / widHeiDict.w;
					var ysc:Number = hei / widHeiDict.h;
					if (xsc > ysc) 
					{
						clp.width = widHeiDict.w *  ysc;
						clp.height  = widHeiDict.h * ysc;
					} 
					else 
					{
						clp.width = widHeiDict.w * xsc;
						clp.height = widHeiDict.h * xsc;
					}
					break;
				case StretcherType.SIXTEEN_NINE:
					if(Math.abs(wid/hei - 16/9) <= 0.01) //屏幕分辨率为16/9
					{
						clp.width = wid;
						clp.height = hei;
					}
					else
					{
						if(wid/hei < 16/9) //非16/9分辨率，比如1680/1050=1.6
						{
							clp.width = wid;
							clp.height = wid * 9 / 16;						
						}
						else
						{
							clp.height = hei;
							clp.width = hei * 16 / 9;
						}
					}										
					break;
			}
			
			(clp.width / wid > 0.95) && (clp.width = wid);
			(clp.height / hei > 0.95) && (clp.height = hei);
			clp.x = wid >> 1;
			clp.y = hei >> 1;
			
			//往下移1px
			(clp.y == 0) && (clp.y = 1);
		}		
	}
}