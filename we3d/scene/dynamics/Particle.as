package we3d.scene.dynamics 
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import we3d.we3d;
	import we3d.mesh.Vertex;

	use namespace we3d;
	
	public class Particle extends Vertex 
	{
		public function Particle (weight:Number=1, resistance:Number=0, lifeTime:Number=50, size:Number=0, explosion:Number=0, color:int=0xFFFFFF, alpha:Number=1)  
		{
			this.weight = weight;
			this.invWeight = 1/weight;
			this.resistance = resistance;
			this.lifeTime = lifeTime;
			this.size = size;
			this.color = color;
			this.alpha = alpha;
			this.explosion = explosion;
		}
		
		public function die () :void {
			if(clipRef) {
				var dp:DisplayObject;
				for(var i:String in clipRef) {
					dp = clipRef[i];
					if(dp.parent) dp.parent.removeChild( dp );
				}
				clipRef = null;
			}
		}
		public var clipRef:Dictionary = new Dictionary(true);
		
		public var weight:Number;
		public var invWeight:Number;
		public var resistance:Number;
		public var explosion:Number;
		public var lifeTime:Number;
		public var size:Number;
		public var age:Number=0;
		public var velocity_x:Number=0;
		public var velocity_y:Number=0;
		public var velocity_z:Number=0;
		public var forces_x:Number=0;
		public var forces_y:Number=0;
		public var forces_z:Number=0;
	}
}
