package we3d.scene.dynamics 
{
	import we3d.we3d;
	import we3d.renderer.RenderSession;

	//import we3d.animation.Gradient;
	use namespace we3d;
	
	/**
	 * @private
	 */ 
	public class ParticleRenderer 
	{
		public function ParticleRenderer () {}
		
	/*	public var gradients:Vector.<Gradient>;
		
		public function addGradient( grd:Gradient ) :int {
			gradients.push( grd );
			return gradients.length-1;
		}
		
		public function removeGradient( grd:Gradient ) :Boolean {
			var id:int = gradients.indexOf( grd );
			if( id >= 0 ) {
				gradients.splice( id, 1 );
				return true;
			}
			return false;
		}
		
		protected function updateGradients (emt:ParticleEmitter, session:RenderSession) :void{
			var L:int=gradients.length;
			for(var i:int=0; i<L; i++) {
				gradients[i].update(emt, session);
			}
		}
		*/
		public function render (emt:ParticleEmitter, session:RenderSession) :void {}
		
		public function clone () :ParticleRenderer {
			return new ParticleRenderer();
		}
	}
	
}