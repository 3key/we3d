package we3d.scene 
{
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.math.Matrix3d;
	import we3d.renderer.RenderSession;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/** 
	* A SceneSound transforms the volume and optional the pan of a Sound relative to the distance to the Camera
	*/
	public class SceneSound extends SceneObject
	{
		/** 
		 * Creates a new SceneSound instance
		 * @param    sp    reference to a SoundChannel
		 * @param    vol   the volume of the sound, if the camera is at the sound position
		 * @param	pan	  maximal pan value for a Sound, pan is between 0 and 1, if zero panning is deactivated
		 * @param    _minDistance     the distance of the sound to wich the user can hear the sound at maximum volume
		 * @param    _maxDistance     the distance to wich the user can hear the sound
		 */
		public function SceneSound (sp:SoundChannel, v:Number=1, p:Number=0, _minDistance:Number=1, _maxDistance:Number=2) {
			volume = v;
			radius = _maxDistance;
			minDistance = _minDistance;
			soundRef = sp;
			if(p == 0) {
				pan = false;
			}else{
				pan = true;
				maxPan = p;
			}
		}
		
		/**
		* Gobal volume for all 3D sounds
		*/
		public static var masterVolume:Number = 1.0;
		/**
		* Sound Channel of this 3D sound
		*/
		public var soundRef:SoundChannel;
		/**
		* Max volume if camera position is at sound position
		*/
		public var volume:Number;
		/**
		* The radius of the sound
		*/
		public var radius:Number;
		/**
		* The radius of the sound were volume is maxVolume
		*/
		public var minDistance:Number;
		/**
		* If pan is true, the panning of the sound is relative to the camera rotation
		*/
		public var pan:Boolean=true;
		/**
		* Maximal pan is a positive Number from 0-1 or higher
		*/
		public var maxPan:Number=1;
		
		private var st:SoundTransform = new SoundTransform(1,0);
		
		/**
		* @private
		*/
		public override function initFrame (session:RenderSession) :Boolean {
			
			var cam:Camera3d = session.camera;
			if(frameInit) transform.initFrame(session.currentFrame);
			
			var cam_cgv:Matrix3d = camMatrix;
			var gv:Matrix3d = transform.gv;
			var rv:Matrix3d = cam.transform.gv;
			
			var dx:Number = gv.m - rv.m;
			var dy:Number = gv.n - rv.n;
			var dz:Number = gv.o - rv.o;
			var dist:Number = Math.sqrt(dx*dx + dy*dy + dz*dz);
			var r:Number = radius - minDistance;
			
			if(dist <= minDistance) {
				st.volume = volume * masterVolume;
				st.pan = 0;
				soundRef.soundTransform = st;
			}
			else if(dist <= radius){
				
				var pa:Number = 0;
				
				if(pan) {
					var d:Number = dx*rv.a + dy*rv.b + dz*rv.c;
					var ang:Number = Math.acos(d/dist) - Math.PI/2;
					pa = - (ang/100 * (100/(Math.PI/2)))*maxPan;
				}
				
				st.volume = (volume/r) * (r-dist) * masterVolume;
				st.pan = pa;
				soundRef.soundTransform = st;
			}
			else{
				st.volume = 0;
				st.pan = 0;
				soundRef.soundTransform =st;
			}
			
			return true;
		}
	}
}
