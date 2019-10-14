package we3d.core.culling 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.math.Matrix3d;
	
	use namespace we3d;
	
	/**
	* Deprecated. object culling, camera frustum - object sphere.
	* The objects may cull to early, the frustum planes can be controlled with cullScale properties
	*/
	public class SphereCulling extends BoundSphere implements IObjectCulling
	{
		public function SphereCulling (scaleH:Number=1, scaleV:Number=1) {
			cullScaleX = scaleH;
			cullScaleY = scaleV;
		}
		
		public var cullScaleX:Number=1;
		public var cullScaleY:Number=1;
		
		public function cull (obj:Object3d, cam:Camera3d) :Boolean 
		{
			if(bSphere == 0) return true;
			
			var ov:Matrix3d = obj.transform.gv;
			var px:Number = ov.m;	
			var py:Number = ov.n;	
			var pz:Number = ov.o;
			
			var rv:Matrix3d = cam.cgv;
			var z1:Number = rv.c*px + rv.g*py + rv.k*pz + rv.o + cam._nearClipping;
			
			if(z1 + bSphere < cam._nearClipping) return true;
			if(z1 - bSphere > cam._farClipping) return true;
			
			var ct:Matrix3d = cam.transform.gv;
			var cm:Number = ct.m;
			var cn:Number = ct.n;
			var co:Number = ct.o;
			
			var dx:Number = cm - px;
			var dy:Number = cn - py;
			var dz:Number = co - pz;
			
			if(dx*dx + dy*dy + dz*dz <= bSphereQ) {
				ov.concatM4(ov, rv, obj.camMatrix);
				return false;
			}
			
			var mz:Number = -z1;
			
			var bsx:Number = cm + ct.a*bSphere + ct.i*mz;
			var bsy:Number = cn + ct.b*bSphere + ct.j*mz;
			var bsz:Number = co + ct.c*bSphere + ct.k*mz;
			var s:Number = rv.a*bsx + rv.e*bsy + rv.i*bsz + rv.m;
			
			var y1:Number = (rv.b*px + rv.f*py + rv.j*pz + rv.n) * cullScaleY;
			if((y1 + s) <  mz) return true;
			if((y1 - s) >  z1) return true;
			
			var x1:Number = (rv.a*px + rv.e*py + rv.i*pz + rv.m) * cullScaleX;
			if((x1 + s) <  mz) return true;
			if((x1 - s) >  z1) return true;
			
			ov.concatM4(ov, rv, obj.camMatrix);
			
			return false;
		}
		
		public function clone () :IObjectCulling {
			var r:SphereCulling = new SphereCulling(cullScaleX,cullScaleY);
			r.testPoint(0,0,boundingSphere);
			return r;
		}
	}
}