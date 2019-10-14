package we3d.material 
{
	import we3d.we3d;
	import we3d.mesh.Face;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	public class FlatAttributes implements ISurfaceAttributes
	{
		public function FlatAttributes (fillColor:uint=0x807060, fillAlpha:Number=1) {
			color = fillColor;
			alpha = fillAlpha;
		}
				
		we3d var r:Number;
		we3d var g:Number;
		we3d var b:Number;
		
		/**  @private	*/
		we3d var _color:uint;
		/**  @private	*/
		we3d var _color32:uint;
		/**  @private 	*/
		we3d var _alpha:Number;
		
		/**  Fill color */
		public function get color () :uint {	return _color;	}
		public function set color (v:uint) :void {
			_color = v;
			_color32 = int(_alpha*255) << 24 | _color;
			r = (_color >> 16 & 255)/255;
			g = (_color >> 8 & 255)/255;
			b = (_color & 255)/255;
		}
		
		/** Alpha transparency from 0-1 */
		public function get alpha () :Number {	return _alpha;	}
		public function set alpha (v:Number) :void {
			_alpha = v;
			_color32 = int(_alpha*255) << 24 | _color;
		}
		
		public function clone () :ISurfaceAttributes {
			var r:FlatAttributes = new FlatAttributes(color, alpha);
			return r;
		}
	
	}
}