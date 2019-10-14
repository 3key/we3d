package we3d.rasterizer 
{
	import flash.display.Graphics;
	
	import we3d.we3d;
	import we3d.material.FlatAttributes;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Draws one fill color on the polygon.
	*/
	public class NativeFlat implements IRasterizer 
	{
		public function NativeFlat () {}
		
		public function clone () :IRasterizer {
			var r:NativeFlat = new NativeFlat();
			return r;
		}
		
		public function draw (material:Surface, session:RenderSession, f:Face) :void 
		{
			var sf:FlatAttributes = FlatAttributes(material.attributes);
			var mc:Graphics = session._graphics;
			
			if(f.vLen == 3) 
			{
				mc.lineStyle();
				mc.beginFill(sf._color, sf._alpha);
				mc.moveTo(f.a.sx, f.a.sy);
				mc.lineTo(f.b.sx, f.b.sy);
				mc.lineTo(f.c.sx, f.c.sy);
				//mc.lineTo(f.a.sx, f.a.sy);
				mc.endFill();
			}
			else if (f.vLen == 4) 
			{
				mc.lineStyle();
				mc.beginFill(sf._color, sf._alpha);
				mc.moveTo(f.a.sx, f.a.sy);
				mc.lineTo(f.b.sx, f.b.sy);
				mc.lineTo(f.c.sx, f.c.sy);
				var d:Vertex = f.vtxs[3];
				mc.lineTo(d.sx, d.sy);
				mc.endFill();
			}
			else if (f.vLen > 4) 
			{
				mc.lineStyle();
				mc.beginFill(sf._color, sf._alpha);
				mc.moveTo(f.a.sx, f.a.sy);
				mc.lineTo(f.b.sx, f.b.sy);
				mc.lineTo(f.c.sx, f.c.sy);
				var b:Vertex;
				var L:int = f.vLen;
				for(var i:int=3; i<L; i++) {
					b = f.vtxs[i]
					mc.lineTo(b.sx, b.sy);
				}
				mc.endFill();
			}
		}
	}
}