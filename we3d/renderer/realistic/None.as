package we3d.renderer.realistic 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.math.Matrix3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.IRenderer;
	import we3d.renderer.RenderSession;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/**
	* Object Culling, Backface Culling
	*/
	public class None implements IRenderer 
	{
		public function None () {}
		
		public var renderedObjects:int=-1;
		
		public function draw (session:RenderSession) :void {
			
			var f:Number = session.currentFrame;
			var v:Camera3d = session.camera;
			var objectList:Vector.<Object3d>  = session.scene.objectList;
			var objs:int = objectList.length;
			var cgv:Matrix3d;
			
			var gv:Matrix3d;
			var p:Face;
			var o:SceneObject;
			var i:int;
			var j:int;
			var k:int;
			var L:int;
			var pL:int;
			var r:Vector.<Face>;
			var ofc:int;
			var vtxs:Vector.<Vertex>;
			var vtxa:Vertex;
			var vtxb:Vertex;
			
			var rObjCount:int=0;
			
			var vt:Number = v.t;	var vs:Number = v.s;
			var v_nearClipping:Number = v._nearClipping;
			var sessionPlgCount:int;
			var session_sortPolys:Boolean;
			
			for(i=0; i<objs; i++) {
				
				o = SceneObject(objectList[i]);
				if(o.initFrame(session)) continue;
				if(o.initMesh(session)) continue;
				
				sessionPlgCount = session.polys.length;
				session_sortPolys = session.sortPolys;
				
				rObjCount++;
				
				r = o.polygons;
				L = r.length;
				
				ofc = o.frameCounter;
				gv = o.transform.gv;
				cgv = o.camMatrix;
				
				for(j=0; j<L; j++) {
					
					p = r[j];
					pL = p.vLen;
					if(pL < 2) continue;
										
					vtxs = p.vtxs;
					
					for(k=0; k<pL; k++) {
						vtxb = vtxs[k];
						if(vtxb.frameCounter2 != ofc) {
							vtxb.wz = cgv.c * vtxb.x + cgv.g * vtxb.y + cgv.k * vtxb.z + cgv.o;
							vtxb.wy = cgv.b * vtxb.x + cgv.f * vtxb.y + cgv.j * vtxb.z + cgv.n;
							vtxb.wx = cgv.a * vtxb.x + cgv.e * vtxb.y + cgv.i * vtxb.z + cgv.m + v_nearClipping;
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
					
					if(session_sortPolys) {
						p.z = cgv.c*p.ax + cgv.g*p.ay + cgv.k*p.az + cgv.o + p.sortFar;
						session.polys[sessionPlgCount++] = p;
					}else{
						p.surface.rasterizer.draw(p.surface, session, p);
					}
				}
			}
			
			renderedObjects = rObjCount;
			
		}
		
	}
}