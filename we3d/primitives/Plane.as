package we3d.primitives 
{
	import we3d.we3d;
	import we3d.core.transform.Transform3d;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.modeler.create.PlaneTool;

	use namespace we3d;
	
	/**
	 * A flat plane primitive
	 */ 
	public class Plane extends BasePrimitive 
	{
		public function Plane (initObj:Object=null) {
			if(initObj && initObj.surface) surface = initObj.surface;
			else surface = new Surface();
		}
		
		public var surface:Surface;
		private var _w:Number=100;
		private var _h:Number=100;
		private var _segX:Number=1;
		private var _segY:Number=1;
		private var _axis:String=""
		private var _makeQuads:Boolean=false;
		private var _transform:Transform3d=null;
		private var _uStart:Number=0;
		private var _vStart:Number=0;
		private var _uEnd:Number=1;
		private var _vEnd:Number=1;
		
		public function set width (value:Number) :void {
			_w = value;
			invalidate();
		}
		public function get width () :Number {
			return _w;
		}
		
		public function set height (value:Number) :void {
			_h = value;
			invalidate();
		}
		public function get height () :Number {
			return _h;
		}
		
		public function set segX (value:int) :void {
			_segX = value;
			invalidate();
		}
		public function get segX () :int {
			return _segX;
		}
		
		public function set segY (value:int) :void {
			_segY = value;
			invalidate();
		}
		public function get segY () :int {
			return _segY;
		}
		
		public function set axis (value:String) :void {
			_axis = value;
			invalidate();
		}
		public function get axis () :String {
			return _axis;
		}
		
		public function set makeQuads (value:Boolean) :void {
			_makeQuads = value;
			invalidate();
		}
		public function get makeQuads () :Boolean {
			return _makeQuads;
		}
		
		public function set meshTransform (value:Transform3d) :void {
			_transform = value;
			invalidate();
		}
		public function get meshTransform () :Transform3d {
			return _transform;
		}
		
		public function setUV (uStart:Number, uEnd:Number, vStart:Number, vEnd:Number) :void {
			_uStart = uStart;
			_uEnd = uEnd;
			_vStart = vStart;
			_vEnd = vEnd;
			invalidate();
		}
		
		public override function updateGeometry () :void {
			points = new Vector.<Vertex>();
			polygons = new Vector.<Face>();
			objectCuller.reset();
			recreate = false;
			PlaneTool.create( 	this, surface, 
								_w, _h, _segX, _segY, 
								_axis, _makeQuads, _transform, 
								_uStart, _vStart, _uEnd, _vEnd);
		}
		
		
	}
}