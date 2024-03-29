package we3d.core.culling 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.math.Matrix3d;
	import we3d.mesh.Vertex;
	
	use namespace we3d;
	
	/**
	* Default culling, bounding box object culling. <br/>
	* The BoxCulling is set by default. It processes the object culling while rendering. <br/>
	 * If you add points directly to the points list of a SceneObject or if you animate points in a SceneObject then you have to update the bounding box.
	 * <br/><code> obj.objectCuller.testPoint( x,y,z ); // test a point, if its outside the boundig box, the box will be updated
	 * //or test a set of points
	 * obj.objectCuller.testPoints( obj.points );
	 * </code>
	 * If the Bounding Box is not up to date, the object may be culled to early (or in worst case never rendered) or to late.
	*/ 
	public class BoxCulling extends BoundBox implements IObjectCulling
	{
		public function BoxCulling () {}
		
		public var wmaxx:Number=0;
		public var wmaxy:Number=0;
		public var wmaxz:Number=0;
		
		public var wminx:Number=0;
		public var wminy:Number=0;
		public var wminz:Number=0;
		
		public function cull (obj:Object3d, cam:Camera3d) :Boolean 
		{
			var cam_cgv:Matrix3d = obj.camMatrix;
			cam_cgv.concatM4(obj.transform.gv, cam.cgv, cam_cgv);
			
			var cn:Number = cam._nearClipping;
			
			wminz = cam_cgv.c*minx + cam_cgv.g*miny + cam_cgv.k*minz + cam_cgv.o + cn;
			wminy = cam_cgv.b*minx + cam_cgv.f*miny + cam_cgv.j*minz + cam_cgv.n;
			wminx = cam_cgv.a*minx + cam_cgv.e*miny + cam_cgv.i*minz + cam_cgv.m;
			
			if( wminx >= -wminz && wminx <= wminz && 
				wminy >= -wminz && wminy <= wminz &&
				wminz >= cam._nearClipping && wminz <= cam._farClipping ) return false;
			
			wmaxz = cam_cgv.c*maxx + cam_cgv.g*maxy + cam_cgv.k*maxz + cam_cgv.o + cam._nearClipping;
			wmaxy = cam_cgv.b*maxx + cam_cgv.f*maxy + cam_cgv.j*maxz + cam_cgv.n;
			wmaxx = cam_cgv.a*maxx + cam_cgv.e*maxy + cam_cgv.i*maxz + cam_cgv.m;
			
			if( wmaxx >= -wmaxz && wmaxx <= wmaxz &&
				wmaxy >= -wmaxz && wmaxy <= wmaxz &&
				wmaxz >= cn && wmaxz <= cam._farClipping) return false;
			
			var L:int = ptLen;
			var i:int;
			var p:Vertex;
			
			// translate all points of bounding box
			for(i=2; i<L; i++) {
				p = points[i];
				p.wx = cam_cgv.a*p.x + cam_cgv.e*p.y + cam_cgv.i*p.z + cam_cgv.m;
				p.wy = cam_cgv.b*p.x + cam_cgv.f*p.y + cam_cgv.j*p.z + cam_cgv.n;
				p.wz = cam_cgv.c*p.x + cam_cgv.g*p.y + cam_cgv.k*p.z + cam_cgv.o + cn;
			}
			
			var e:Boolean;
			
			if(wminz < cn && wmaxz < cn) { // near plane
				e = true;
				for(i=2; i<L; i++) {
					p = points[i];
					if(p.wz >= cn) {
						e = false;
						break;
					}
				}
				if(e) return true;
			}
			
			if(wminz > cam._farClipping && wmaxz > cam._farClipping) { // far plane
				e = true;
				for(i=2; i<L; i++) {
					p = points[i];
					if(p.wz <= cam._farClipping) {
						e = false;
						break;
					}
				}
				if(e) return true;
			}
			
			if(wminy < -wminz && wmaxy < -wmaxz) { // top plane
				e = true;
				for(i=2; i<L; i++) {
					p = points[i];
					if(p.wy >= -p.wz) {
						e = false;
						break;
					}
				}
				if(e) return true;
			}
			else if(wminy > wminz && wmaxy > wmaxz) { // bottom plane
				e = true;
				for(i=2; i<L; i++) {
					p = points[i];
					if(p.wy < p.wz) {
						e = false;
						break;
					}
				}
				if(e) return true;
			}
			
			if(wminx < -wminz && wmaxx < - wmaxz) { // left plane
				e = true;
				for(i=2; i<L; i++) {
					p = points[i];
					if(p.wx >= -p.wz) {
						e = false;
						break;
					}
				}
				if(e) return true;
			}
			else if(wminx > wminz && wmaxx > wmaxz) { // right plane
				e = true;
				for(i=2; i<L; i++) {
					p = points[i];
					if(p.wx <= p.wz) {
						e = false;
						break;
					}
				}
				if(e) return true;
			}
			
			return false;
		}
		
		public function clone () :IObjectCulling {
			var r:BoxCulling = new BoxCulling();
			if(points.length>0) r.testPoint(points[0].x, points[0].y, points[0].z);
			if(points.length>1) r.testPoint(points[1].x, points[1].y, points[1].z);
			return r;
		}
	}
}