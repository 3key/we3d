﻿package we3d.scene
{
	import we3d.core.Object3d;
	import we3d.core.Camera3d;
	
	/**
	* A Scene3d contains the SceneObjects and one Camera3d. 
	* Add or remove SceneObjects with the add and remove methods or use the objectList array directly. 
	* Call scene.invalidate() to tell a View that the scene need a redraw. 
	*/
	public class Scene3d 
	{
		/**
		* Create a new Scene instance
		* @param	camera	the Camera3d of the Scene, if null, a new camera will be created by default
		*/
		public function Scene3d (camera:Camera3d=null) {
			if(!camera) cam = new Camera3d();
			else cam = camera;
			cam.initCamFrame(1);
		}
		
		/** 
		* The objectList contains all SceneObjects
		*/
		public var objectList:Vector.<Object3d>=new Vector.<Object3d>();
		/** 
		* Camera of the scene
		*/
		public var cam:Camera3d;
		/**
		* Current frame to render
		*/
		public var currentFrame:Number=1;
		/**
		* True if the scene needs a redraw
		*/
		public var renderState:Boolean=false;
		/** 
		* Clear the objectList
		*/
		public function clearScene () :void {
			if(!objectList) objectList = new Vector.<Object3d>();
			else if(objectList.length > 0) objectList.splice(0, objectList.length);
		}
		/**
		* Add one or more objects to the scene
		* @param	c	the object
		*/
		public function add (... objs:Array) :void {
			
			var c:Object;
			var L:int = objs.length;
			var L2:int;
			var j:int;
			
			for(var i:int=0; i<L; i++) {
				c = objs[i];
				if(c is Array) {
					L2 = c.length;
					for(j=0; j<L2; j++) 
						add(c[j]);
				}else{
					if(getId(c) == -1) 
						objectList.push(c);
				}
			}
		}
		/**
		* Remove one or more objects from the scene
		*/
		public function remove (... objs:Array) :void {
			var c:Object;
			var L:int = objs.length;
			var L2:int;
			var j:int;
			var id:int;
			
			for(var i:int=0; i<L; i++) {
				c = objs[i];
				if(c is Array) {
					L2 = c.length;
					for(j=0; j<L2; j++) 
						remove(c[j]);
				}else{
					id = getId(c);
					if(id >= 0) 
						objectList.splice(id, 1);
				}
			}
		}
		
		public function disposeGPU () :void {
			var L:int = objectList.length;
			for(var i:int=0; i<L; i++) {
				objectList[i].disposeGPU()
			}
		}
		
		/**
		* Returns the id of the object in the objectList
		* @param	c
		*/
		public function getId (c:Object) :int {
			if(c is Object3d) return objectList.indexOf(c);
			return -1;
		}
		/**
		* Returns an object from the objectList
		* @param	id	the array id
		* @return	a SceneObject
		*/
		public function getObjectAt (id:int) :Object3d {
			return objectList[id];
		}
		/**
		* Returns the length of the objectList
		*/
		public function get numObjects () :int {
			return objectList.length;
		}
		/**
		* Invalidates the scene for redraw
		*/
		public function invalidate () :void {
			renderState = true;
		}
		/** 
		* @private
		*/
		public function initFrame (cf:Number) :void {
			cam.initCamFrame(cf);
		}
		/**
		* @private
		*/
		public function endFrame (cf:Number) :void {
			renderState = false;
		}
		
	}
}