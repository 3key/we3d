package we3d.modeler.create
{
	import we3d.we3d;
	import we3d.core.transform.Transform3d;
	import we3d.material.Surface;
	import we3d.math.Vector3d;
	import we3d.mesh.Vertex;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/**
	* Create a grid of lines in a SceneObject
	*/
	public class GridTool
	{
		public static function create (obj:SceneObject, sf:Surface, width:Number=100, height:Number=100, linesX:int=16, linesY:int=16, transform:Transform3d=null) :void {
			
			var cx:Number = width / linesX;
			var cy:Number = height / linesY;
			var w2:Number = width/2;
			var h2:Number = height/2;
			
			var x:Number = -w2;
			var z:Number = -h2+cy;
			var y:Number = 0;
			var i:int;
			var L:int = linesX-1;
			
			var gstart:int = obj.points.length;
			
			for(i=0; i<L; i++) {
				obj.addPoint(x, y, z);
				obj.addPoint(w2, y, z);
				obj.addPolygon( sf, obj.points.length-2, obj.points.length-1);
				z += cy;
			}
			
			L = linesY-1;
			x = -w2+cx;
			z = -h2;
			
			for(i=0; i<L; i++) {
				obj.addPoint(x, y, z);
				obj.addPoint(x, y, h2);
				obj.addPolygon(sf, obj.points.length-2, obj.points.length-1);
				x += cx;
			}
			
			if(transform != null) {
				var vec1:Vector3d = new Vector3d();
				var vec2:Vector3d = new Vector3d();
				var pt:Vertex;
				
				for(i=gstart; i<obj.points.length; i++) {
					pt = obj.points[i];
					vec1.assign( pt.x, pt.y, pt.z );
					transform.gv.vectorMul( vec1, vec2 );
					pt.x = vec2.x;
					pt.y = vec2.y;
					pt.z = vec2.z;
				}
				obj.objectCuller.reset();
				obj.objectCuller.testPoints( obj.points );
			}
		}
	}
}