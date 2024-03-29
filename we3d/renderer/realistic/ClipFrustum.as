package we3d.renderer.realistic 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.math.Matrix3d;
	import we3d.mesh.Face;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;
	import we3d.renderer.ClipUtil;
	import we3d.renderer.IRenderer;
	import we3d.renderer.RenderSession;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/**
	* Polygon clipping against the five frustum planes of the camera (left, top, right, bottom and near).
	*/
	public class ClipFrustum extends ClipUtil implements IRenderer 
	{
		public function ClipFrustum () {}
		
		public function draw (session:RenderSession) :void {
			
			var objectList:Vector.<Object3d>  = session.scene.objectList;
			var objs:int = objectList.length;
			var farPlane:Number = session.camera._farClipping;
			
			plw = session.camera._nearClipping == 0 ? .0005 : session.camera._nearClipping;
			var vt:Number = session.camera.t;
			var vs:Number = session.camera.s;
			
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
			var vtxb:Vertex;
			var splitpts:Vector.<Vertex>;
			var splitpts2:Vector.<Vertex>;
			var vtxa:Vertex;
			var uvs:Vector.<UVCoord>;
			var splituvs:Vector.<UVCoord>;
			var splituvs2:Vector.<UVCoord>;
			var u:UVCoord;
			var u0:UVCoord;
			var splitface:Face;
			var e:Boolean;
			
			var x:Number;	var y:Number;	var z:Number;
			var ofc:int;
			
			var cgv:Matrix3d;
			var cgva:Number;	var cgvb:Number;	var cgvc:Number;
			var cgve:Number;	var cgvf:Number;	var cgvg:Number;
			var cgvi:Number;	var cgvj:Number;	var cgvk:Number;
			var cgvm:Number;	var cgvn:Number;	var cgvo:Number;
			
			var gv:Matrix3d;
			var gva:Number;	var gvb:Number;	var gvc:Number;
			var gve:Number;	var gvf:Number;	var gvg:Number;
			var gvi:Number;	var gvj:Number;	var gvk:Number;
			var gvm:Number;	var gvn:Number;	var gvo:Number;
			
			var camx:Number = session.camera.transform.worldX;
			var camy:Number = session.camera.transform.worldY;
			var camz:Number = session.camera.transform.worldZ;
			var sessionPlgCount:int;
			var session_sortPolys:Boolean;
			var session_polys:Array;
			
			for(i=0; i<objs; i++) {
				
				o = SceneObject(objectList[i]);
				if(o.initFrame(session)) continue;
				if(o.initMesh(session)) continue;
				
				session_polys = session.polys;
				sessionPlgCount = session_polys.length;
				session_sortPolys = session.sortPolys;
				
				r = o.polygons;
				L = r.length;
				
				ofc = o.frameCounter;
				
				gv = o.transform.gv;
				gva = gv.a;	gvb = gv.b;	gvc = gv.c;
				gve = gv.e;	gvf = gv.f;	gvg = gv.g;
				gvi = gv.i;	gvj = gv.j;	gvk = gv.k;
				gvm = gv.m;	gvn = gv.n;	gvo = gv.o;
				
				cgv = o.camMatrix;
				cgva = cgv.a;	cgvb = cgv.b;	cgvc = cgv.c;
				cgve = cgv.e;	cgvf = cgv.f;	cgvg = cgv.g;
				cgvi = cgv.i;	cgvj = cgv.j;	cgvk = cgv.k;
				cgvm = cgv.m;	cgvn = cgv.n;	cgvo = cgv.o + plw;
				
				for(j=0; j<L; j++) {
					
					p = r[j];
					pL = p.vLen;
					
					vtxa = p.a;
					
					
					if(pL < 3) {
						if(pL < 2) continue;
					}
					else
					{
						vtxb = p.normal;
						vtxb.wz = gvc * vtxb.x + gvg * vtxb.y + gvk * vtxb.z;
						vtxb.wy = gvb * vtxb.x + gvf * vtxb.y + gvj * vtxb.z;
						vtxb.wx = gva * vtxb.x + gve * vtxb.y + gvi * vtxb.z;
						
						if(p.surface.hideBackfaces) {
							z = camz - (gvc * vtxa.x + gvg * vtxa.y + gvk * vtxa.z + gvo);
							y = camy - (gvb * vtxa.x + gvf * vtxa.y + gvj * vtxa.z + gvn);
							x = camx - (gva * vtxa.x + gve * vtxa.y + gvi * vtxa.z + gvm);
							if(x*vtxb.wx + y*vtxb.wy + z*vtxb.wz < 0) continue;
						}
					}
					
					vtxs = p.vtxs;
					
					e = true;
					for(k=0; k<pL; k++) {
						vtxb = vtxs[k];
						if(vtxb.frameCounter1 != ofc) {
							vtxb.wz = cgvc * vtxb.x + cgvg * vtxb.y + cgvk * vtxb.z + cgvo;
							vtxb.wy = cgvb * vtxb.x + cgvf * vtxb.y + cgvj * vtxb.z + cgvn;
							vtxb.wx = cgva * vtxb.x + cgve * vtxb.y + cgvi * vtxb.z + cgvm;
							vtxb.frameCounter1 = ofc;
							
							z = vtxb.wz;
							vtxb.culled = (z < plw || z > farPlane || vtxb.wy > z || vtxb.wy < -z || vtxb.wx > z || vtxb.wx < -z);
							
							if(!vtxb.culled) {
								vtxb.frameCounter2 = ofc;
								vtxb.sx = vt + vtxb.wx/z * vt;
								vtxb.sy = vs - vtxb.wy/z * vs;
							}
						}
						
						if(e && vtxb.culled) {
							e = false;
						}
					}
					
					if(e) {
						// all points in frustum
						p.frameCounter = ofc;
						
						if(session_sortPolys) {
							p.z = cgvc*p.ax + cgvg*p.ay + cgvk*p.az + cgvo + p.sortFar;
							session_polys[sessionPlgCount] = p;
							sessionPlgCount++;
						}else{
							p.surface.rasterizer.draw(p.surface, session, p);
						}
						continue;
					}
					
					z = vtxa.wz;
					
					// test if all points are culled to the frustum
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
					
					// clip polygon
					splitpts = new Vector.<Vertex>();
					
					if(p.uvs == null) {
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
						clp2 = vtxb.wz < plw;
						if(!clp1) splitpts.push( vtxa );
						if(clp1 != clp2) splitpts.push( splitVertex(vtxb, vtxa) );
					
						pL = splitpts.length;
						
						if(pL> 1) {
							
							splitface = new Face();
							splitface.surface = p.surface;
							splitface.vLen = pL;
							splitface.vtxs = splitpts;
							splitface.a = splitpts[0];
							splitface.b = splitpts[1];
							
							if(pL > 2) 
							{
								splitface.c = splitpts[2];
								splitface.normal.wx = p.normal.wx;
								splitface.normal.wy = p.normal.wy;
								splitface.normal.wz = p.normal.wz;
							}
							
							splitface.ax = p.ax;
							splitface.ay = p.ay;
							splitface.az = p.az;
							
							splitface.so = p.so;
							splitface.frameCounter = ofc;
							
							for(k=0; k<pL; k++) {
								vtxb = splitpts[k];
								if(vtxb.frameCounter2 != ofc) {
									vtxb.sx = vt + vtxb.wx/vtxb.wz * vt;
									vtxb.sy = vs - vtxb.wy/vtxb.wz * vs;
									vtxb.frameCounter2 = ofc;
								}
							}
							
							if(session_sortPolys) {
								splitface.z = cgvc*splitface.ax + cgvg*splitface.ay + cgvk*splitface.az + cgvo + p.sortFar;
								session_polys[sessionPlgCount] = splitface;
								sessionPlgCount++;
							}else{
								splitface.surface.rasterizer.draw(splitface.surface, session, splitface);
							}
						}
						
					}
					else {
						
						// clip with uv
						uvs = p.uvs;
						
						splituvs = new Vector.<UVCoord>();
						
						// clip top plane ///////////////////////////
						vtxa = vtxs[0];
						u0 = uvs[0];
						clp1 = vtxa.wy > vtxa.wz;
						
						for(k=1; k<pL; k++) {
							
							vtxb = vtxs[k];
							u = uvs[k];
							
							clp2 = vtxb.wy > vtxb.wz;
							
							if(!clp1) {
								splitpts.push( vtxa );
								splituvs.push( u0 );
							}
							if(clp1 != clp2) splitVertexUVPlane(vtxb, vtxa, topPlane, u, u0, splitpts, splituvs);
							
							clp1 = clp2;
							vtxa = vtxb;
							u0 = u;
						}
						
						vtxb = vtxs[0];
						u = uvs[0];
						clp2 = vtxb.wy > vtxb.wz;
						if(!clp1) {
							splitpts.push( vtxa );
							splituvs.push( u0 );
						}
						if(clp1 != clp2) splitVertexUVPlane(vtxb, vtxa, topPlane, u, u0, splitpts, splituvs);
						
						pL = splitpts.length;
						if(pL < 2) continue;
						
						// clip bottom plane ///////////////////////////
						splitpts2 = new Vector.<Vertex>();
						splituvs2 = new Vector.<UVCoord>();
						
						vtxa = splitpts[0];
						u0 = splituvs[0];
						clp1 = vtxa.wy < -vtxa.wz;
						for(k=1; k<pL; k++) {
							
							vtxb = splitpts[k];
							u = splituvs[k];
							
							clp2 = vtxb.wy < -vtxb.wz;
							
							if(!clp1) {
								splitpts2.push( vtxa );
								splituvs2.push( u0 );
							}
							if(clp1 != clp2) splitVertexUVPlane(vtxb, vtxa, bottomPlane, u, u0, splitpts2, splituvs2);
							
							clp1 = clp2;
							vtxa = vtxb;
							u0 = u;
						}
						
						vtxb = splitpts[0];
						u = splituvs[0];
						clp2 = vtxb.wy < -vtxb.wz;
						if(!clp1) {
							splitpts2.push( vtxa );
							splituvs2.push( u0 );
						}
						if(clp1 != clp2) splitVertexUVPlane(vtxb, vtxa, bottomPlane, u, u0, splitpts2, splituvs2);
						
						
						pL = splitpts2.length;
						if(pL < 2) continue;
						
						// clip left plane ///////////////////////////
						splitpts = new Vector.<Vertex>();
						splituvs = new Vector.<UVCoord>();
						vtxa = splitpts2[0];
						u0 = splituvs2[0];
						clp1 = vtxa.wx < -vtxa.wz;
						
						for(k=1; k<pL; k++) {
							
							vtxb = splitpts2[k];
							u = splituvs2[k];
							clp2 = vtxb.wx < -vtxb.wz;
							
							if(!clp1) {
								splitpts.push( vtxa );
								splituvs.push( u0 );
							}
							if(clp1 != clp2) {
								splitVertexUVPlane(vtxb, vtxa, leftPlane, u, u0, splitpts, splituvs);
							}
							
							clp1 = clp2;
							vtxa = vtxb;
							u0 = u;
						}
						vtxb = splitpts2[0];
						u = splituvs2[0];
						clp2 = vtxb.wx < -vtxb.wz;
						if(!clp1) {
							splitpts.push( vtxa );
							splituvs.push( u0 );
						}
						if(clp1 != clp2) splitVertexUVPlane(vtxb, vtxa, leftPlane, u, u0, splitpts, splituvs);
						
						
						pL = splitpts.length;
						if(pL < 2) continue;
						
						// clip right plane ///////////////////////////
						splitpts2 = new Vector.<Vertex>();;
						splituvs2 = new Vector.<UVCoord>();
						vtxa = splitpts[0];
						u0 = splituvs[0];
						clp1 = vtxa.wx > vtxa.wz;
						for(k=1; k<pL; k++) {
							
							vtxb = splitpts[k];
							u = splituvs[k];
							clp2 = vtxb.wx > vtxb.wz;
							
							if(!clp1) {
								splitpts2.push( vtxa );
								splituvs2.push( u0 );
							}
							if(clp1 != clp2) splitVertexUVPlane(vtxb, vtxa, rightPlane, u, u0, splitpts2, splituvs2);
							
							clp1 = clp2;
							vtxa = vtxb;
							u0 = u;
						}
						vtxb = splitpts[0];
						u = splituvs[0];
						clp2 = vtxb.wx > vtxb.wz;
						if(!clp1) {
							splitpts2.push( vtxa );
							splituvs2.push( u0 );
						}
						if(clp1 != clp2) splitVertexUVPlane(vtxb, vtxa, rightPlane, u, u0, splitpts2, splituvs2);
						
						
						pL = splitpts2.length;
						if(pL < 2) continue;
						
						// clip near plane ///////////////////////////
						splitpts = new Vector.<Vertex>();
						splituvs = new Vector.<UVCoord>();
						vtxa = splitpts2[0];
						u0 = splituvs2[0];
						clp1 = vtxa.wz < plw;
						for(k=1; k<pL; k++) {
							
							vtxb = splitpts2[k];
							u = splituvs2[k];
							clp2 = vtxb.wz < plw;
							
							if(!clp1) {
								splitpts.push( vtxa );
								splituvs.push( u0 );
							}
							if(clp1 != clp2)  splitVertexUV(vtxb, vtxa, u, u0, splitpts, splituvs);
							
							clp1 = clp2;
							vtxa = vtxb;
							u0 = u;
						}
						
						vtxb = splitpts2[0];
						u = splituvs2[0];
						clp2 = vtxb.wz < plw;
						if(!clp1) {
							splitpts.push( vtxa );
							splituvs.push( u0 );
						}
						if(clp1 != clp2) splitVertexUV(vtxb, vtxa, u, u0, splitpts, splituvs);
						
						
						pL = splitpts.length;
						
						if(pL > 1) {
							
							splitface = new Face();
							splitface.surface = p.surface;
							splitface.vLen = pL;
							splitface.vtxs = splitpts;
							splitface.a = splitpts[0];
							splitface.b = splitpts[1];
							if(pL > 2) 
							{
								splitface.c = splitpts[2];
								
								splitface.u1 = splituvs[0].u;
								splitface.v1 = splituvs[0].v;
								
								splitface.u2 = splituvs[1].u;
								splitface.v2 = splituvs[1].v;
								
								splitface.u3 = splituvs[2].u;
								splitface.v3 = splituvs[2].v;
								
								splitface.normal.wx = p.normal.wx;
								splitface.normal.wy = p.normal.wy;
								splitface.normal.wz = p.normal.wz;
								
								splitface.uvs = splituvs;
							}
							
							splitface.ax = p.ax;
							splitface.ay = p.ay;
							splitface.az = p.az;
							splitface.so = p.so;
													
							splitface.frameCounter = ofc;
							
							for(k=0; k<pL; k++) {
								vtxb = splitpts[k];
								if(vtxb.frameCounter2 != ofc) {
									vtxb.sx = vt + vtxb.wx/vtxb.wz * vt;
									vtxb.sy = vs - vtxb.wy/vtxb.wz * vs;
									vtxb.frameCounter2 = ofc;
								}
							}
							
							if(session_sortPolys) 
							{
								splitface.z = cgvc*splitface.ax + cgvg*splitface.ay + cgvk*splitface.az + cgvo + p.sortFar;
								session_polys[sessionPlgCount] = splitface;
								sessionPlgCount++;
							}else{
								splitface.surface.rasterizer.draw(splitface.surface, session, splitface);
							}
						}
					}
				}
			}
		}
		
	}
}
