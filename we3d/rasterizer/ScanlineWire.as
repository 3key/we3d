package we3d.rasterizer 
{
	import flash.display.BitmapData;
	
	import we3d.we3d;
	import we3d.material.Surface;
	import we3d.material.WireAttributes;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Wireframe polygons with software rasterizer.
	*/
	public class ScanlineWire extends Rasterizer 
	{
		public function ScanlineWire () {}
		
		public override function draw (material:Surface, session:RenderSession, f:Face) :void {
			
			var sf:WireAttributes = WireAttributes(material.attributes);
			
			var col:uint = sf._color32;
			var bmp:BitmapData = session.bmp;
			
			var L:int = f.vLen-1;
			var a:Vertex;
			var b:Vertex;
			
			for(var i:int=0; i<L; i++) {
				a = f.vtxs[i];
				b = f.vtxs[i+1];
				drawLine (a.sx, a.sy, b.sx, b.sy, col, bmp);
			}
			
			drawLine (b.sx, b.sy, f.a.sx, f.a.sy, col, bmp);
		}
		
		public override function clone () :IRasterizer {
			var r:ScanlineWire = new ScanlineWire();
			return r;
		}
		
	}
}