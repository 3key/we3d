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
	import we3d.renderer.ClipUtil;
	import we3d.renderer.IRenderer;
	import we3d.renderer.RenderSession;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/**
	* Polygon clipping against the five frustum planes of the camera (left, top, right, bottom and near).
	*/
	public class WFClipFrustum extends ClipUtil implements IRenderer 
	{
		public function WFClipFrustum () {}
		
		public function draw (session:RenderSession) :void {
			
			var f:Number = session.currentFrame;
			var v:Camera3d = session.camera;
			var objectList:Vector.<Object3d>  = session.scene.objectList;
			var objs:int = objectList.length;
			var cgv:Matrix3d;
			var farPlane:Number = v._farClipping;
			
			plw = v._nearClipping == 0 ? .0005 : v._nearClipping;
			var vt:Number = v.t;
			var vs:Number = v.s;
			
			var p:Face;
			var o:SceneObject;
			var i:int;
			var j:int;
			var L:int;
			var r:Vector.<Face>;
			var clp1:Boolean;
			var clp2:Boolean;
			var pL:int;
			var vtxs:Vector.<Vertex>;
			var k:int;
			var splitpts:Vector.<Vertex>;
			var splitpts2:Vector.<Vertex>;
			var vtxa:Vertex;
			var vtxb:Vertex;
			var e:Boolean;
			
			var x:Number;	var y:Number;	var z:Number; 
			var ofc:int;
			var cgva:Number;	var cgvb:Number;	var cgvc:Number;
			var cgve:Number;	var cgvf:Number;	var cgvg:Number;
			var cgvi:Number;	var cgvj:Number;	var cgvk:Number;
			var cgvm:Number;	var cgvn:Number;	var cgvo:Number;
			var gv:Matrix3d;
			
			var camx:Number = v.transform.worldX;
			var camy:Number = v.transform.worldY;
			var camz:Number = v.transform.worldZ;
			
			var sl:Rasterizer = new Rasterizer();
			var bmpd:BitmapData = session.bmp;
			
			var col:uint;
			
			for(i=0; i<objs; i++) {
				
				o = SceneObject(objectList[i]);
				if(o.initFrame(session)) continue;
				if(o.initMesh(session)) continue;
				
				r = o.polygons;
				L = r.length;
				
				ofc = o.frameCounter;
				gv = o.transform.gv;
				cgv = o.camMatrix;
				
				cgva = cgv.a;	cgvb = cgv.b;	cgvc = cgv.c;
				cgve = cgv.e;	cgvf = cgv.f;	cgvg = cgv.g;
				cgvi = cgv.i;	cgvj = cgv.j;	cgvk = cgv.k;
				cgvm = cgv.m;	cgvn = cgv.n;	cgvo = cgv.o + plw;
				
				for(j=0; j<L; j++) {
					
					p = r[j];
					
					vtxb = p.normal;
					vtxb.wz = gv.c * vtxb.x + gv.g * vtxb.y + gv.k * vtxb.z;
					vtxb.wy = gv.b * vtxb.x + gv.f * vtxb.y + gv.j * vtxb.z;
					vtxb.wx = gv.a * vtxb.x + gv.e * vtxb.y + gv.i * vtxb.z;
					
					vtxa = p.a;
					
					if(p.surface.hideBackfaces) {
						
						z = camz - (gv.c * vtxa.x + gv.g * vtxa.y + gv.k * vtxa.z + gv.o);
						y = camy - (gv.b * vtxa.x + gv.f * vtxa.y + gv.j * vtxa.z + gv.n);
						x = camx - (gv.a * vtxa.x + gv.e * vtxa.y + gv.i * vtxa.z + gv.m);
					
						if(x*vtxb.wx + y*vtxb.wy + z*vtxb.wz < 0) continue;
					}
					
					pL = p.vLen;
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
					
					z = vtxa.wz;
					
					if(z < plw) {
						e = true;
						for(k=1; k<pL; k++) {
							vtxb = vtxs[k];
							if(vtxb.wz >= plw) {
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
							if(vtxb.wz <= farPlane) {
								e = false;
								break;
							}
						}
						if(e) continue;
					}
					
					if(vtxa.wy < -z) {
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
					else if(vtxa.wy > z) {
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
					
					if(vtxa.wx < -z) {
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
					else if(vtxa.wx > z) {
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
					
					e = true;
					for(k=0; k<pL; k++) {
						vtxb = vtxs[k];
						z = vtxb.wz;
						if(vtxb.wy > z || vtxb.wy < -z || vtxb.wx > z || vtxb.wx < -z || z < plw || z > farPlane) { // point culled
							e = false;
							break;
						}
					}
					if(e) {
						for(k=0; k<pL; k++) {
							vtxb = vtxs[k];
							if(vtxb.frameCounter2 != ofc) {
								vtxb.sx = vt + vtxb.wx/vtxb.wz * vt;
								vtxb.sy = vs - vtxb.wy/vtxb.wz * vs;
								vtxb.frameCounter2 = ofc;
							}
						}
						p.frameCounter = ofc;
						
						// draw Poly
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
						continue;
					}
					
					splitpts = new Vector.<Vertex>();
				
					// clip top plane ///////////////////////////
					vtxa = vtxs[0];
					clp1 = vtxa.wy > vtxa.wz;
					for(k=1; k<pL; k++) {
						
						vtxb = vtxs[k];
						clp2 = vtxb.wy > vtxb.wz;
						
						if(!clp1) splitpts.push( vtxa );
						if(clp1 != clp2) splitpts.push( splitVertexPlane(vtxa, vtxb, topPlane) );
						
						clp1 = clp2;
						vtxa = vtxb;
					}
					vtxb = vtxs[0];
					clp2 = vtxb.wy > vtxb.wz;
					if(!clp1) splitpts.push( vtxa );
					if(clp1 != clp2) splitpts.push( splitVertexPlane(vtxa, vtxb, topPlane) );
					
					
					
					pL = splitpts.length;
					if(pL < 2) continue;
					
					// clip bottom plane ///////////////////////////
					splitpts2 = new Vector.<Vertex>();
					vtxa = splitpts[0];
					clp1 = vtxa.wy < -vtxa.wz;
					for(k=1; k<pL; k++) {
						
						vtxb = splitpts[k];
						clp2 = vtxb.wy < -vtxb.wz;
						
						if(!clp1) splitpts2.push( vtxa );
						if(clp1 != clp2) splitpts2.push( splitVertexPlane(vtxa, vtxb, bottomPlane) );
						
						clp1 = clp2;
						vtxa = vtxb;
					}
					vtxb = splitpts[0];
					clp2 = vtxb.wy < -vtxb.wz;
					if(!clp1) splitpts2.push( vtxa );
					if(clp1 != clp2) splitpts2.push( splitVertexPlane(vtxa, vtxb, bottomPlane) );
					
					
					pL = splitpts2.length;
					if(pL < 2) continue;
					
					// clip left plane ///////////////////////////
					splitpts = new Vector.<Vertex>();
					vtxa = splitpts2[0];
					clp1 = vtxa.wx < -vtxa.wz;
					for(k=1; k<pL; k++) {
						
						vtxb = splitpts2[k];
						clp2 = vtxb.wx < -vtxb.wz;
						
						if(!clp1) splitpts.push( vtxa );
						if(clp1 != clp2) splitpts.push( splitVertexPlane(vtxa, vtxb, leftPlane) );
						
						clp1 = clp2;
						vtxa = vtxb;
					}
					vtxb = splitpts2[0];
					clp2 = vtxb.wx < -vtxb.wz;
					if(!clp1) splitpts.push( vtxa );
					if(clp1 != clp2) splitpts.push( splitVertexPlane(vtxa, vtxb, leftPlane) );
					
					
					
						
					pL = splitpts.length;
					if(pL < 2) continue;
					
					// clip right plane ///////////////////////////
					splitpts2 = new Vector.<Vertex>();
					vtxa = splitpts[0];
					clp1 = vtxa.wx > vtxa.wz;
					for(k=1; k<pL; k++) {
						
						vtxb = splitpts[k];
						clp2 = vtxb.wx > vtxb.wz;
						
						if(!clp1) splitpts2.push( vtxa );
						if(clp1 != clp2) splitpts2.push( splitVertexPlane(vtxa, vtxb, rightPlane) );
						
						clp1 = clp2;
						vtxa = vtxb;
					}
					vtxb = splitpts[0];
					clp2 = vtxb.wx > vtxb.wz;
					if(!clp1) splitpts2.push( vtxa );
					if(clp1 != clp2) splitpts2.push( splitVertexPlane(vtxa, vtxb, rightPlane) );
					
					
					
					pL = splitpts2.length;
					if(pL < 2) continue;
					
					// clip near plane ///////////////////////////
					splitpts = new Vector.<Vertex>();
					vtxa = splitpts2[0];
					clp1 = vtxa.wz < plw;
					for(k=1; k<pL; k++) {
						
						vtxb = splitpts2[k];
						clp2 = vtxb.wz < plw;
						
						if(!clp1) splitpts.push( vtxa );
						if(clp1 != clp2) splitpts.push( splitVertex(vtxb, vtxa) );
						
						clp1 = clp2;
						vtxa = vtxb;
					}
					vtxb = splitpts2[0];
					clp2 = vtxb.wz < v._nearClipping;
					if(!clp1) splitpts.push( vtxa );
					if(clp1 != clp2) splitpts.push( splitVertex(vtxb, vtxa) );
					
					pL = splitpts.length;
					
					if(pL> 1) {
						
						for(k=0; k<pL; k++) {
							vtxb = splitpts[k];
							if(vtxb.frameCounter2 != ofc) {
								vtxb.sx = vt + vtxb.wx/vtxb.wz * vt;
								vtxb.sy = vs - vtxb.wy/vtxb.wz * vs;
								vtxb.frameCounter2 = ofc;
							}
						}
						p.frameCounter = ofc;
						// drawPoly
						col = FlatAttributes(p.surface.attributes)._color32;
						pL--;
						for(k=0; k<pL; k++) {
							vtxa = splitpts[k];
							vtxb = splitpts[k+1];
							sl.drawLine(vtxa.sx, vtxa.sy, vtxb.sx, vtxb.sy, col, bmpd);
						}
						vtxa = splitpts[k];
						vtxb = splitpts[0];
						sl.drawLine(vtxa.sx, vtxa.sy, vtxb.sx, vtxb.sy, col, bmpd);
					}	
				}
			}
			
		}
	}
}
