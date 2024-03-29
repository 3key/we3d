package we3d.core.culling 
{
	import we3d.we3d;
	import we3d.mesh.Vertex;

	use namespace we3d;
	
	/**
	* @private
	*/
	public class BoundSphere 
	{
		public function BoundSphere () {}
		
		we3d var bSphere:Number=0;
		we3d var bSphereQ:Number=0;
		
		public function set boundingSphere (v:Number) :void {
			bSphere = v;
			bSphereQ = v*v;
		}
		public function get boundingSphere () :Number {
			return bSphere;
		}
		
		public function reset () :void {
			boundingSphere = 0;
		}
		
		public function containsPoint (x:Number, y:Number, z:Number) :Boolean {
			var l:Number = x*x + y*y + z*z;
			return l <= bSphereQ;
		}
		
		public function testPoint (x:Number, y:Number, z:Number) :void {
			var l:Number = x*x + y*y + z*z;
			if(l > bSphereQ) boundingSphere = Math.sqrt(l);
		}
		
		public function testPoints (pts:Vector.<Vertex>) :void {
			var L:int=pts.length;
			var v:Vertex;
			for(var i:int=0; i<L; i++) 
			{
				v = pts[i];
				testPoint(v.x, v.y, v.z);
			}
		}
		
	}
	
}