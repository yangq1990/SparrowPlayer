package com.xinguoedu.v.component.settings
{
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.consts.NumberConst;
	import com.xinguoedu.consts.PlayerColor;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.settings.SubtitleEvt;
	import com.xinguoedu.utils.UIUtil;
	import com.xinguoedu.v.ui.StatefulButton;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * 设置项 
	 * @author yangq1990
	 * 
	 */	
	public class SettingItem extends Sprite
	{
		private var _label:TextField;
		private var _btnArray:Array;
		private var _btnInfoArray:Array;
		
		public function SettingItem(label:String, btnInfoArray:Array)
		{
			super();
			
			_label = new TextField();
			_label.defaultTextFormat = UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.SIZE);
			_label.text = label;
			_label.width = _label.textWidth + 5;
			_label.height = _label.textHeight + 5;
			addChild(_label);
			
			_btnArray = [];
			_btnInfoArray = btnInfoArray;
			var len:int = btnInfoArray.length;
			var btn:StatefulButton;
			for(var i:int = 0; i < len; i++)
			{
				btn = new StatefulButton(50, 25, PlayerColor.MAIN_COLOR, 1);
				btn.label = btnInfoArray[i].label;
				btn.registerHandler(btnClickHandler);
				btn.x = _label.x + _label.width + NumberConst.LABEL_BUTTON_MARGIN + i * (btn.width + NumberConst.SETTINGS_BUTTON_MARGIN);
				btn.y = (btn.height - _label.height) * 0.5;				
				addChild(btn);
				
				_btnArray.push(btn);
			}
		}
		
		private function btnClickHandler(label:String):void
		{
			setEnabled(label);
		}
		
		/**
		 * 设置指定label的button enabled，其余设置为不可用状态 
		 * @param label
		 * 
		 */		
		public function setEnabled(label:String):void
		{
			var len:int = _btnArray.length;
			var statefulBtn:StatefulButton;
			for(var i:int = 0; i < len; i++)
			{
				statefulBtn = _btnArray[i] as StatefulButton;
				if(_btnInfoArray[i].label == label)
				{
					statefulBtn.setState(true);
					EventBus.getInstance().dispatchEvent(new SubtitleEvt(_btnInfoArray[i].type));
				}
				else
				{
					statefulBtn.setState(false)
				}
			}
		}
		
		override public function get width():Number
		{
			return _label.width + NumberConst.LABEL_BUTTON_MARGIN +  _btnArray.length * (_btnArray[0].width + NumberConst.SETTINGS_BUTTON_MARGIN)
		}
		
		override public function get height():Number
		{
			return _btnArray[0].height;
		}
	}
}