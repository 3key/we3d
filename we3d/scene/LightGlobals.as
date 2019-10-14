package we3d.scene 
{
	import we3d.we3d;
	import we3d.filter.BackgroundFilter;
	import we3d.renderer.RenderSession;
	import we3d.scene.SceneLight;

	use namespace we3d;
	
	/**
	* LightGlobals is a lighting setup. 
	* Multiple light setups can be used in the same scene but not on the same material. 
	* You have to assign an instance of LightGlobals to a LightAttributes material.
	*/
	public class LightGlobals extends BackgroundFilter
	{
		public function LightGlobals () {}
		
		/** 
		* The lightList contains all lights
		*/
		public var lightList:Vector.<SceneLight> = new Vector.<SceneLight>();
		/**
		* Amount of ambient light from 0-1 or higher
		*/
		public var ambientLight:Number=0.25;
		/**
		* @private
		*/
		we3d var ambientR:int=255;
		/**
		* @private
		*/
		we3d var ambientG:int=255;
		/**
		* @private
		*/
		we3d var ambientB:int=255;
		/**
		* @private
		*/
		we3d var _sar:int=0;
		/**
		* @private
		*/
		we3d var _sag:int=0;
		/**
		* @private
		*/
		we3d var _sab:int=0;
		
		/**
		* The color of ambient light
		*/
		public function set ambientColor (v:int) :void {
			ambientR = v >> 16 & 255;
			ambientG = v >> 8 & 255;
			ambientB = v & 255;
		}
		public function get ambientColor () :int {
			return ambientR << 16 | ambientG << 8 | ambientB;
		}
		
		public function get finalAmbientColor () :int {
			return int(ambientR*ambientLight) << 16 | int(ambientG*ambientLight) << 8 | int(ambientB*ambientLight);
		}
		
		/**
		* @private
		*/
		public override function initFrame (session:RenderSession) :void 
		{
			var L:int = lightList.length+1;
			_sar = (ambientR*ambientLight) / L;
			_sag = (ambientG*ambientLight) / L;
			_sab = (ambientB*ambientLight) / L;
			
			L--;
			for(var i:int=0; i<L; i++) {
				lightList[i].initFrame(session);
			}
		}
	}
	
}