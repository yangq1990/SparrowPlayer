package com.xinguoedu.v
{
	import com.xinguoedu.consts.DebugConst;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.debug.DebugEvt;
	import com.xinguoedu.m.Model;
	
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	/**
	 * 右键菜单类 
	 * @author yatsen_yang
	 * 
	 */	
	public class RightClickMenuView extends Sprite
	{
		private var context:ContextMenu;
		private var _m:Model;
		private var _debuggingInfo:String;
		
		public function RightClickMenuView(m:Model, parent:Sprite)
		{
			super();
			
			this._m = m;		
			context = new ContextMenu();
			context.hideBuiltInItems();
			parent.contextMenu = context; //Stage不实现此属性
			
			if(m.debugmode)
			{
				_debuggingInfo = "";
				EventBus.getInstance().addEventListener(DebugEvt.DEBUG, debugHandler);
			}			
		}
		
		private function debugHandler(evt:DebugEvt):void
		{			
			_debuggingInfo += new Date().toString() + '-->' + evt.info + "\n";  
		}
		
		public function initializeMenu():void
		{
			addItem(new ContextMenuItem('版本:' + _m.version));
			
			for each(var obj:Object in _m.playerconfig.rightclickinfo)
			{
				addItem(new ContextMenuItem(obj.title), menuItemSelectHandler);
			}
			
			_m.debugmode && addItem(new ContextMenuItem(DebugConst.COPY_DEBUG_INFO), menuItemSelectHandler);
		}
		
		/** Add an item to the contextmenu.**/
		protected function addItem(itm:ContextMenuItem, fcn:Function=null):void 
		{
			itm.separatorBefore = true;
			context.customItems.push(itm);
			fcn && itm.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, fcn);								
		}
		
		/** 如果被选择的menuItem有链接，则跳转到指定的链接地址 **/
		private function menuItemSelectHandler(evt:ContextMenuEvent):void
		{
			var caption:String = (evt.target as ContextMenuItem).caption;
			if(caption == DebugConst.COPY_DEBUG_INFO)
			{
				System.setClipboard(_debuggingInfo);
				return;	
			}
			
			for each(var obj:Object in _m.playerconfig.rightclickinfo)
			{
				if(obj.title == caption && obj.url != null)
				{
					navigateToURL(new URLRequest(obj.url));
				}
			}
		}
	}
}