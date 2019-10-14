package we3d.material 
{
	import we3d.mesh.Face;
	import we3d.scene.LightGlobals;
	
	public class FlatWireLightAttributes extends FlatWireAttributes
	{
		public function FlatWireLightAttributes (fillColor:int=0x804020, fillAlpha:Number=1,
											lineColor:int=0x402010, lineAlpha:Number=1, lineStyle:Number=0,
											luminosity:Number=0, diffuse:Number=1, lightGlobals:LightGlobals=null) {
			super(fillColor, fillAlpha, lineColor, lineAlpha, lineStyle);
			this.luminosity = luminosity;
			this.diffuse = diffuse;
			this.lightGlobals = lightGlobals;
		}
		public var lightGlobals:LightGlobals;
		/**
		* Self lighting of the surface
		*/
		public var luminosity:Number;
		/**
		* Amount of lighting on the surface
		*/
		public var diffuse:Number;
		/**
		 * Flat or smooth light shading
		 */
		public var smoothShading:Boolean = false;
		
		public override function clone () :ISurfaceAttributes {
			var r:FlatWireLightAttributes = new FlatWireLightAttributes(color, alpha, lineColor, lineAlpha, lineStyle, luminosity
																		, diffuse, lightGlobals);
			return r;
		}
		
	}
	
}