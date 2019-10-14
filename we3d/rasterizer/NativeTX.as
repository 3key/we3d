package we3d.rasterizer 
{
	import flash.display.Graphics;
	
	import we3d.we3d;
	import we3d.material.BitmapAttributes;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Bitmap textures using the flash 10 drawing api, provides better amd faster texture rastering than Flash 9 compatible NativeTX
	*/
	public class NativeTX implements IRasterizer 
	{
		public function NativeTX () {
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
			var r:NativeTX = new NativeTX();
			return r;
		}
		
		public function draw (material:Surface, session:RenderSession, f:Face) :void 
		{
			if(f.vLen > 2) 
			{
				var sf:BitmapAttributes = BitmapAttributes(material.attributes);
				var mc:Graphics = session._graphics;
				
				mc.lineStyle();
				mc.beginBitmapFill(sf._texture, null, sf.repeat, sf.smooth);
				
				vertices[0] = f.a.sx;	vertices[1] = f.a.sy;
				vertices[2] = f.b.sx;	vertices[3] = f.b.sy;
				vertices[4] = f.c.sx;	vertices[5] = f.c.sy;
				
				uvt[0] = f.u1;	uvt[1] = f.v1;	uvt[2] = 1/f.a.wz;
				uvt[3] = f.u2;	uvt[4] = f.v2;	uvt[5] = 1/f.b.wz;
				uvt[6] = f.u3;	uvt[7] = f.v3;	uvt[8] = 1/f.c.wz;
				
				mc.drawTriangles( vertices, indices, uvt );
				
				if(f.vLen > 3) 
				{
					var L:int = f.vLen-1;
					var b:Vertex;	var c:Vertex;
					var uv1:UVCoord;
					var uv2:UVCoord;
					for(var i:int=1; i<L; i++) 
					{
						b = f.vtxs[i];
						c = f.vtxs[i+1];
						
						vertices[2] = b.sx;	vertices[3] = b.sy;
						vertices[4] = c.sx;	vertices[5] = c.sy;
						
						uv1 = f.uvs[i];
						uv2 = f.uvs[i+1];
						uvt[3] = uv1.u;	uvt[4] = uv1.v;	uvt[5] = 1/b.wz;
						uvt[6] = uv2.u;	uvt[7] = uv2.v;	uvt[8] = 1/c.wz;
						
						mc.drawTriangles( vertices, indices, uvt );
					}
				}
				
				mc.endFill();
			}	
		}
	}
}