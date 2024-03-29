package we3d.core.culling 
{
	import we3d.we3d;
	import we3d.mesh.Vertex;
	use namespace we3d;
	
	public class BoundBox extends BoundSphere
	{
		public function BoundBox () {
			points = new Vector.<Vertex>();
			for(var i:int=0; i<ptLen; i++) points.push(new Vertex());
		}
		
		we3d var minx:Number=2147483647;
		we3d var miny:Number=2147483647;
		we3d var minz:Number=2147483647;
		
		we3d var maxx:Number=-2147483647;
		we3d var maxy:Number=-2147483647;
		we3d var maxz:Number=-2147483647;
		
		we3d var points:Vector.<Vertex>;
		
		we3d var cx:Number=0;
		we3d var cy:Number=0;
		we3d var cz:Number=0;
		
		we3d var ptLen:int=8;
		protected var _rectMode:Boolean=false;
		
		public function set rectMode (v:Boolean) :void {
			if( v ) {
				ptLen = 4;
			}else{
				ptLen = 8;
			}
			_rectMode = v;
		}
		public function get rectMode () :Boolean {
			return _rectMode;
		}
		
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
				cx = minx+(maxx - minx)/2;
				cy = miny+(maxy - miny)/2;
				cz = minz+(maxz - minz)/2;
				
				var dx:Number = maxx-cx;
				var dy:Number = maxy-cy;
				var dz:Number = maxz-cz;
				
				boundingSphere = Math.sqrt(dx*dx + dy*dy + dz*dz);
				
				if(points.length==0) return;
				points[0].assign(minx, miny, minz);
				points[1].assign(maxx, maxy, maxz);
				points[2].assign(maxx, miny, minz);
				points[3].assign(minx, maxy, minz);
				
				if( !_rectMode ) {
					points[4].assign(maxx, maxy, minz);
					points[5].assign(minx, miny, maxz);
					points[6].assign(maxx, miny, maxz);
					points[7].assign(minx, maxy, maxz);
				}
			}
		}
		
	}
}