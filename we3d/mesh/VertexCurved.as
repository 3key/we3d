package we3d.mesh 
{
	import we3d.mesh.Vertex;
	
	/**
	* VertexCurved is a point in a mesh object with an additional curve handle point. You create vertexes with the sceneObjectCurved.addCurvedPoint method. Curved points are rendered with the NativeFlatCurved rasterizer only.
	*/ 
	public class VertexCurved extends Vertex 
	{
		function VertexCurved (ax:Number=0, ay:Number=0, az:Number=0, cx:Number=0, cy:Number=0, cz:Number=0) {
			x = ax;
			y = ay;
			z = az;
			bx = cx;
			by = cy;
			bz = cz;
		}
		
		public var bx:Number=0;
		public var by:Number=0;
		public var bz:Number=0;
		public var bsx:Number=0;
		public var bsy:Number=0;
	}
}