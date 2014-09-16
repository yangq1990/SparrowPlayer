package com.xinguoedu.utils
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.system.Security;

	/**
	 * 持有舞台stage的静态引用
	 * @author yatsen_yang
	 */
	public class StageReference 
	{
		/** 指向舞台的引用 **/ 
		private static var _stage:Stage;
		
		public static var root:DisplayObject;		

		public function StageReference(displayObj:DisplayObject) 
		{
			if (!StageReference.root) 
			{
				StageReference.root = displayObj.root;
				StageReference.stage = displayObj.stage;
				try 
				{
					Security.allowDomain("*");
				} 
				catch(e:Error) 
				{
					
				}
			}
		}
		
		public static function get stage():Stage 
		{
			return _stage;
		}
		
		public static function set stage(s:Stage):void 
		{
			_stage = s;
		}
	}
}