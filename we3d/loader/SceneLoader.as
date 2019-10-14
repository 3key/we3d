package we3d.loader 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Scene;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLRequest;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.loader.ImageLoadEvent;
	import we3d.loader.Loader3d;
	import we3d.material.Surface;
	import we3d.mesh.VertexMap;
	import we3d.scene.LightGlobals;
	import we3d.scene.Scene3d;
	import we3d.scene.SceneLight;
	import we3d.scene.SceneObject;
	import we3d.ui.Console;
	
	use namespace we3d;
	
	/**
	* Base Class for a Loader wich support scene object like lights and cameras
	*/
	public class SceneLoader extends Loader3d 
	{
		public function SceneLoader () {}
		
		/**
		* If true, the loader also loads resources wich are referenced in the file. 
		* Resources can be gif, jpg and png images 
		* If the file contains external resources the loader waits until everything is downloaded
		*/
		public var loadResources:Boolean = true;
		
		public var useLights:Boolean = true;
		public var lightGlobals:LightGlobals;
		
		/**
		* Contains the parsed objects from the file
		*/
		public function get objects () :Array {
			return fileObjects;
		}
		/**
		* Contains the parsed lights from the file if the file format support lighting
		*/
		public function get lights () :Array {
			return fileLights;
		}
		/**
		* Contains the parsed surfaces from all objects in the file
		*/
		public function get surfaces () :Array {
			return fileSurfaces;
		}
		/**
		* Contains the parsed cameras from the file
		*/
		public function get cameras () :Array {
			return fileCameras;
		}
		/**
		* Returns the number of parsed objects
		*/
		public function get numObjects () :int {
			if(fileObjects == null) 	return 0;
			return fileObjects.length;
		}
		/**
		* Returns the number of parsed lights
		*/
		public function get numLights () :int {
			if(fileLights == null) 	return 0;
			return fileLights.length;
		}
		/**
		* Returns the number of parsed surfaces
		*/
		public function get numSurfaces () :int {
			if(fileSurfaces == null) return 0;
			return fileSurfaces.length;
		}
		/**
		* Returns the number of parsed cameras
		*/
		public function get numCameras () :int {
			if(fileCameras == null) return 0;
			return fileCameras.length;
		}
		/**
		* Returns the number of loaded images
		*/
		public function get numImages () :int {
			if(fileBitmaps == null) return 0;
			return fileBitmaps.length;
		}
		/**
		 * Returns the number of loaded sprites
		 */
		public function get numSprites () :int {
			if(fileSprites == null) return 0;
			return fileSprites.length;
		}
		
		/**
		* Returns a parsed object by id
		*/
		public function getObjectAt (id:int) :SceneObject		{ 	return fileObjects[id]; }
		/**
		* Returns a parsed light by id
		*/
		public function getLightAt (id:int) :SceneLight		{ 	return fileLights[id]; }
		/**
		* Returns a parsed surface by id
		*/
		public function getSurfaceAt (id:int) :Surface			{	return fileSurfaces[id]; }
		/**
		* Returns a parsed camera by id
		*/
		public function getCameraAt (id:int) :Camera3d			{	return fileCameras[id]; }
		/**
		 * Returns a parsed sprite by id
		 */
		public function getSpriteAt (id:int) :SceneObject			{	return fileSprites[id]; }
		/**
		* Returns a parsed vertex map by id
		*/
		public function getMapAt (id:int) 	:VertexMap			{	return fileVmaps[id]; }
		/**
		* Returns a parsed object by name
		*/
		public function getObjectByName (name:String) :SceneObject 	{	return objectsByName[name];	}
		/**
		* Returns a parsed light by name
		*/
		public function getLightByName (name:String) :SceneLight	{	return lightsByName[name];	}
		/**
		* Returns a parsed surface by name
		*/
		public function getSurfaceByName (name:String) :Surface		{	return surfacesByName[name]; }
		/**
		* Returns a parsed camera by name
		*/
		public function getCameraByName (name:String) :Camera3d		{	return camerasByName[name]; }
		/**
		 * Returns a parsed sprite by name
		 */
		public function getSpriteByName (name:String) :SceneObject		{	return spritesByName[name]; }
		/**
		* Returns a parsed vertex map by name
		*/
		public function getMapByName (name:String) :VertexMap		{	return vmapsByName[name]; }
		
		public static var EVT_IMAGES_LOADED:String = "evtImagesLoaded";
		public static var EVT_IMAGE_LOADED:String = "evtImageLoaded";
		
		/**
		* @private
		*/
		internal var fileObjects:Array;
		/**
		* @private
		*/
		internal var fileLights:Array;
		/**
		* @private
		*/
		internal var fileSurfaces:Array;
		/**
		* @private
		*/
		internal var fileCameras:Array;
		/**
		 * @private
		 */
		internal var fileSprites:Array;
		/**
		* @private
		*/
		internal var fileVmaps:Array;
		/**
		* @private
		*/
		public var objectsByName:Object;
		/**
		* @private
		*/
		public var lightsByName:Object;
		/**
		* @private
		*/
		public var camerasByName:Object;
		/**
		 * @private
		 */
		public var spritesByName:Object;
		/**
		* @private
		*/
		public var surfacesByName:Object;
		/**
		* @private
		*/
		public var vmapsByName:Object;
		/**
		* @private
		*/
		internal var images:Array;
		/**
		* @private
		*/
		internal var currSurface:Surface;
		/**
		* @private
		*/
		internal var currObject:SceneObject;
		/**
		* @private
		*/
		internal var currLight:SceneLight;
		/**
		* @private
		*/
		internal var currCamera:Camera3d;
		/**
		* @private
		*/
		internal var bitmaps:Array;
		/**
		* Contains an array of strings with the image names found in the file
		*/
		public function get fileImages () :Array {
			return images;
		}
		/**
		* contains an array of objects with bmp, the bitmapData, path and other properties, mainly used for surface lookup after file loading
		*/
		public function get fileBitmaps () :Array {
			return bitmaps;
		}
		
		private var totalImages:int = 0;
		private var bmpsLoaded:int=0;
		
		public function get scene () :Scene3d {
			var s:Scene3d = new Scene3d();
			
			if(this.numCameras>0) {
				s.cam = Camera3d(this.cameras[0]);
			}
			var L:int=this.numObjects;
			for(var i:int=0; i<L; i++) {
				s.objectList[i] = SceneObject(this.objects[i]);
			}
			return s;
		}
		
		/**
		* @private
		*/
		internal function init () :void {
			vmapsByName = {};	objectsByName = {};	lightsByName = {};	surfacesByName = {};	camerasByName = {};	spritesByName = {};
			fileVmaps = [];		fileObjects = [];	fileLights = [];	fileSurfaces = [];	fileCameras = [];	fileSprites = [];
			images = [];
			bitmaps = [];
			totalImages = 0;
			bmpsLoaded = 0;
		}
		
		/**
		* @private
		*/
		internal function clearMemory () :void {
			
			images = null;
			bitmaps = null;
			currLight = null;
			currObject = null;
			currCamera = null;
			currSurface = null;
			
			vmapsByName = null;	objectsByName = null;	lightsByName = null;	surfacesByName = null;	camerasByName = null;	spritesByName = null;
			fileVmaps = null;	fileObjects = null;		fileLights = null;		fileSurfaces = null;	fileCameras = null;		fileSprites = null;
			Console.log( "File parsed: " + filepath );
		}
		
		/**
		* @private
		* load a bitmap from the images array
		*/
		internal function loadBitmap (id:int) :void {
			
			var file:String = images[id];
			var L:int = bitmaps.length;
			
			var pth:String = file;
			if(subdirResources && file.indexOf(filedir) == -1) 
			{
				pth = filedir + file;
			}
			
			for(var i:int=0; i<L; i++) {
				if(bitmaps[i].path == pth) {
					// More Surfaces use this image
					if(bitmaps[i].bmp != null) {
						return;
					}
				}
			}
			try {
				var loader:Loader = new Loader();
	            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				
				var request:URLRequest = new URLRequest(pth);
				
				bitmaps.push( { path: pth, bmp: null, ldr: loader, bmpid: bitmaps.length, imgid: id, sprite: null } );
				
				
				loader.load(request);
				totalImages++;
			}
			catch(e:Error) 
			{
				Console.log("Unable to load bitmap: '" + file + "' fullpath: " + pth);
			}
		}
		private function errorHandler (event:Event) :void {
			var loader:Loader = Loader(event.target.loader);
			Console.log( "Error loading resource: " + bmpsLoaded);
			bmpsLoaded++;
			if(bmpsLoaded >= totalImages) {
				dispatchEvent(new Event(EVT_IMAGES_LOADED));
			}
		}
		
		private function completeHandler (event:Event) :void {
            var loader:Loader = Loader(event.target.loader);
			var image:Bitmap;
			var isswf:Boolean=false;
			var sp:Sprite;
			
			if(loader.content is Sprite) {
				isswf=true;
				sp = Sprite(loader.content);
				var bmd:BitmapData = new BitmapData(loader.content.width, loader.content.height, true, 0);
				bmd.draw( loader.content );
				image = new Bitmap( bmd );
			}else{
            	image = Bitmap(loader.content);
			}
			
			var lp:int = loader.contentLoaderInfo.url.lastIndexOf("/");
			var file:String;
			
			if(lp == -1) {
				file = filedir + loader.contentLoaderInfo.url
			}else{
				file = filedir + loader.contentLoaderInfo.url.substring(lp+1);
			}
			
			var L:int = bitmaps.length;
			for(var i:int=0; i<L; i++) 
			{
				if(bitmaps[i].path.indexOf(file) >= 0) {
					
					if(isswf) {
						bitmaps[i].sprite = sp;
						bitmaps[i].bmp = image.bitmapData;
					}else{
						bitmaps[i].bmp = image.bitmapData.clone();
					}
					bmpsLoaded++;
					dispatchEvent(new ImageLoadEvent(EVT_IMAGE_LOADED, bitmaps[i].bmpid, bitmaps[i].imgid));
					break;
				}
			}
			
			if(bmpsLoaded >= totalImages) 
			{
				Console.log( totalImages + " bitmaps from " + filepath + " loaded." );
				dispatchEvent(new Event(EVT_IMAGES_LOADED));
			}
		}
	
	}
	
}