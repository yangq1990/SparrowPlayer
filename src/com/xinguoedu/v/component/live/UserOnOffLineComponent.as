package com.xinguoedu.v.component.live
{
	import com.greensock.TweenLite;
	import com.xinguoedu.consts.module.UserModuleEvtType;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.m.vo.MsgVO;
	import com.xinguoedu.v.base.BaseComponent;
	import com.xinguoedu.v.base.BaseHintComponent;
	
	/**
	 * 用户上下线提示组件 
	 * @author yangq1990
	 * 
	 */	
	public class UserOnOffLineComponent extends BaseHintComponent
	{
		public function UserOnOffLineComponent(m:Model)
		{
			super(m);
		}
		
		override protected function usrModuleHandler(data:MsgVO):void
		{
			var text:String;
			if(data.type == UserModuleEvtType.ONLINE || data.type == UserModuleEvtType.OFFLINE)
			{
				var postfix:String = (data.type == UserModuleEvtType.ONLINE ? '上线' : '下线');	
				text = 'IP为' + data.content.ip + '的' +  data.content.name + postfix;
				
				if(!this.visible)
				{
					this.visible = true;
					super.setHintTxt(text);
					TweenLite.from(this, 0.4, {alpha:0.4, y:-this.height, onComplete:super.startTimer});
				}
				else
				{
					_repo.push(text);
					super.startTimer();
				}
			}
		}
		
		private function onTweenComplete():void
		{
			super.startTimer();
		}
		
		override protected function resize():void
		{
			if(this.visible)
			{
				this.x = (stageWidth - this.width) >> 1;
			}
		}		
		
		override public function get width():Number
		{
			return _hint.width;
		}
		
		override public function get height():Number
		{
			return _hint.height;
		}
	}
}