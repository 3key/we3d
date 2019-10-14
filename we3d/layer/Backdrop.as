package we3d.layer 
{
	import we3d.layer.Layer;
	import we3d.renderer.RenderSession;
	
	/** 
	 * Base class for a layer backdrop
	 */
	public class Backdrop  
	{
		public function Backdrop () {}
		public function drawToGPU (session:RenderSession, lyr:Layer) :void {}
		public function drawToBitmap (session:RenderSession, lyr:Layer) :void {}
		public function drawToSprite (session:RenderSession, lyr:Layer) :void {}
	}
}