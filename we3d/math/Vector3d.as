package we3d.math
{
	public class Vector3d 
	{
		public function Vector3d (ax:Number=0, ay:Number=0, az:Number=0) {
			x = ax;
			y = ay;
			z = az;
		}
		
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function assign( ax:Number, ay:Number, az:Number) :void {
			x = ax;
			y = ay;
			z = az;
		}
		
		public function toString (dp:int=-1) :String {
			if(dp > 0) {
				return x.toFixed(dp) + ", "  + y.toFixed(dp) + ", " + z.toFixed(dp); 
			}else{
				return x+", "+y+", "+z;
			}
		}
		
		public function assignVector (newVect:Vector3d) :void {
			x = newVect.x;
			y = newVect.y;
			z = newVect.z;
		}
		
		public function normalize () :void {
			var m:Number = Math.sqrt(x*x + y*y + z*z);
			x /= m;
			y /= m;
			z /= m;
		}
		
		public function dot (v:Vector3d) :Number {			
			return x * v.x + y * v.y + z * v.z;
		}
		
		public function magnitude () :Number {
			return Math.sqrt(x*x + y*y + z*z); 
		}
		
		public function cross (v2:Vector3d, rv:Vector3d) :void {
			rv.x = y * v2.z - z * v2.y;
			rv.y = z * v2.x - x * v2.z;
			rv.z = x * v2.y - y * v2.x;
		}
		
		public function distanceTo (v2:Vector3d) :Number {
			var a:Number = v2.x-x;
			var b:Number = v2.y-y;
			var c:Number = v2.z-z;
			
			return Math.sqrt(a*a+b*b+c*c);
		}
		
		public function clone () :Vector3d {
			return new Vector3d(x,y,z);
		}
		
	}
	
}
