package we3d.scene 
{
	import we3d.we3d;
	import we3d.core.culling.BoxCulling;
	import we3d.renderer.RenderSession;
	import we3d.mesh.MeshBuffer;
	import we3d.mesh.Vertex;
	use namespace we3d;
	
	/**
	* @private
	*/ 
	public class MorphFrame 
	{
		public function MorphFrame (name:String="") {	this.name=name;		}
		
		public var points:Vector.<Vertex> = new Vector.<Vertex>();
		public var name:String="";
		public var objectCuller:BoxCulling = new BoxCulling();
		
		public function updateBounds () :void {
			objectCuller.reset();
			objectCuller.testPoints( points );
		}
		
		we3d var buffersDirty:Boolean=true;
		we3d var meshBuffer:Vector.<MeshBuffer>;
		
		public function initBuffers (session:RenderSession) :void 
		{			
			if(meshBuffer == null) {
				meshBuffer = new Vector.<MeshBuffer>();
			}else{
				try {
					var L:int;
					var i:int;
					L = meshBuffer.length;
					for(i=0; i<L; i++) {
						meshBuffer[i].dispose();
					}
				}catch(e:Error){
					//var tm;
				}
				meshBuffer = new Vector.<MeshBuffer>();
			}
			
		}
		
		
	}
}