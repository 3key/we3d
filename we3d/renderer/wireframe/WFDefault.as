package we3d.renderer.wireframe 
{
	import flash.display.BitmapData;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.material.FlatAttributes;
	import we3d.math.Matrix3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.rasterizer.Rasterizer;
	import we3d.renderer.IRenderer;
	import we3d.renderer.RenderSession;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/**
	* Backface Culling
	*/
	public class WFDefault implements IRenderer 
	{
		public function WFDefault () {}
		
		public function draw (session:RenderSession) :void {
			
			var v:Camera3d = session.camera;
			var objectList:Vector.<Object3d>  = session.scene.objectList;
			var f:Number = session.currentFrame;
			
			var objs:int = objectList.length;
			var cgv:Matrix3d;
			
			var camx:Number = v.transform.worldX;
			var camy:Number = v.transform.worldY;
			var camz:Number = v.transform.worldZ;
			
			var sl:Rasterizer = new Rasterizer();
			var bmpd:BitmapData = session.bmp;
			
			var col:uint;
			var ofc:int;
			var gv:Matrix3d;
			var pL:int;
			var i:int;
			var j:int;
			var k:int;
			var L:int;
			var r:Vector.<Face>;
			var vtxs:Vector.<Vertex>;
			var x:Number; var y:Number; var z:Number;
			var vtxa:Vertex;
			var vtxb:Vertex;
			var p:Face;
			var o:SceneObject;
			
			for(i=0; i<objs; i++) 
			{
				o = SceneObject(objectList[i]);
				if(o.initFrame(session)) continue;
				if(o.initMesh(session)) continue;
				
				r = o.polygons;
				L = r.length;
				
				ofc = o.frameCounter;
				gv = o.transform.gv;
				cgv = o.camMatrix;
				
				for(j=0; j<L; j++) 
				{
					p = r[j];
					
					pL = p.vLen;
					if(pL < 2) continue;
					
					vtxb = p.normal;
					vtxb.wz = gv.c * vtxb.x + gv.g * vtxb.y + gv.k * vtxb.z;
					vtxb.wy = gv.b * vtxb.x + gv.f * vtxb.y + gv.j * vtxb.z;
					vtxb.wx = gv.a * vtxb.x + gv.e * vtxb.y + gv.i * vtxb.z;
					
					if(p.surface.hideBackfaces) 
					{
						vtxa = p.a;
						z = camz - (gv.c * vtxa.x + gv.g * vtxa.y + gv.k * vtxa.z + gv.o);
						y = camy - (gv.b * vtxa.x + gv.f * vtxa.y + gv.j * vtxa.z + gv.n);
						x = camx - (gv.a * vtxa.x + gv.e * vtxa.y + gv.i * vtxa.z + gv.m);
					
						if(x*vtxb.wx + y*vtxb.wy + z*vtxb.wz < 0) continue;
					}
					
					vtxs = p.vtxs;
					
					for(k=0; k<pL; k++) {
						vtxb = vtxs[k];
						if(vtxb.frameCounter1 != ofc) {
							vtxb.wz = cgv.c * vtxb.x + cgv.g * vtxb.y + cgv.k * vtxb.z + cgv.o;
							vtxb.wy = cgv.b * vtxb.x + cgv.f * vtxb.y + cgv.j * vtxb.z + cgv.n;
							vtxb.wx = cgv.a * vtxb.x + cgv.e * vtxb.y + cgv.i * vtxb.z + cgv.m + v._nearClipping;
							if(vtxb.wz > 0) {
								vtxb.sx = v.t + vtxb.wx/vtxb.wz * v.t;
								vtxb.sy = v.s - vtxb.wy/vtxb.wz * v.s;
							}else{
								vtxb.sx = v.t + vtxb.wx * v.t;
								vtxb.sy = v.s - vtxb.wy * v.s;
							}
							vtxb.frameCounter1 = ofc;
						}
					}
					
					// drawPoly
					col = FlatAttributes(p.surface.attributes)._color32;
					pL--;
					for(k=0; k<pL; k++) {
						vtxa = vtxs[k];
						vtxb = vtxs[k+1];
						sl.drawLine(vtxa.sx, vtxa.sy, vtxb.sx, vtxb.sy, col, bmpd);
					}
					vtxa = vtxs[k];
					vtxb = vtxs[0];
					sl.drawLine(vtxa.sx, vtxa.sy, vtxb.sx, vtxb.sy, col, bmpd);
				}
			}
		}
		
	}
}