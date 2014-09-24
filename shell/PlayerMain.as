package  
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * @author yatsen_yang
	 * 
	 */	
	public class PlayerMain extends MovieClip {
		[Embed(source = "player/SparrowPlayer.swf", mimeType="application/octet-stream")]
		private var mainViewClass:Class;
		private var m_loader:Loader;

		public function PlayerMain() {
			init();
		}
		
		private function init():void
		{
			m_loader = new Loader();
			addChild(m_loader);
			m_loader.loadBytes(new mainViewClass());
		}
	}
	
}

