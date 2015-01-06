package
{
	import com.xinguoedu.c.Controller;
	import com.xinguoedu.m.Model;
	import com.xinguoedu.utils.StageReference;
	import com.xinguoedu.v.View;
	import com.xinguoedu.v.base.BaseInitView;
	
	/**
	 * sparrow player入口类 
	 * @author yatsen_yang
	 * 
	 */	
	public class SparrowPlayer extends BaseInitView
	{
		private var _m:Model;
		private var _v:View;
		private var _c:Controller;
		
		public function SparrowPlayer()
		{
			super();
		}
		
		override protected function init():void
		{
			super.init();			
			
			new StageReference(this);
			
			_m = new Model();
			_v = new View(_m);
			
			_c = new Controller(_v, _m);		
			_c.setupPlayer();
		}
	}
}