package we3d.filter 
{
	import we3d.we3d;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/** 
	 * The ZBuffer is assigned to the Scanline-ZB rasterizers. You can also just set camera.zbuffer to true and set the ZBuffer filter in the rasterizer to null.
	 */
	public class ZBuffer extends BackgroundFilter 
	{
		public function ZBuffer (w:int=0, h:int=0) {
			_width = w;
			_height = h;
		}
		
		we3d var vec:Vector.<Number>;
		private var _width:int;
		private var _height:int;
		
		public function setSize (w:int, h:int) :void {
			_width = w;
			_height = h;
			createBitmap();
		}
		
		public override function initialize (session:RenderSession) :void {
			if(_width == 0) _width = session.camera.width || session.width;
			if(_height == 0) _height = session.camera.height || session.height;
			createBitmap();
		}
		public function clear () :void {
			vec = new Vector.<Number>(_width*_height);
		}
		public override function initFrame (session:RenderSession) :void {
			vec = new Vector.<Number>(_width*_height);
		}
		
		public function createBitmap () :void {
			vec = new Vector.<Number>(_width*_height);
		}
		
	}
}
