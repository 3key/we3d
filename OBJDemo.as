package {
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import we3d.view.View3d;
	import we3d.scene.Scene3d;
	import we3d.scene.SceneObject;
	import we3d.loader.OBJLoader;
	import we3d.samples.UserCamera;
	import we3d.layer.GradientBackdrop;
	import we3d.renderer.realistic.ClipFrustum;
	import we3d.filter.ZBuffer;
	
	public class OBJDemo extends Sprite {
		
		public function OBJDemo () {}
		
		public var scene:Scene3d;
		public var view:View3d;
		public var ucam:UserCamera;
		private var zb:ZBuffer = new ZBuffer(550,400);
		
		public function init () :void {
			
			scene = new Scene3d();
			scene.cam.initProjection( 0.9, 1, 1000, 550, 400);
			scene.cam.transform.setPosition (0,80,-210);
			scene.cam.transform.setRotation (Math.PI/9, 0, 0);
			
			view = new View3d(550, 400);
			view.scene = scene;
			view.renderer = new ClipFrustum();
			view.firstLayer.backdrop = new GradientBackdrop(0x002850, 0x78B4F0, 0x32281E, 0x64503C, 5, 5 );
			addChild(view.viewport);
			
			view.addFilter(zb);
			
			var ldr:OBJLoader = new OBJLoader();
			ldr.addEventListener(Event.INIT, initOBJ);
			ldr.addEventListener(Event.COMPLETE, completeOBJ);
			ldr.scale = 5;
			
			
			ldr.loadFile("wd3d.obj");
		}
		
		private function initOBJ (e:Event)  :void {
			trace("File downloaded, starting with parse...");
		}
		
		private function completeOBJ (e:Event)  :void {
			
			ucam = new UserCamera(view, 2);
			
			var ldr:OBJLoader = OBJLoader(e.target);
			
			trace("File parsed, " + ldr.objects.length + " objects, "  + ldr.surfaces.length  +  " surfaces, " + ldr.fileImages.length + " images ");
			
			scene.add( ldr.objects );
			
			scene.invalidate();
		}
	}
}