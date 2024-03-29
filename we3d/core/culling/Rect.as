package we3d.core.culling 
{
	import we3d.we3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;

	use namespace we3d;
	
	/**
	 * @private
	 */ 
	public class Rect extends BoundSphere
	{
		public function Rect () {}
		
		we3d var minx:Number=2147483647;
		we3d var miny:Number=2147483647;
		we3d var minz:Number=2147483647;
		
		we3d var maxx:Number=-2147483647;
		we3d var maxy:Number=-2147483647;
		we3d var maxz:Number=-2147483647;
		
		we3d var points:Vector.<Vertex> = new Vector.<Face>([	new Vertex(),new Vertex(),new Vertex(),new Vertex() ]);
		
		public override function reset () :void {
			
			super.reset();
			
			minx = 2147483647;
			miny = minx;
			minz = minx;
			
			maxx = -minx;
			maxy = maxx;
			maxz = maxx;
		}
		
		public override function containsPoint (x:Number, y:Number, z:Number) :Boolean {
			return x >= minx && x <= maxx && y >= miny && y <= maxx && z >= minz && z <= maxz;
		}
		
		public override function testPoint (x:Number, y:Number, z:Number) :void {
			
			var c:Boolean = false;
			
			if(x < minx) {
				c = true;
				minx = x;
			}
			if(y < miny) {
				c = true;
				miny = y;
			}
			if(z < minz) {
				c = true;
				minz = z;
			}
			
			if(x > maxx) {
				c = true;
				maxx = x;
			}
			if(y > maxy) {
				c = true;
				maxy = y;
			}
			if(z > maxz) {
				c = true;
				maxz = z;
			}
			
			if(c) {
				var cx:Number = minx+(maxx - minx)/2;
				var cy:Number = miny+(maxy - miny)/2;
				var cz:Number = minz+(maxz - minz)/2;
				
				var dx:Number = maxx-cx;
				var dy:Number = maxy-cy;
				var dz:Number = maxz-cz;
				
				boundingSphere = Math.sqrt(dx*dx + dy*dy + dz*dz);
				
				points[0].assign(minx, miny, minz);
				points[1].assign(maxx, maxy, maxz);
				points[2].assign(maxx, miny, minz);
				points[3].assign(maxx, maxy, minz);
				
			}
		}
		
	}
}