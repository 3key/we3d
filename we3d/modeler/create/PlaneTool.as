package we3d.modeler.create 
{
	import we3d.we3d;
	import we3d.core.transform.Transform3d;
	import we3d.material.Surface;
	import we3d.math.Matrix3d;
	import we3d.math.Vector3d;
	import we3d.mesh.Face;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/**
	 * Creates flat plane
	 */ 
	public class PlaneTool  
	{
		public static var MAX_DIVISION:int = 200;
		
		public static var defaultTransform:Transform3d = new Transform3d();
		private static var vec:Vector3d  =  new Vector3d(0,0,0);
		private static var vec2:Vector3d =  new Vector3d(0,0,0);
		
		/**
		* Creates a plane in a SceneObject
		* @param	so	Object for the points and polygons
		* @param	sf	surface for the new polygons
		* @param	w	width of the plane
		* @param	h	height of the plane
		* @param	segX	horizontal division
		* @param	segY	vertical division
		* @param	axis	String "x", "y" or "z"
		* @param	makeQuads	Boolean if true the plane is made of Quads otherwise Triangles
		* @param	transform	optional apply a transform to the points of the new plane
		*/
		public static function create(	so:SceneObject, sf:Surface, 
										w:Number=100, h:Number=100, 
										segX:int=1, segY:int=1,
										axis:String="", makeQuads:Boolean=false,
										transform:Transform3d=null, 
										uStart:Number=0, vStart:Number=0,
										uEnd:Number=1, vEnd:Number=1) :void
		{
			
			axis = axis.charAt(0).toLowerCase();
			
			var ax:int;
			
			if(axis=="x") {
				ax = 1;
			}else if(axis=="y") {
				ax = 2;
			}else{
				ax = 0;
			}
			
			if(segX < 1) segX = 1;
			else if(segX > MAX_DIVISION) segX = MAX_DIVISION;
			
			if(segY < 1) segY = 1;
			else if(segY > MAX_DIVISION) segY = MAX_DIVISION;
		
			var x:Number = -w/2;
			var y:Number = h/2;
			var z:Number = 0;
			
			var x2:Number;
			var y2:Number;
			
			var pointslineT:Array;
			var pointslineB:Array;
			
			var spaceX:Number = w/segX;
			var spaceY:Number = h/segY;
			
			var uvxSpace:Number = (uEnd-uStart)/segX;
			var uvySpace:Number = (vEnd-vStart)/segY;
			
			var uvx:Number = uStart;
			var uvy:Number = vStart;
			
			var plg:Face;
			var p1:int;
			var p2:int;
			var i:int;
			var j:int;
			var L:int;
			var tm:Matrix3d;
			
			if(transform != null) {
				tm = transform.transform;
			}else{
				tm = defaultTransform.transform;
			}
			x2 = x;
			y2 = y;
			
			pointslineB = [];
			
			if(ax==1) {
				for(i=0; i <= segX; i++) {
					createPoint(so, pointslineB, tm, z, y2, x2);
					x2 += spaceX;
				}
			}else if(ax==2) {
				for(i=0; i <= segX; i++) {
					createPoint(so, pointslineB, tm, x2, z, y2);
					x2 += spaceX;
				}
			}else{
				for(i=0; i <= segX; i++) {
					createPoint(so, pointslineB, tm, x2, y2, z);
					x2 += spaceX;
				}
			}

			for(j=0; j < segY; j++) {
			
				pointslineT = pointslineB;
				pointslineB = [];
				
				uvx = uStart;
				x2 = x;
				y2 = y-spaceY;
				
				if(ax==1) {
					for(i=0; i <= segX; i++) {
						createPoint(so, pointslineB, tm, z, y2, x2);
						x2 += spaceX;
					}
				}else if(ax==2) {
					for(i=0; i <= segX; i++) {
						createPoint(so, pointslineB, tm, x2, z, y2);
						x2 += spaceX;
					}
				}else{
					for(i=0; i <= segX; i++) {
						createPoint(so, pointslineB, tm, x2, y2, z);
						x2 += spaceX;
					}
				}
				
				L = pointslineT.length-1;
				
				if(makeQuads) {
					
					for(i=0; i<L; i++) {
						plg = so.addPolygon(sf, pointslineB[i+1], pointslineT[i+1], pointslineT[i], pointslineB[i]);
						plg.addUvCoord(uvx+uvxSpace, uvy+uvySpace);
						plg.addUvCoord(uvx+uvxSpace, uvy);
						plg.addUvCoord(uvx, uvy);
						plg.addUvCoord(uvx, uvy+uvySpace);
						uvx += uvxSpace;
					}
					
				}else{
					for(i=0; i<L; i++) {
						plg = so.addPolygon(sf, pointslineB[i], pointslineT[i+1], pointslineT[i]);
						plg.addUvCoord(uvx, uvy+uvySpace);
						plg.addUvCoord(uvx+uvxSpace, uvy);
						plg.addUvCoord(uvx, uvy);
						
						plg = so.addPolygon(sf, pointslineB[i+1], pointslineT[i+1], pointslineB[i]);
						plg.addUvCoord(uvx+uvxSpace, uvy+uvySpace);
						plg.addUvCoord(uvx+uvxSpace, uvy);
						plg.addUvCoord(uvx, uvy+uvySpace);
						uvx += uvxSpace;
					}
				}
					
				uvy += uvySpace;
				y -= spaceY;
			}
			
		}
		
		private static function createPoint (so:SceneObject, arr:Array, tm:Matrix3d, x:Number, y:Number, z:Number) :void {
			vec.x = x;	vec.y = y;	vec.z = z;		
			tm.vectorMul(vec, vec2);
			arr.push( so.addPoint(vec2.x, vec2.y, vec2.z) );
		}
	}
	
}