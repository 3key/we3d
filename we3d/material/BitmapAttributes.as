package we3d.material 
{
	import flash.display.BitmapData;
	
	import we3d.we3d;
	import we3d.mesh.Face;
	import we3d.mesh.UVCoord;
	import we3d.renderer.RenderSession;
	
	use namespace we3d;
	
	public class BitmapAttributes extends FlatAttributes implements ISurfaceAttributes
	{
		public function BitmapAttributes (bitmap:BitmapData=null) {
			texture = bitmap;
		}
		
		we3d var _texture:BitmapData;
		we3d var _w:Number=0;
		we3d var _h:Number=0;
		public var smooth:Boolean=true;
		public var repeat:Boolean=false;
		
		/**
		 * the bitmapdata of the texture
		 * @return
		 */
		public function get texture () :BitmapData { return _texture; }
		public function set texture (b:BitmapData) :void {
			if(b is BitmapData) {
				_texture = b;
				_w = b.width;
				_h = b.height;
			}else{
				_texture = null;
				_w = 0;
				_h = 0;
			}
		}
		
		public function setSize (w:Number, h:Number) :void {
			_w = w;
			_h = h;
		}
		
		public override function clone () :ISurfaceAttributes {
			var r:BitmapAttributes = new BitmapAttributes( texture );
			return r;
		}
		
	}
}