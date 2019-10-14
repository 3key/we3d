package we3d.modeler.create
{
	import we3d.we3d;
	import we3d.core.transform.Transform3d;
	import we3d.material.Surface;
	import we3d.math.Matrix3d;
	import we3d.math.Vector3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/**
	* Create a simple box with 6 quad faces or twelve trianlges if makeQuads is false.
	*/
	public class SimpleBoxTool
	{
		/** 
		* Add a simple box to a SceneObject
		* @param	obj	Object for the points and polygons
		* @param	sf	surface for the new polygons
		* @param	low	min vector of the box
		* @param	high max vector of the box
		* @param 	outside if true the polys face outside
		*/
		public static function create ( obj:SceneObject, sf:Surface, low:Object, high:Object, 
										outside:Boolean=true, makeQuads:Boolean=false,
										transform:Transform3d=null, makeUv:Boolean=true,
										uStart:Number=0, vStart:Number=0,
										uEnd:Number=1, vEnd:Number=1 ) :void {
			
			
			var lx:Number;	var hx:Number;
			var ly:Number;	var hy:Number;
			var lz:Number;	var hz:Number;
			
			if( low.x > high.x) {
				lx = high.x;
				hx = low.x;
			}else{
				lx = low.x;
				hx = high.x;
			}
			
			if(low.y > high.y) {
				ly = high.y;
				hy = low.y;
			}else{
				ly = low.y;
				hy = high.y;
			}
			
			if(low.z > high.z) {
				lz = high.z;
				hz = low.z;
			}else{
				lz = low.z;
				hz = high.z;
			}
			
			if(outside == true) {
				var _lx:Number = lx;	var _ly:Number = ly; var _lz:Number = lz;
				lx = hx;
				ly = hy;
				lz = hz;
				hx = _lx;
				hy = _ly;
				hz = _lz;
			}
			var point1:Vector3d=new Vector3d(lx, ly, lz);
			var point2:Vector3d=new Vector3d(hx, ly, lz);
			var point3:Vector3d=new Vector3d(lx, hy, lz);
			var point4:Vector3d=new Vector3d(hx, hy, lz);
			var point5:Vector3d=new Vector3d(lx, ly, hz);
			var point6:Vector3d=new Vector3d(hx, ly, hz);
			var point7:Vector3d=new Vector3d(lx, hy, hz);
			var point8:Vector3d=new Vector3d(hx, hy, hz);
			
			var p1:int;
			var p2:int;
			var p3:int;
			var p4:int;
			var p5:int;
			var p6:int;
			var p7:int;
			var p8:int;
			
			if(transform != null) {
				var a:Array = [point1, point2, point3, point4, point5, point6, point7, point8];
				var zv:Vector3d = new Vector3d();
				var m:Matrix3d = transform.gv;
				for(var i:int=0; i<8; i++) {
					m.vectorMul(a[i], zv);
					a[i].x = zv.x;	a[i].y = zv.y;	a[i].z = zv.z;
				}
			}
			
			p1 = obj.addPoint(point1.x, point1.y, point1.z);
			p2 = obj.addPoint(point2.x, point2.y, point2.z);
			p3 = obj.addPoint(point3.x, point3.y, point3.z);
			p4 = obj.addPoint(point4.x, point4.y, point4.z);
			p5 = obj.addPoint(point5.x, point5.y, point5.z);
			p6 = obj.addPoint(point6.x, point6.y, point6.z);
			p7 = obj.addPoint(point7.x, point7.y, point7.z);
			p8 = obj.addPoint(point8.x, point8.y, point8.z);
			
			
			var plg1:Face, plg2:Face, plg3:Face, plg4:Face, plg5:Face, plg6:Face;
			
			if(makeQuads) {
				// back poly
				plg1 = obj.addPolygon(sf, p3, p4, p2, p1);
				// front poly
				plg2 = obj.addPolygon(sf, p5, p6, p8, p7);
				// bottom poly
				plg3 = obj.addPolygon(sf, p7, p8, p4, p3);
				// top poly
				plg4 = obj.addPolygon(sf, p1, p2, p6, p5);
				// right poly
				plg5 = obj.addPolygon(sf, p5, p7, p3, p1);
				// left poly
				plg6 = obj.addPolygon(sf, p2, p4, p8, p6);
				
				if(makeUv) {
					plg1.addUvCoord(uStart, vEnd);
					plg1.addUvCoord(uEnd, vEnd);
					plg1.addUvCoord(uEnd, vStart);
					plg1.addUvCoord(uStart, vStart);
					
					plg2.addUvCoord(uEnd, vStart);
					plg2.addUvCoord(uStart, vStart);
					plg2.addUvCoord(uStart, vEnd);
					plg2.addUvCoord(uEnd, vEnd);
					
					plg3.addUvCoord(uEnd, vStart);
					plg3.addUvCoord(uStart, vStart);
					plg3.addUvCoord(uStart, vEnd);
					plg3.addUvCoord(uEnd, vEnd);
					
					plg4.addUvCoord(uEnd, vStart);
					plg4.addUvCoord(uStart, vStart);
					plg4.addUvCoord(uStart, vEnd);
					plg4.addUvCoord(uEnd, vEnd);
					
					plg5.addUvCoord(uStart, vStart);
					plg5.addUvCoord(uStart, vEnd);
					plg5.addUvCoord(uEnd, vEnd);
					plg5.addUvCoord(uEnd, vStart);
					
					plg6.addUvCoord(uStart, vStart);
					plg6.addUvCoord(uStart, vEnd);
					plg6.addUvCoord(uEnd, vEnd);
					plg6.addUvCoord(uEnd, vStart);
				}
			}else{
				// back poly
				plg1  = obj.addPolygon(sf, p1, p4, p2);
				var plg1a:Face = obj.addPolygon(sf, p3, p4, p1);
				// front poly
				plg2 = obj.addPolygon(sf, p5, p6, p8);
				var plg2a:Face = obj.addPolygon(sf, p8, p7, p5);
				// bottom poly
				plg3 = obj.addPolygon(sf, p7, p8, p4);
				var plg3a:Face = obj.addPolygon(sf, p7, p4, p3);
				// top poly
				plg4 = obj.addPolygon(sf, p5, p2, p6);
				var plg4a:Face = obj.addPolygon(sf, p1, p2, p5);
				// right poly
				plg5 = obj.addPolygon(sf, p5, p7, p1);
				var plg5a:Face = obj.addPolygon(sf, p7, p3, p1);
				// left poly
				plg6 = obj.addPolygon(sf, p2, p4, p8);
				var plg6a:Face = obj.addPolygon(sf, p2, p8, p6);
				
				if(makeUv) {
					plg1.addUvCoord(uStart, vStart);
					plg1.addUvCoord(uEnd, vEnd);
					plg1.addUvCoord(uEnd, vStart);
					plg1a.addUvCoord(uStart, vEnd);
					plg1a.addUvCoord(uEnd, vEnd);
					plg1a.addUvCoord(uStart, vStart);
					
					plg2.addUvCoord(uEnd, vStart);
					plg2.addUvCoord(uStart, vStart);
					plg2.addUvCoord(uStart, vEnd);
					plg2a.addUvCoord(uStart, vEnd);
					plg2a.addUvCoord(uEnd, vEnd);
					plg2a.addUvCoord(uEnd, vStart);
					
					plg3.addUvCoord(uEnd, vStart);
					plg3.addUvCoord(uStart, vStart);
					plg3.addUvCoord(uStart, vEnd);
					plg3a.addUvCoord(uEnd, vStart);
					plg3a.addUvCoord(uStart, vEnd);
					plg3a.addUvCoord(uEnd, vEnd);
					
					plg4.addUvCoord(uEnd, vEnd);
					plg4.addUvCoord(uStart, vStart);
					plg4.addUvCoord(uStart, vEnd);
					plg4a.addUvCoord(uEnd, vStart);
					plg4a.addUvCoord(uStart, vStart);
					plg4a.addUvCoord(uEnd, vEnd);
					
					plg5.addUvCoord(uStart, vStart);
					plg5.addUvCoord(uStart, vEnd);
					plg5.addUvCoord(uEnd, vStart);
					plg5a.addUvCoord(uStart, vEnd);
					plg5a.addUvCoord(uEnd, vEnd);
					plg5a.addUvCoord(uEnd, vStart);
					
					plg6.addUvCoord(uStart, vStart);
					plg6.addUvCoord(uStart, vEnd);
					plg6.addUvCoord(uEnd, vEnd);
					plg6a.addUvCoord(uStart, vStart);
					plg6a.addUvCoord(uEnd, vEnd);
					plg6a.addUvCoord(uEnd, vStart);
				}
			}
		}
	}
}
