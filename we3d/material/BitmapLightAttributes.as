package we3d.material 
{
	import flash.display.BitmapData;
	
	
	import we3d.we3d;
	import we3d.scene.LightGlobals;
	
	use namespace we3d;
	
	public class BitmapLightAttributes extends BitmapAttributes
	{
		public function BitmapLightAttributes (bitmap:BitmapData=null, luminosity:Number=0, diffuse:Number=1, lightGlobals:LightGlobals=null)  {
			super(bitmap);
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
		
		public override function clone () :ISurfaceAttributes {
			var r:BitmapLightAttributes = new BitmapLightAttributes( texture, luminosity, diffuse, lightGlobals );
			return r;
		}
		
	}
}