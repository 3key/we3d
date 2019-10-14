package we3d.core 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.culling.BoxCulling;
	import we3d.core.culling.IObjectCulling;
	import we3d.core.transform.Transform3d;
	import we3d.math.Matrix3d;
	import we3d.renderer.RenderSession;
	
	use namespace we3d;
	  
	/**
	* Object3d is the base class for all SceneObjects, Lights, Bones, etc.
	*/
	public class Object3d extends EventDispatcher
	{
		public function Object3d () {}
		
		/**
		* Store optional dynamic properties
		*/
		public var shared:Object={};
		
		public static function getClass (path:String) :Object {
			var c:Object;
			
			try {
				c = getDefinitionByName(path);
			}catch(e:Error) {
				c = null;
			}
			return c;
		}
		
		/**
		* The transform contains the position, rotation and other properties like parent, target and keyframe channels 
		*/
		public var transform:Transform3d = new Transform3d();
		/**
		* Performs the object culling, by default the boxculling is recommended
		*/
		public var objectCuller:IObjectCulling = new BoxCulling();
		/**
		* Read Only, true if the object is culled by the object culler
		*/
		public var culled:Boolean=false;
		/**
		* Frame counter of the last rendered frame, if the frameCounter equals Transform3d.FCounter then the object was rendererd
		*/
		public var frameCounter:int=0;
		/**
		* If frameInit is true, the transform will be initialized with initFrame, the default Transform3d don't need frame init but don't support scaling and parenting, you have to assign a Hierarchy transform, see setTransform method
		*/
		public var frameInit:Boolean=false;
		/**
		* Camera matrix with projection and object transformation
		*/
		public var camMatrix:Matrix3d = new Matrix3d();
		
		/**
		 * Read Only, the children wich have been added with addChild method or the parent property
		 */ 
		we3d var children:Vector.<Object3d>;
		we3d var _parent:Object3d=null;
		
		/**
		 * Reupload geometry data to the GPU. If buffersDirty is true, the buffers will be uploaded when the object gets rendered the next time.
		 * The buffers should be updated when the geometry or the materials changes.
		 */
		public var buffersDirty:Boolean=true;
		
		/**
		* Get and set the parent object to create hierarchies, setting the parent property automatically calls the addChild and removeChild methods. <br/> 
		 * Use null to set the root as the parent. <br/>The parent can not be set if the object is already assigned higher in the hierarchy of the object
		*/ 
		public function set parent (o:Object3d) :void {
			if(o == null) {
				if(_parent is Object3d) {
					_parent.removeChild(this);
				}
				_parent = null;
			}
			else if(_parent == null) {
				if(o is Object3d) {
					o.addChild (this);
				}
			}
			else {
				var p:Object3d = o._parent;
				if(p != null) {
					while(p) {
						if(p == this) return;
						p = p._parent;
					}
					if(_parent is Object3d) {
						_parent.removeChild(this);
					}
					o.addChild(this);
				}
			}
		}
		public function get parent () :Object3d {
			return _parent;
		}
		
		/**
		* Returns the index in the children list or -1 if c is not a child of this object
		*/
		public function indexOfChild (c:Object3d) :int {
			if(children != null) return children.indexOf(c);
			return -1;
		}
		
		/**
		* Add a child to the transform to create hierachies in 3D <br/>
		* The Hierarchy transform has to be assigned to the children with the setTransform or parenting will not work
		* method: <br/>
		* <code>
		*	child.setTransform ( new we3d.core.transform.Hierarchy() );
		*	obj.addChild( child );
		* </code>
		*/
		public function addChild (c:Object3d) :void  {
			if(indexOfChild(c) >= 0) return;
			if(children == null) children = new Vector.<Object3d>();
			children.push(c);
			c._parent = this;
			c.transform._parent = this.transform;
		}
		
		/**
		* Remove a child, the child's parent will be set to root
		*/
		public function removeChild (c:Object3d) :Boolean {
			if(children != null) {
				var id:int = indexOfChild(c);
				if(id != -1) {
					children.splice(id,1);
					c.transform._parent = null;
					c._parent = null;
					return true;
				}
			}
			return false;
		}
		
		/**
		* Change the transform type and the available features in the transform (scaling, parenting, keyframing etc.)
		* <code> obj.setTransform ( new we3d.core.transform.Animated() ); </code>
		* @param	tr
		*/
		public function setTransform (tr:Transform3d) :void {
			
			var classname:String = getQualifiedClassName(tr);
			
			if(classname == "we3d.core.transform::Transform3d") {
				frameInit = false;
			}else{
				frameInit = true;
			}
			transform = tr;
		}
		
		public function disposeGPU () :void {}
		
		/**
		* @private
		*/
		public function initFrame (session:RenderSession) :Boolean {
			
			frameCounter = transform.frameCounter = Transform3d.FCounter;
			if(frameInit) transform.initFrame(session.currentFrame);
			
			culled = objectCuller.cull (this, session.camera);
			
			if(session.context3d) { 
				if(session.allBuffersDirty && culled) {
					buffersDirty = true;
				}
			}
			
			return culled;
		}
		
	}
}