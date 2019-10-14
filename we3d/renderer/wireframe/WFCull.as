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
	* Polygon Culling against the camera frustum
	*/
	public class WFCull implements IRenderer 
	{
		public function WFCull () {}
		
		public function draw (session:RenderSession) :void {
			
			var v:Camera3d = session.camera;
			var objectList:Vector.<Object3d>  = session.scene.objectList;
			var f:Number = session.currentFrame;
			
			var objs:int = objectList.length;
			var cgv:Matrix3d;
			var nearPlane:Number = v._nearClipping;
			var farPlane:Number = v._farClipping;
			
			var pL:int;
			var i:int;
			var j:int;
			var k:int;
			var L:int;
			var r:Vector.<Face>;
			var vtxs:Vector.<Vertex>;
			var x:Number; var y:Number;	var z:Number;
			var vtxa:Vertex;	var vtxb:Vertex;
			var mz:Number;
			var e:Boolean;
			var p:Face;
			var o:SceneObject;
			
			var sl:Rasterizer = new Rasterizer();
			var bmpd:BitmapData = session.bmp;
			
			var col:uint;
			
			var ofc:int;
			var vt:Number = v.t;
			var vs:Number = v.s;
			var cgva:Number;	var cgvb:Number;	var cgvc:Number;
			var cgve:Number;	var cgvf:Number;	var cgvg:Number;
			var cgvi:Number;	var cgvj:Number;	var cgvk:Number;
			var cgvm:Number;	var cgvn:Number;	var cgvo:Number;
			var gv:Matrix3d;
			
			var camx:Number = v.transform.worldX;
			var camy:Number = v.transform.worldY;
			var camz:Number = v.transform.worldZ;
			
			for(i=0; i<objs; i++) 
			{
				o = SceneObject(objectList[i]);
				if(o.initFrame(session)) continue;
				if(o.initMesh(session)) continue;
				
				r = o.polygons;
				L = r.length;
				
				ofc = o.frameCounter;
				cgv = o.camMatrix;
				cgva = cgv.a;	cgvb = cgv.b;	cgvc = cgv.c;
				cgve = cgv.e;	cgvf = cgv.f;	cgvg = cgv.g;
				cgvi = cgv.i;	cgvj = cgv.j;	cgvk = cgv.k;
				cgvm = cgv.m;	cgvn = cgv.n;	cgvo = cgv.o + nearPlane;
				
				gv = o.transform.gv;
				
				for(j=0; j<L; j++) 
				{	
					p = r[j];
					
					pL = p.vLen;
					if(pL < 2) continue;
					
					vtxb = p.normal;
					vtxb.wz = gv.c * vtxb.x + gv.g * vtxb.y + gv.k * vtxb.z;
					vtxb.wy = gv.b * vtxb.x + gv.f * vtxb.y + gv.j * vtxb.z;
					vtxb.wx = gv.a * vtxb.x + gv.e * vtxb.y + gv.i * vtxb.z;
					
					vtxa = p.a;
					
					if(p.surface.hideBackfaces) 
					{
						z = camz - (gv.c * vtxa.x + gv.g * vtxa.y + gv.k * vtxa.z + gv.o);
						y = camy - (gv.b * vtxa.x + gv.f * vtxa.y + gv.j * vtxa.z + gv.n);
						x = camx - (gv.a * vtxa.x + gv.e * vtxa.y + gv.i * vtxa.z + gv.m);
					
						if(x*vtxb.wx + y*vtxb.wy + z*vtxb.wz < 0) continue;
					}
					
					vtxs = p.vtxs;
					
					for(k=0; k<pL; k++) {
						vtxb = vtxs[k];
						if(vtxb.frameCounter1 != ofc) {
							vtxb.wz = cgvc * vtxb.x + cgvg * vtxb.y + cgvk * vtxb.z + cgvo;
							vtxb.wy = cgvb * vtxb.x + cgvf * vtxb.y + cgvj * vtxb.z + cgvn;
							vtxb.wx = cgva * vtxb.x + cgve * vtxb.y + cgvi * vtxb.z + cgvm;
							vtxb.frameCounter1 = ofc;
						}
					}
					
					x = vtxa.wx;	
					y = vtxa.wy;	
					z = vtxa.wz;
					
					mz = -z;
					
					if(x < mz) {
						e = true;
						for(k=1; k<pL; k++) {
							vtxb = vtxs[k];
							if(vtxb.wx >= -vtxb.wz) {
								e = false;
								break;
							}
						}
						if(e) continue;
					}
					else if(x > z) {
						e = true;
						for(k=1; k<pL; k++) {
							vtxb = vtxs[k];
							if(vtxb.wx <= vtxb.wz) {
								e = false;
								break;
							}
						}
						if(e) continue;
					}
					
					if(y < mz) {
						e = true;
						for(k=1; k<pL; k++) {
							vtxb = vtxs[k];
							if(vtxb.wy >= -vtxb.wz) {
								e = false;
								break;
							}
						}
						if(e) continue;
					}
					else if(y > z) {
						e = true;
						for(k=1; k<pL; k++) {
							vtxb = vtxs[k];
							if(vtxb.wy <= vtxb.wz) {
								e = false;
								break;
							}
						}
						if(e) continue;
					}
					
					if(z < nearPlane) {
						e = true;
						for(k=1; k<pL; k++) {
							vtxb = vtxs[k];
							if(vtxb.wz > nearPlane) {
								e = false;
								break;
							}
						}
						if(e) continue;
					}
					else if(z > farPlane) {
						e = true;
						for(k=1; k<pL; k++) {
							vtxb = vtxs[k];
							if(vtxb.wz < farPlane) {
								e = false;
								break;
							}
						}
						if(e) continue;
					}
					
					for(k=0; k<pL; k++) {
						vtxb = vtxs[k];
						if(vtxb.frameCounter2 != ofc) {
							if(vtxb.wz > 0) {
								vtxb.sx = vt + vtxb.wx/vtxb.wz * vt;
								vtxb.sy = vs - vtxb.wy/vtxb.wz * vs;
							}else{
								vtxb.sx = vt + vtxb.wx * vt;
								vtxb.sy = vs - vtxb.wy * vs;
							}
							vtxb.frameCounter2 = ofc;
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