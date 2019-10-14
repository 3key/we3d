package we3d.material 
{
	import we3d.we3d;
	import we3d.mesh.Face;
	import we3d.mesh.MeshProgram;
	import we3d.rasterizer.IRasterizer;
	import we3d.rasterizer.NativeFlat;

	use namespace we3d;
	
	/** 
	* Surfaces of polygons
	*/
	public class Surface 
	{
		public function Surface (_rasterizer:IRasterizer=null, _attributes:ISurfaceAttributes=null, _hideBackfaces:Boolean=true) {
			rasterizer = _rasterizer || defaultRasterizer;
			attributes = _attributes || defaultAttributes;
			hideBackfaces = _hideBackfaces
		}
		
		/** 
		* Hide or display backfaces 
		*/
		public var hideBackfaces:Boolean;
		public var rasterizer:IRasterizer;
		public var attributes:ISurfaceAttributes;
		we3d var program:MeshProgram;
		public var programDirty:Boolean=true;
		
		public var shared:Object = {};
		
		public static var defaultRasterizer:IRasterizer = new NativeFlat();
		public static var defaultAttributes:ISurfaceAttributes = new FlatAttributes();
		
		public function clone () :Surface {
			var r:Surface = new Surface( rasterizer.clone(), attributes.clone() );
			r.hideBackfaces = hideBackfaces;
			if(shared) {
				for(var id:String in shared) {
					r.shared[id] = shared[id];
				}
			}
			return r;
		}
	}
}