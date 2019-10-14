package we3d.material 
{
	import we3d.we3d;

	use namespace we3d;
	
	public class FlatWireAttributes extends FlatAttributes
	{
		public function FlatWireAttributes (fillColor:int= 0x804020, fillAlpha:Number=1,
											lineColor:int=0x402010, lineAlpha:Number=1, lineStyle:Number=0) {
			super(fillColor, fillAlpha);
			this.lineColor = lineColor;
			this.lineAlpha = lineAlpha;
			this.lineStyle = lineStyle;
		}
		
		/** 
		* Color of lines around polygons
		*/
		we3d var _lineColor:int;
		/**
		* @private lineColor with alpha
		*/ 
		we3d var _lineColor32:uint;
		/** 
		* Line alpha 
		*/
		we3d var _lineAlpha:Number;
		
		
		/** 
		 * Fill color
		 */
		public function get lineColor () :uint {
			return _lineColor;
		}
		public function set lineColor (v:uint) :void {
			_lineColor = v;
			_lineColor32 = int(_lineAlpha*255) << 24 | _lineColor;
		}
		/**
		 * Alpha transparency from 0-1
		 */
		public function get lineAlpha () :Number {
			return _lineAlpha;
		}
		public function set lineAlpha (v:Number) :void {
			_lineAlpha = v;
			_lineColor32 = int(_lineAlpha*255) << 24 | _lineColor;
		}
		
		/** 
		* Line thickness
		*/
		public var lineStyle:Number;
		
		public override function clone () :ISurfaceAttributes {
			var r:FlatWireAttributes = new FlatWireAttributes(color, alpha, lineColor, lineAlpha, lineStyle);
			return r;
		}
		
	}
	
}