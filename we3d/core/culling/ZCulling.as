package we3d.core.culling 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.math.Matrix3d;
	
	use namespace we3d;
	
	/**
	* Object culling, camera near and far plane - object sphere. ZCulling is the fastest culler. But the render may take longer if not as much objects are culled as with the default BoxCulling
	*/
	public class ZCulling extends BoundSphere implements IObjectCulling
	{
		public function ZCulling () {}
		
		public function cull (obj:Object3d, cam:Camera3d) :Boolean 
		{
			if(bSphere == 0) return true;
			
			var rv:Matrix3d = obj.transform.gv;
			var cgv:Matrix3d = cam.cgv;
			
			var z1:Number = cgv.c*rv.m + cgv.g*rv.n + cgv.k*rv.o + cgv.o + cam._nearClipping;
			
			if(z1 + bSphere < cam._nearClipping) return true;
			if(z1 - bSphere > cam._farClipping) return true;
			
			cgv.concatM4(rv, cgv, obj.camMatrix);
			
			return false;
		}
		public function clone () :IObjectCulling {
			var r:ZCulling = new ZCulling();
			r.testPoint(0,0,boundingSphere);
			return r;
		}
	}
}