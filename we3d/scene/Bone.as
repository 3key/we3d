package we3d.scene 
{
	import we3d.core.Object3d;
	import we3d.math.Vector3d;
	import we3d.mesh.Face;
	
	/**
	* Bones can be added only to a SceneObjectBones object.
	* 
	* A Bone is really simple, they know a set of points, wich will be transformed by the Bone. 
	* To animate a Bone, first set the restPosition to the initial position of the Bone. 
	* Then position and rotate the Bone to transform the points connected with the Bone.
	*/
	public class Bone extends Object3d 
	{
		public function Bone () {}
		
		/**
		* Point ids to transform
		*/
		public var points:Vector.<int> = new Vector.<int>();
		
		/**
		 * Point weight map
		 */
		public var weights:Vector.<Number> = new Vector.<Number>();
		
		/**
		* The restPosition is the initialPosition relative to the SceneObject
		*/
		public var restPosition:Vector3d = new Vector3d();
	}
}