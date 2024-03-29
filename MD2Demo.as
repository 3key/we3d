package {
	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	
	import we3d.view.View3d;
	import we3d.core.Object3d;
	import we3d.scene.Scene3d;
	import we3d.scene.SceneObject;
	import we3d.loader.MD2Loader;
	import we3d.samples.UserCamera;
	import we3d.layer.GradientBackdrop;

	 import we3d.filter.ZBuffer;
	import flash.display.Loader;
	import we3d.material.Surface;
	import we3d.scene.SceneObjectMorph;
	import we3d.material.BitmapAttributes;
	import we3d.rasterizer.ScanlineTX;
	import we3d.ui.Console;
	import we3d.ui.ShowConsole;
	
	public class MD2Demo extends Sprite {
		
		public function MD2Demo () {}
		
		public var scene:Scene3d;
		public var view:View3d;
		public var ucam:UserCamera;
		private var zb:ZBuffer = new ZBuffer(800,600);
		public var cat:SceneObjectMorph;
		private var rows:int= 35;
		private var cols:int = 5;
		private var rowspace:Number = 80;
		private var colspace:Number = 50;
		
		public function init () :void {
			
			scene = new Scene3d();
			scene.cam.initProjection( 0.9, 1, 1000, 800, 600);
			scene.cam.transform.setPosition (130,17,-131);
			scene.cam.transform.setRotation (Math.PI/19, -Math.PI/11, 0);
			
			view = new View3d(800, 600);
			view.gpuEnabled = true;
			view.scene = scene;
			view.renderState = false;
			
			view.firstLayer.backdrop = new GradientBackdrop(0x002850, 0xfa1550, 0x32281E, 0x54402C, 5, 5 );
			addChild(view.viewport);
			
			view.addFilter(zb);
			
			var ldr:MD2Loader = new MD2Loader();
			ldr.addEventListener(Event.INIT, init3DS);
			ldr.addEventListener(Event.COMPLETE, complete3DS);
			ldr.scale = 1;
			
			ldr.loadFile("cat.md2");
			
			Console.log("Loading file cat.md2...");
			
			ShowConsole.printLogFile(this);
		}
		
		private function init3DS (e:Event)  :void {
			Console.log("File downloaded, starting with parse...");
		}
		
		private function textureCompleteHandler (event:Event) :void {
			var loader:Loader = Loader(event.target.loader);
            var image:Bitmap = Bitmap(loader.content);
			var sf:Surface = cat.polygons[0].surface;
			sf.attributes = new BitmapAttributes(image.bitmapData);
			sf.rasterizer = new ScanlineTX();
			sf.programDirty = true;
			cat.frameBuffersDirty = true;
			view.forceUpdate = true;
			
			cat.transform.x = colspace*2;
			cat.transform.z = -25;
			
			var rowpos:Number = 0;
			var colpos:Number = 0;
			
			var ct:SceneObjectMorph;
			
			for(var i:int = 0; i<rows; i++) 
			{
				colpos = 0;
				for(var j:int=0; j<cols; j++) 
				{
					ct = SceneObjectMorph( cat.clone() );
					
					var id:int = int(Math.random()*walkFrames.length);
					trace("Set CF: " +id);
					
					ct.setFrameByName( walkFrames[id] );
					
					ct.frameFps = 16 + Math.random()*8;
					
					ct.transform.x = colpos + (Math.random()*colspace/2);
					ct.transform.z = rowpos + (Math.random()*rowspace/2);
					scene.objectList.push( ct );
					
					colpos += colspace;
				}
				rowpos += rowspace;
			}
			Console.log("Scene loaded correctly");
			Console.log("Use Arrow keys to move the camera \nClick and drag to rotate the camera");
			
			addEventListener( Event.ENTER_FRAME, frameHandler );
		}
		
		private function complete3DS (e:Event)  :void {
			
			var ldr:MD2Loader = MD2Loader(e.target);
			
			Console.log("File parsed, " + ldr.objects.length + " objects, "  + ldr.surfaces.length  +  " surfaces, " + ldr.fileImages.length + " images ");
			
			cat = SceneObjectMorph(ldr.objects[0]);
			
			// load md2 texture
			var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, textureCompleteHandler);
			var request:URLRequest = new URLRequest("cat.png");
			loader.load(request);
			
			scene.add( ldr.objects );
			
			catWalk();
			
			ucam = new UserCamera(view, 2);
			
		}
		
		private function frameHandler (e:Event) :void 
		{
			var objs:Vector.<Object3d> = view.scene.objectList;
			for(var i:int=0; i < objs.length; i++) {
				objs[i].transform.z -= 0.25;				
			}
			view.invalidate();
		}
		
		private var sitFrames:Array;
		private var walkFrames:Array;
		
		private function catSit ()  :void 
		{
			if(sitFrames == null) {
				sitFrames=[];
				var names:Array = cat.frameNames;
				names.sort();
				
				cat.clearPlayList();
				
				var L:int=names.length;
				for(var i:int=0; i<L; i++){
					if(names[i].indexOf("sit") >= 0){
						sitFrames.push(names[i]);
					}
				}
			}
			cat.setPlayList(sitFrames);
		}
		
		private function catWalk ()  :void 
		{
			if(walkFrames == null) {
				walkFrames=[];
				var names:Array = cat.frameNames;
				names.sort();
				
				cat.clearPlayList();
				
				var L:int=names.length;
				for(var i:int=0; i<L; i++) {
					if(names[i].indexOf("walk") >= 0) {
						walkFrames.push(names[i]);
					}
				}
			}
			cat.setPlayList(walkFrames);
		}
		
		
	}
}