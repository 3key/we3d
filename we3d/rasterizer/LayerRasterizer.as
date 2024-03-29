package we3d.rasterizer 
{
	import we3d.we3d;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Renders multiple surfaces on one polygon.
	*/
	public class LayerRasterizer implements IRasterizer
	{
		public function LayerRasterizer () {}
				
		public var surfaces:Vector.<Surface> = new  Vector.<Surface>();
		
		public function addLayer (sf:Surface) :int {
			return surfaces.push(sf)-1;
		}
		
		public function draw (material:Surface, session:RenderSession, f:Face) :void {
			var L:int = surfaces.length;
			var sf:Surface;
			for(var i:int=0; i<L; i++) {
				sf = surfaces[i];
				sf.rasterizer.draw(sf, session, f);
			}
		}
		
		public function clone () :IRasterizer {
			var r:LayerRasterizer = new LayerRasterizer();
			var L:int = surfaces.length;
			for(var i:int=0; i<L; i++) {
				r.surfaces.push( Surface(surfaces[i]).clone() );
			}
			return r;
		}
	}
}