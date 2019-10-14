package we3d.rasterizer 
{
	import flash.display.Graphics;
	
	import we3d.we3d;
	import we3d.material.FlatAttributes;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.mesh.VertexCurved;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Curved points can be added to a SceneObjectCurved object with the addCurvedPoint method.
	* To draw curved polygons the surface have to have this rasterizer assigned.
	*/
	public class NativeFlatCurved implements IRasterizer 
	{
		public function NativeFlatCurved () {}
		
		public function clone () :IRasterizer {
			var r:NativeFlatCurved = new NativeFlatCurved();
			return r;
		}
		
		public function draw (material:Surface, session:RenderSession, f:Face) :void {
			
			var L:int = f.vLen;
			var sf:FlatAttributes = FlatAttributes(material.attributes);
			var mc:Graphics = session._graphics;
			
			var a:Vertex = f.a;
			var b:Vertex = f.b;
			var vcr:VertexCurved;
			
			if(L == 2) {
				mc.lineStyle(0, sf._color, sf._alpha);
				//mc.beginFill(0,1);
				mc.moveTo(a.sx, a.sy);
				if(b is VertexCurved) {
					vcr = VertexCurved(b);
					mc.curveTo(vcr.bsx, vcr.bsy, vcr.sx, vcr.sy);
				}else{
					mc.lineTo(b.sx, b.sy);
				}
				return;
			}
			
			mc.lineStyle();
			mc.beginFill(sf._color, sf._alpha);
			
			var x0:Number = a.sx;
			var y0:Number = a.sy;
			
			mc.moveTo(x0, y0);
			if(b is VertexCurved) {
				vcr = VertexCurved(b);
				mc.curveTo(vcr.bsx, vcr.bsy, vcr.sx, vcr.sy);
			}else{
				mc.lineTo(b.sx, b.sy);
			}
			
			var c:Vertex = f.c;
			
			if(L == 3) {
				if(c is VertexCurved) {
					vcr = VertexCurved(c);
					mc.curveTo(vcr.bsx, vcr.bsy, vcr.sx, vcr.sy);
				}else{
					mc.lineTo(c.sx, c.sy);
				}
			}
			else if (L == 4) {
				if(c is VertexCurved) {
					vcr = VertexCurved(c);
					mc.curveTo(vcr.bsx, vcr.bsy, vcr.sx, vcr.sy);
				}else{
					mc.lineTo(c.sx, c.sy);
				}
				b = f.vtxs[3];
				if(b is VertexCurved) {
					vcr = VertexCurved(b);
					mc.curveTo(vcr.bsx, vcr.bsy, vcr.sx, vcr.sy);
				}else{
					mc.lineTo(b.sx, b.sy);
				}
			}
			else{
				var p:Vector.<Vertex> = f.vtxs;
				for(var i:int=2; i<L; i++) {
					b = p[i];
					if(b is VertexCurved) {
						vcr = VertexCurved(b);
						mc.curveTo(vcr.bsx, vcr.bsy, vcr.sx, vcr.sy);
					}else{
						mc.lineTo(b.sx, b.sy);
					}
				}
			}
			
			mc.endFill();
		}
		
	}
}