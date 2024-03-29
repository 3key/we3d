package we3d.scene 
{
	import we3d.we3d;
	import we3d.core.Object3d;
	import we3d.math.Matrix3d;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Directional or point light source
	*/
	public class SceneLight extends Object3d
	{
		public function SceneLight (isPointLightSource:Boolean=false, _intensity:Number=1) {
			directional = !isPointLightSource;
			intensity = _intensity;
		}
		
		/**
		* The radius of the light to send light, 0 is infinite radius
		*/
		public var radius:Number=0;
		/** 
		* The light intensity from 0-1 or higher
		*/
		public var intensity:Number=1;
		/**
		* Amount of red color component (0-255)
		*/
		public var r:int=255;
		/**
		* Amount of green color component (0-255)
		*/
		public var g:int=255;
		/**
		* Amount of blue color component (0-255)
		*/
		public var b:int=255;
		/**
		* If true, the light is a directional light source, otherwise a point light source
		*/
		public var directional:Boolean=true;
		
		/**
		* @param v color of the light source
		*/
		public function set color (v:uint) :void {
			r = v >> 16 & 255;
			g = v >> 8 & 255;
			b = v & 255;
		}
		public function get color () :uint {
			return r << 16 | g << 8 | b;
		}
		
		public function clone () :SceneLight {
			var rv:SceneLight = new SceneLight(!directional);
			rv.setTransform( transform.clone() );
			rv.radius = radius;
			rv.intensity = intensity;
			rv.r = r;
			rv.g = g;
			rv.b = b;
			if(shared) 
			{
				for(var id:String in shared) {
					rv.shared[id] = shared[id];
				}
			}
			return rv;
		}
		
	}
}