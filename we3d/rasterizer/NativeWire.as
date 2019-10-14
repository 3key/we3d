package we3d.rasterizer 
{
	import flash.display.Graphics;
	
	import we3d.we3d;
	import we3d.material.Surface;
	import we3d.material.WireAttributes;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Draws only the outlines of a polygon
	*/
	public class NativeWire implements IRasterizer 
	{
		public function NativeWire () {}
		
		public function clone () :IRasterizer {
			var r:NativeWire = new NativeWire();
			return r;
		}
		
		public function draw (material:Surface, session:RenderSession, f:Face) :void {
			
			var L:int = f.vLen;
			var sf:WireAttributes = WireAttributes(material.attributes);
			var mc:Graphics = session._graphics;
			
			var a:Vertex = f.a;
			var b:Vertex = f.b;
			
			if(L == 2) {
				mc.lineStyle(sf.lineStyle, sf._color, sf._alpha);
				mc.moveTo(a.sx, a.sy);
				mc.lineTo(b.sx, b.sy);
				return;
			}
			mc.beginFill(0,0);
			mc.lineStyle(sf.lineStyle, sf._color, sf._alpha);
			
			var x0:Number = a.sx;
			var y0:Number = a.sy;
			
			mc.moveTo(x0, y0);
			mc.lineTo(b.sx, b.sy);
			
			var c:Vertex = f.c;
			
			if(L == 3) {
				mc.lineTo(c.sx, c.sy);
			}
			else if (L == 4) {
				mc.lineTo(c.sx, c.sy);
				b = f.vtxs[3];
				mc.lineTo(b.sx, b.sy);
			}
			else{
				var p:Vector.<Vertex> = f.vtxs;
				mc.lineTo(c.sx, c.sy);
				for(var i:int=3; i<L; i++) {
					b = p[i];
					mc.lineTo(b.sx, b.sy);
				}
			}
			mc.endFill();
		}
		
	}
}