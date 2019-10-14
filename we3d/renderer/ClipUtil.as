package we3d.renderer 
{
	import we3d.we3d;
	import we3d.math.Plane;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;

	use namespace we3d;
	
	/**
	* @private
	*/
	public class ClipUtil 
	{
		public function ClipUtil () {
			var w:Number = Math.PI/4;
			var h:Number = Math.sin(w);
			var q:Number = Math.cos(w);
			
			leftPlane.x   =  q;   leftPlane.z   = h;
			rightPlane.x  = -q;   rightPlane.z  = h;
			topPlane.y    = -q;   topPlane.z    = h;
			bottomPlane.y =  q;   bottomPlane.z = h;	
		}
		
		protected var topPlane:Plane    = new Plane();
		protected var bottomPlane:Plane = new Plane();
		protected var leftPlane:Plane   = new Plane();
		protected var rightPlane:Plane  = new Plane();
		protected var plw:Number=0;
		
 		public function splitVertexPlane (a:Vertex, b:Vertex, n:Plane) :Vertex {
			var adot:Number = a.wx * n.x + a.wy * n.y + a.wz * n.z;
			var bdot:Number = b.wx * n.x + b.wy * n.y + b.wz * n.z;
			var scale:Number = (-adot)/(bdot-adot);
			
			var rv:Vertex = new Vertex();
			rv.wx = a.wx + scale*(b.wx-a.wx);
			rv.wy = a.wy + scale*(b.wy-a.wy);
			rv.wz = a.wz + scale*(b.wz-a.wz);
			
			return rv;
		}
		
		public function splitVertexUVPlane (a:Vertex, b:Vertex, n:Plane, uva:UVCoord, uvb:UVCoord, pts:Vector.<Vertex> , uvs:Vector.<UVCoord> ) :void {
			
			var adot:Number = a.wx * n.x + a.wy * n.y + a.wz * n.z;
			var bdot:Number = b.wx * n.x + b.wy * n.y + b.wz * n.z;
			var scale:Number = (-adot)/(bdot-adot);
			
			var rv:Vertex = new Vertex();
			rv.wx = a.wx + scale*(b.wx-a.wx);
			rv.wy = a.wy + scale*(b.wy-a.wy);
			rv.wz = a.wz + scale*(b.wz-a.wz);
			
			pts.push(rv);
			
			var tuv:UVCoord = new UVCoord(uva.u + scale*(uvb.u-uva.u), uva.v + scale*(uvb.v-uva.v));
			uvs.push(tuv);
		}
		
		public function splitVertex (a:Vertex, b:Vertex) :Vertex {
			
			var rv:Vertex = new Vertex();
			var scale:Number = (plw-a.wz)/(b.wz-a.wz)
			rv.wx = a.wx + scale*(b.wx-a.wx);
			rv.wy = a.wy + scale*(b.wy-a.wy);
			rv.wz = plw;
			
			return rv;
		}
		
		public function splitVertexUV (a:Vertex, b:Vertex, uva:UVCoord, uvb:UVCoord, pts:Vector.<Vertex> , uvs:Vector.<UVCoord> ) :void {
			
			var rv:Vertex = new Vertex();
			var scale:Number = (plw-a.wz)/(b.wz-a.wz);
			rv.wx = a.wx + scale*(b.wx-a.wx);
			rv.wy = a.wy + scale*(b.wy-a.wy);
			rv.wz = plw;
			
			pts.push(rv);
			
			var tuv:UVCoord = new UVCoord(uva.u + scale*(uvb.u-uva.u), uva.v + scale*(uvb.v-uva.v));
			uvs.push(tuv);
		}
		
	}
	
}