package we3d.scene 
{
	import we3d.mesh.Vertex;
	
	/**
	* @private
	*/ 
	public class MorphKeyFrame 
	{
		public function MorphKeyFrame (id:int, d:Number=0) {	this.id=id;		this.duration = d	}
		
		public var id:int;
		
		/**
		* Duration of the animation to the next frame in ms. if duration is zero, the frame is not morphed to the next frame
		*/ 
		public var duration:Number=0;
		
		/**
		 * @private
		 */
		public var startTime:Number=0;
		
	}
}