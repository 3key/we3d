package we3d.math 
{
	import we3d.mesh.Vertex;
	
	public class Plane 
	{
		public function Plane (ax:Number=0, ay:Number=0, az:Number=0, aw:Number=0) {
			x = ax;
			y = ay;
			z = az;
			w = aw;
		}
		
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var w:Number;
		
		
		public static var NEGATIVE:int = -1;
		public static var POSITIVE:int = 1;
		public static var ON_PLANE:int = 0;
		
		public function create (a:Vertex, b:Vertex, c:Vertex) :void {
			var x1:Number = b.x-a.x;
			var y1:Number = b.y-a.y;
			var z1:Number = b.z-a.z;
			
			var x2:Number = c.x-a.x;
			var y2:Number = c.y-a.y;
			var z2:Number = c.z-a.z;
			
			x = y1 * z2 - z1 * y2;
			y = z1 * x2 - x1 * z2;
			z = x1 * y2 - y1 * x2;
			
			var m:Number = Math.sqrt(x*x + y*y + z*z);
			x /= m;
			y /= m;
			z /= m;
			
			w = x * a.x + y * a.y + z * a.z;
		}
		
		public function createFromNormalAndPoint (nx:Number=0, ny:Number=0, nz:Number=0,
												  px:Number=0, py:Number=0, pz:Number=0) :void {
			x = nx;
			y = ny;
			z = nz;
			
			w = -(nx*px + ny*py + nz*pz);
		}
		
		public function distanceToPoint (px:Number=0, py:Number=0, pz:Number=0) :Number {
			return x * px + y * py + z * pz + w;
		}
		
		public function classifyPoint (px:Number=0, py:Number=0, pz:Number=0) :int {
			var d:Number;
			d = distanceToPoint( px, py, pz );
			
			if (d < 0){
				return NEGATIVE;
			}else if (d > 0){
				return POSITIVE;
			}
			return ON_PLANE;
		}
		
		public function splitPoint (v0:Vertex, v1:Vertex) :Vertex {
			var d0:Number = x * v0.x + y * v0.y + z * v0.z - w;
			var d1:Number = x * v1.x + y * v1.y + z * v1.z - w;
			
			var m:Number = d1 / ( d1 - d0 );
			
			return new Vertex(	v1.x + ( v0.x - v1.x ) * m,
								v1.y + ( v0.y - v1.y ) * m,
								v1.z + ( v0.z - v1.z ) * m);
		}
	}
}