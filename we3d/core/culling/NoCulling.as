package we3d.core.culling 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.mesh.Vertex;

	use namespace we3d;
	
	/**
	* No Object culling.
	*/
	public class NoCulling implements IObjectCulling
	{
		public function NoCulling () {}
		
		public function reset () :void {}
		public function clearPoint (x:Number, y:Number, z:Number) :void {}
		public function testPoint (x:Number, y:Number, z:Number) :void {}
		public function testPoints (pts:Vector.<Vertex>) :void {}
		public function containsPoint (x:Number, y:Number, z:Number) :Boolean { return false; }
		
		public function cull (obj:Object3d, cam:Camera3d) :Boolean 
		{
			obj.camMatrix.concatM4(obj.transform.gv, cam.cgv, obj.camMatrix);	
			return false; 
		}
		
		public function clone () :IObjectCulling {
			return new NoCulling();
		}
		
	}
}