package com.xinguoedu.v.component
{
	import com.xinguoedu.consts.PlayerState;
	import com.xinguoedu.evt.EventBus;
	import com.xinguoedu.evt.PlayerStateEvt;
	import com.xinguoedu.evt.media.MediaEvt;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.Logger;
	import com.xinguoedu.v.base.BaseComponent;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	/**
	 * 包括缓冲提示信息的组件
	 * @author yatsen_yang
	 * 
	 */	
	public class DisplayComponent extends BaseComponent
	{
		private var _buffer_mc:MovieClip;
		private var _buffer_tf:TextField;
		
		public function DisplayComponent(m:Model)
		{
			super(m);
		}
		
		override protected function buildUI():void
		{
			_skin = _m.skin.display as MovieClip;
			_buffer_mc = _skin.buffer_mc as MovieClip;
			_buffer_tf = _skin.buffer_tf as TextField;
			this.addChild(_buffer_mc);
			this.addChild(_buffer_tf);
			resize();
			super.buildUI(); //默认是隐藏状态
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_LOADING, mediaLoadingHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_BUFFER_FULL, bufferFullHandler);
			EventBus.getInstance().addEventListener(MediaEvt.MEDIA_ERROR, mediaErrorHandler);
		}
		
		override protected function playerStateChangeHandler(evt:PlayerStateEvt):void
		{
			switch(_m.state)
			{			
				case PlayerState.BUFFERING:
					this.visible = true;
					resize();
					break;
				case PlayerState.IDLE:
				case PlayerState.PAUSED:
				case PlayerState.PLAYING:
					this.visible = false;
					break;
			}
		}
		
		/** 
		 * 对于http视频，evt.data.percent 代表的是视频在内寸缓冲区的填满程度
		 * 对于httpe视频，evt.data.percent 代表的是加密视频加载到本地的进度
		 * **/
		private function mediaLoadingHandler(evt:MediaEvt):void
		{
			if(_m.state == PlayerState.PLAYING) //避免一边播放一边显示加载百分比
				return;
			
			_buffer_tf.text = "";
			(evt.data != null) && _buffer_tf.appendText(int(evt.data.percent*100) + "%"); //这样写更有效
			if(!this.visible)
			{				
				this.visible = true;
				resize();
			}
		}
		
		private function bufferFullHandler(evt:MediaEvt):void
		{
			this.visible = false;
		}
		
		private function mediaErrorHandler(evt:MediaEvt):void
		{
			this.visible = false;
		}
		
		override protected function resize():void
		{
			if(this.visible)
			{
				if(_buffer_tf.text)
				{
					_buffer_mc.x = (stageWidth - _buffer_mc.width) >> 1;
					_buffer_tf.x = stageWidth >> 1;
				}
				else
				{
					_buffer_mc.x = stage.stageWidth >> 1;
				}
				_buffer_mc.y = (stageHeight - controlbarHeight) >> 1 ;
				_buffer_tf.y = (stageHeight - controlbarHeight - _buffer_tf.height) >> 1;
			}
		}
	}
}