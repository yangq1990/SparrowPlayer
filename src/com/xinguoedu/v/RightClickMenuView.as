package com.xinguoedu.v
{
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.StageReference;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	/**
	 * 右键菜单类 
	 * @author yatsen_yang
	 * 
	 */	
	public class RightClickMenuView extends Sprite
	{
		protected var context:ContextMenu;
		private var _m:Model;
		private var _parent:Sprite;
		
		public function RightClickMenuView(m:Model, parent:Sprite)
		{
			super();
			
			this._m = m;
			this._parent = parent;
			
			context = new ContextMenu();
			context.hideBuiltInItems();
			_parent.contextMenu = context; //Stage不实现此属性
		}
		
		public function initializeMenu():void
		{
			addItem(new ContextMenuItem('版本:' + _m.playerconfig.version));
			
			for each(var obj:Object in _m.playerconfig.rightclickinfo)
			{
				addItem(new ContextMenuItem(obj.title), onMenuItemSelectHandler);
			}
		}
		
		/** Add an item to the contextmenu.**/
		protected function addItem(itm:ContextMenuItem, fcn:Function=null):void 
		{
			itm.separatorBefore = true;
			context.customItems.push(itm);
			fcn && itm.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, fcn);								
		}
		
		/** 如果被选择的menuItem有链接，则跳转到指定的链接地址 **/
		private function onMenuItemSelectHandler(evt:ContextMenuEvent):void
		{
			var caption:String = (evt.target as ContextMenuItem).caption;
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