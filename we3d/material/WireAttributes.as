package we3d.material 
{
	public class WireAttributes extends FlatAttributes implements ISurfaceAttributes
	{
		public function WireAttributes (lineColor:int=0x402010, lineAlpha:Number=1, lineStyle:Number=0) {
			this.color = lineColor;
			this.alpha = lineAlpha;
			this.lineStyle = lineStyle;
		}
		
		/** 
		* Line thickness
		*/
		public var lineStyle:int;
		
		public override function clone () :ISurfaceAttributes {
			var r:WireAttributes = new WireAttributes(color, alpha, lineStyle);
			return r;
		}
	}
	
}