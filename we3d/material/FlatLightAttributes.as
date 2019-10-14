package we3d.material 
{
	import we3d.we3d;
	import we3d.scene.LightGlobals;

	use namespace we3d;
	
	public class FlatLightAttributes extends FlatAttributes
	{
		public function FlatLightAttributes (fillColor:int= 0x804020, fillAlpha:Number=1, luminosity:Number=0, diffuse:Number=1, lightGlobals:LightGlobals=null) {
			super(fillColor, fillAlpha);
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
			var r:FlatLightAttributes = new FlatLightAttributes(color, alpha, luminosity, diffuse, lightGlobals);
			return r;
		}
	}
	
}