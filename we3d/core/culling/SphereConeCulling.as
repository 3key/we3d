package we3d.core.culling 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.math.Matrix3d;
	
	use namespace we3d;
	
	/**
	* Deprecated. culls the object against a cycle instead of the 4 camera planes. But it is slower than BoxCulling
	*/
	public class SphereConeCulling extends BoundSphere implements IObjectCulling
	{
		public function SphereConeCulling (fov:Number=0.9) { camFov = fov; }
		
		public var camFov:Number=0.9;
		
		public function cull (obj:Object3d, cam:Camera3d) :Boolean 
		{
			var b:Number = bSphere;
			if(b == 0) return true;
			
			var nvx:Number;
			var nvy:Number;
			var nvz:Number;
			var mn:Number;
			var d:Number;
			
			var rv:Matrix3d = cam.transform.gv;
			
			var zax:Number = rv.i;
			var zay:Number = rv.j;
			var zaz:Number = rv.k;
			
			var wpx:Number = rv.m;
			var wpy:Number = rv.n;
			var wpz:Number = rv.o;
			
			nvx = obj.transform.gv.m-wpx;
			nvy = obj.transform.gv.n-wpy;
			nvz = obj.transform.gv.o-wpz;
			if(nvx*nvx + nvy*nvy + nvz*nvz >= cam._farClipping*cam._farClipping + bSphereQ) return true;
			
			nvx += b*zax;
			nvy += b*zay;
			nvz += b*zaz;
			
			d = nvx*zax+nvy*zay+nvz*zaz;
			if(d <= 0) return true;
			
			mn = Math.sqrt(nvx*nvx + nvy*nvy + nvz*nvz)+0.0000003;
			if(Math.acos(d/mn) >= camFov) return true;
			
			var cam_cgv:Matrix3d = obj.camMatrix;
			cam_cgv.concatM4(obj.transform.gv, cam.cgv, cam_cgv);
			
			return false;
		}
		
		public function clone () :IObjectCulling {
			var r:SphereConeCulling = new SphereConeCulling(camFov);
			r.testPoint(0,0,boundingSphere);
			return r;
		}
	}
}