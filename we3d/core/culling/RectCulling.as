package we3d.core.culling 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.math.Matrix3d;
	import we3d.mesh.Vertex;
	
	use namespace we3d;
	
	/**
	 * RectCulling culls like the BoxCulling but with a plane instead of a box (only 4 points). <br/> The RectCulling can be used on Flat plane like objects or sprites. <br/>
	 * <code>obj.objectCuller = new RectCulling();
	 * obj.objectCuller.testPoints( obj.points );
	 * </code>
	 */ 
	public class RectCulling extends BoundBox implements IObjectCulling
	{
		public function RectCulling () {}
		
		we3d var wmaxx:Number=0;
		we3d var wmaxy:Number=0;
		we3d var wmaxz:Number=0;
		
		we3d var wminx:Number=0;
		we3d var wminy:Number=0;
		we3d var wminz:Number=0;
		
		public function cull (obj:Object3d, cam:Camera3d) :Boolean 
		{
			var cam_cgv:Matrix3d = obj.camMatrix;
			cam_cgv.concatM4(obj.transform.gv, cam.cgv, cam_cgv);
			
			var x:Number = minx;	
			var y:Number = miny; 	
			var z:Number = minz;
			
			wminz = cam_cgv.c*x + cam_cgv.g*y + cam_cgv.k*z + cam_cgv.o + cam._nearClipping;
			wminy = cam_cgv.b*x + cam_cgv.f*y + cam_cgv.j*z + cam_cgv.n;
			wminx = cam_cgv.a*x + cam_cgv.e*y + cam_cgv.i*z + cam_cgv.m;
			
			if( wminx >= -wminz && wminx <= wminz && 
				wminy >= -wminz && wminy <= wminz &&
				wminz >= cam._nearClipping && wminz <= cam._farClipping ) return false;
			
			x = maxx;
			y = maxy;
			z = maxz;
			
			wmaxz = cam_cgv.c*x + cam_cgv.g*y + cam_cgv.k*z + cam_cgv.o + cam._nearClipping;
			wmaxy = cam_cgv.b*x + cam_cgv.f*y + cam_cgv.j*z + cam_cgv.n;
			wmaxx = cam_cgv.a*x + cam_cgv.e*y + cam_cgv.i*z + cam_cgv.m;
			
			if( wmaxx >= -wmaxz && wmaxx <= wmaxz &&
				wmaxy >= -wmaxz && wmaxy <= wmaxz &&
				wmaxz >= cam._nearClipping && wmaxz <= cam._farClipping) return false;
			
			var L:int = points.length;
			var i:int;
			var p:Vertex;
			
			// translate all points of bounding box
			for(i=2; i<L; i++) {
				p = points[i];
				p.wx = cam_cgv.a*p.x + cam_cgv.e*p.y + cam_cgv.i*p.z + cam_cgv.m;
				p.wy = cam_cgv.b*p.x + cam_cgv.f*p.y + cam_cgv.j*p.z + cam_cgv.n;
				p.wz = cam_cgv.c*p.x + cam_cgv.g*p.y + cam_cgv.k*p.z + cam_cgv.o + cam._nearClipping;
			}
			
			var e:Boolean;
			
			if(wminz < cam._nearClipping && wmaxz < cam._nearClipping) { // near plane
				e = true;
				for(i=2; i<L; i++) {
					p = points[i];
					if(p.wz >= cam._nearClipping) {
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
			r.testPoint(points[0].x, points[0].y, points[0].z);
			r.testPoint(points[1].x, points[1].y, points[1].z);
			return r;
		}
	}
}