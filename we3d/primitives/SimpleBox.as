package we3d.primitives 
{
	import we3d.we3d;
	import we3d.core.transform.Transform3d;
	import we3d.material.Surface;
	import we3d.math.Vector3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.modeler.create.SimpleBoxTool;

	use namespace we3d;
	
	/**
	 * A simple box primitive with 6 faces
	 */ 
	public class SimpleBox extends BasePrimitive 
	{
		public function SimpleBox (initObj:Object=null) {
			if(initObj && initObj.surface) surface = initObj.surface;
			else surface = new Surface();
		}
		
		public var surface:Surface;
		private var _low:Vector3d  = new Vector3d(-50,-50,-50);
		private var _high:Vector3d = new Vector3d( 50, 50, 50);
		private var _outside:Boolean=true;
		private var _makeQuads:Boolean=false;
		private var _makeUV:Boolean=true;
		private var _transform:Transform3d=null;
		private var _uStart:Number=0;
		private var _vStart:Number=0;
		private var _uEnd:Number=1;
		private var _vEnd:Number=1;
		
		public function set low (value:*) :void {
			_low.x = value.x;
			_low.y = value.y;
			_low.z = value.z;
			invalidate();
		}
		public function get low () :Vector3d {
			return _low;
		}
		
		public function set high (value:*) :void {
			_high.x = value.x;
			_high.y = value.y;
			_high.z = value.z;
			invalidate();
		}
		public function get high () :Vector3d {
			return _high;
		}
		
		public function set width (value:Number) :void {
			_low.x = -value/2;
			_high.x = value/2;
			invalidate();
		}
		public function get width () :Number {
			return _high.x - _low.x;
		}
		
		public function set height (value:Number) :void {
			_low.y = -value/2;
			_high.y = value/2;
			invalidate();
		}
		public function get height () :Number {
			return _high.y - _low.y;
		}
		
		public function set depth (value:Number) :void {
			_low.z = -value/2;
			_high.z = value/2;
			invalidate();
		}
		public function get depth () :Number {
			return _high.z - _low.z;
		}
		
		public function set outside (value:Boolean) :void {
			_outside = value;
			invalidate();
		}
		public function get outside () :Boolean {
			return _outside;
		}
		
		public function set makeQuads (value:Boolean) :void {
			_makeQuads = value;
			invalidate();
		}
		public function get makeQuads () :Boolean {
			return _makeQuads;
		}
		
		public function set makeUV (value:Boolean) :void {
			_makeUV = value;
			invalidate();
		}
		public function get makeUV () :Boolean {
			return _makeUV;
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
			recreate = false;
			objectCuller.reset();
			SimpleBoxTool.create( 	this, surface, 
									_low, _high,
									_outside, _makeQuads, 
									_transform, _makeUV, 
									_uStart, _vStart, _uEnd, _vEnd);
		}
		
		
	}
}