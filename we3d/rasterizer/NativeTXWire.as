package we3d.rasterizer 
{
	import flash.display.Graphics;
	
	import we3d.we3d;
	import we3d.material.BitmapWireAttributes;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Bitmap textures with outlines
	*/
	public class NativeTXWire implements IRasterizer 
	{
		public function NativeTXWire () {
			indices = new Vector.<int>(3);
			vertices = new Vector.<Number>(6);
			uvt = new Vector.<Number>(9);
			
			indices[0] = 0;
			indices[1] = 1;
			indices[2] = 2;
		}
		private var indices:Vector.<int>;
		private var vertices:Vector.<Number>;
		private var uvt:Vector.<Number>;
		
		public function clone () :IRasterizer {
			var r:NativeTXWire = new NativeTXWire();
			return r;
		}
		
		public function draw (material:Surface, session:RenderSession, f:Face) :void {
			
			var L:int = f.vLen;
			
			if(L > 2) 
			{
				var sf:BitmapWireAttributes = BitmapWireAttributes(material.attributes);
				var mc:Graphics = session._graphics;
				
				mc.lineStyle(sf.lineStyle, sf._lineColor, sf._lineAlpha);
				mc.beginBitmapFill(sf._texture, null, sf.repeat, sf.smooth);
				
				var a:Vertex;	var b:Vertex;	var c:Vertex;
				
				a = f.a;
				vertices[0] = a.sx;	vertices[1] = a.sy;
				uvt[0] = f.uvs[0].u;	uvt[1] = f.uvs[0].v;	uvt[2] = 1/a.wz;
				L--;
				
				for(var i:int=0; i<L; i++) 
				{
					b = f.vtxs[i];
					c = f.vtxs[i+1];
					
					vertices[2] = b.sx;	vertices[3] = b.sy;
					vertices[4] = c.sx;	vertices[5] = c.sy;
					
					uvt[3] = f.uvs[i].u;	uvt[4] = f.uvs[i].v;	uvt[5] = 1/b.wz;
					uvt[6] = f.uvs[i+1].u;	uvt[7] = f.uvs[i+1].v;	uvt[8] = 1/c.wz;
					
					mc.drawTriangles( vertices, indices, uvt );
				}
				mc.endFill();
			}
			
		}
		
	}
}