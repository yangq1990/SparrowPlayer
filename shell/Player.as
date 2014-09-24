package 
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.display.MovieClip;

	/**
	 * @author yatsen_yang
	 * 
	 */
	public class Player extends MovieClip
	{
		private var _timeout:uint;

		public function Player()
		{
			init();
		}

		private function init():void
		{
			stop();
			stage.scaleMode = "noScale";
			stage.align = "TL";
			stage.showDefaultContextMenu = false;

			loaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resize();
		}

		private function completeHandler(event:Event):void
		{
			loaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			_timeout = setTimeout(timeoutHandler,1000);
		}

		private function timeoutHandler():void
		{
			try
			{
				clearTimeout(_timeout);
				_timeout = undefined;
				play();

			}
			catch (err:Error)
			{
				trace(err.getStackTrace());
			}
		}

		private function resizeHandler(event:Event):void
		{
			resize();
		}

		private function resize():void
		{
			if (bg_pic != null)
			{
				bg_pic.x = stage.stageWidth * 0.5;
				bg_pic.y = stage.stageHeight * 0.5 - 50;
			}
		}
	}
}