package com.xinguoedu.evt
{
	import com.xinguoedu.m.vo.MsgVO;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	
	/**
	 * 模块事件类 
	 * @author yangq1990
	 * 
	 */	
	public class ModuleEvt extends Event
	{
		private var _moduleID:String;
		
		private var _data:*;
		
		/**
		 *  
		 */		
		public static const INCOMING_MSG:String = "incoming_msg";
		
		public function ModuleEvt(type:String, moduleID:String, data:MsgVO, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._moduleID = moduleID;
			this._data = data;
		}
		
		public function get moduleID():String
		{
			return _moduleID;
		}
		
		public function get data():MsgVO
		{
			return _data;
		}
		
		override public function clone():Event
		{
			return new ModuleEvt(type, _moduleID, _data);
		}
	}
}