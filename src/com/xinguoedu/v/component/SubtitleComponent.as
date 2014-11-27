package com.xinguoedu.v.component
{
	import com.xinguoedu.consts.Font;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.evt.settings.SubtitleEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.Logger;
	import com.xinguoedu.utils.UIUtil;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.StageDisplayState;
	import flash.text.TextField;
	
	/**
	 * 字幕组件，目前只支持对srt字幕的解析
	 * @author yangq1990
	 * 
	 */	
	public class SubtitleComponent extends BaseComponent
	{
		/** 默认字幕 **/
		private var _defaultSubtitle:TextField;
		/** 双语字幕时的第二字幕 **/
		private var _secondSubtitle:TextField;
		/** 字幕时间当前位置 **/
		private var _index:int = 0;
		private var _pos:Number;
		
		public function SubtitleComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_defaultSubtitle = new TextField();
			addChild(_defaultSubtitle);
			
			if(_m.subtitleVO.isBilingual) //双语字幕
			{
				_secondSubtitle = new TextField();
				addChild(_secondSubtitle);
			}
			
			//默认显示字幕
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_TIME, timeHandler);
			EventBus.getInstance().addEventListener(SubtitleEvt.SHOW_SUBTITLE, showSubtitleHandler);
			EventBus.getInstance().addEventListener(SubtitleEvt.CLOSE_SUBTITLE, closeSubtitleHandler);
		}
	
		private function timeHandler(evt:MediaEvt):void
		{
			if(_m.srtTimeArray == null || _m.srtTimeArrayLength == 0)
			{
				Logger.error('SubtitleComponent', '字幕数据不正确');
				EventBus.getInstance().removeEventListener(MediaEvt.MEDIA_TIME, timeHandler);
				return;
			}
			
			_pos = evt.data.position;
			if(_pos < _m.srtTimeArray[0] || _pos > _m.srtTimeArray[_m.srtTimeArrayLength - 1])
				return;
			
			//trace(_index, _pos, _m.srtTimeArray[_index], _m.srtTimeArray[_index+1]);
			if((_index % 2 == 0) && _pos >= _m.srtTimeArray[_index] && _pos < _m.srtTimeArray[_index + 1])
			{
				if(_defaultSubtitle.text != _m.defaultLangTextArray[_index / 2])
				{
					_defaultSubtitle.text = _m.defaultLangTextArray[_index / 2];
					!secondSubtitleIsNull && (_secondSubtitle.text = _m.secondLangTextArray[_index / 2]); 
					resize();
				}				
			}
			else
			{
				_defaultSubtitle.text = "";
				!secondSubtitleIsNull && (_secondSubtitle.text = "");
				updateIndex();
			}			
		}
		
		private function updateIndex():void
		{
			if(_m.srtTimeArrayLength == 0)
				return;
			
			for(var i:int = 0; i < _m.srtTimeArrayLength; i+=2) //for循环的步长为2
			{
				if(_pos >= _m.srtTimeArray[i] && _pos < _m.srtTimeArray[i+1])
				{
					_index = i;
					break;
				}
			}
		}
		
		private function showSubtitleHandler(evt:SubtitleEvt):void
		{
			if(!visible)
			{
				visible = true;
				resize();
			}
		}
		
		private function closeSubtitleHandler(evt:SubtitleEvt):void
		{
			visible = false;
		}
		
		override protected function resize():void
		{
			if(visible)
			{
				//全屏状态和普通状态下字幕字体的大小不一样
				if(displayState == StageDisplayState.NORMAL)
				{
					_defaultSubtitle.setTextFormat(UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.DEFAULT_SUBTITLE_SIZE));
					UIUtil.adjustTFWidthAndHeight(_defaultSubtitle);
					
					if(!secondSubtitleIsNull)
					{
						_secondSubtitle.setTextFormat((UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.SECOND_SUBTITLE_SIZE)));
						UIUtil.adjustTFWidthAndHeight(_secondSubtitle);	
					}
				}
				else if(displayState == StageDisplayState.FULL_SCREEN)
				{
					_defaultSubtitle.setTextFormat(UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.DEFAULT_SUBTITLE_SIZE_FULLSCREEN));
					UIUtil.adjustTFWidthAndHeight(_defaultSubtitle, 10);
					if(!secondSubtitleIsNull)
					{
						_secondSubtitle.setTextFormat(UIUtil.getTextFormat(Font.YAHEI, Font.COLOR, Font.SECOND_SUBTITLE_SIZE_FULLSCREEN));
						UIUtil.adjustTFWidthAndHeight(_secondSubtitle, 10);
					}
				}
							
				_defaultSubtitle.x = (stageWidth - _defaultSubtitle.textWidth) >> 1;
				_defaultSubtitle.y = stageHeight - controlbarHeight - 50;
				
				if(!secondSubtitleIsNull)
				{
					_secondSubtitle.x = (stageWidth - _secondSubtitle.textWidth) >> 1;
					_secondSubtitle.y = _defaultSubtitle.y - _secondSubtitle.height;
				}
			}
		}
		
		override protected function mediaCompleteHandler(evt:MediaEvt):void
		{
			_defaultSubtitle.text = "";
			!secondSubtitleIsNull && (_secondSubtitle.text = "");
			_index = 0;
		}
		
		/** 第二字幕是否为null **/
		protected function get secondSubtitleIsNull():Boolean
		{
			return _secondSubtitle == null;
		}
	}
}