package we3d.renderer 
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.mesh.MeshProgram;
	import we3d.scene.Scene3d;

	use namespace we3d;
	
	/**
	 * The RenderSession object is used internally during rendering. It is already created in the view.
	 */ 
	public class  RenderSession 
	{
		public function RenderSession () {}
		
		public var viewId:int;
		public var scene:Scene3d;
		public var polys:Array;
		public var sprites:Array;
		public var container:Sprite;
		public var nativeContainer:Sprite;
		public var sortSprites:Boolean=true;
		public var sortPolys:Boolean=true;
		public var _graphics:Graphics;
		public var bmp:BitmapData;
		public var width:Number=0;
		public var height:Number=0;
		public var currentFrame:Number=1;
		public var camera:Camera3d;
		public var dispatcher:EventDispatcher;
		public var context3d:Object;
		public var currPrg:MeshProgram;
		public var allBuffersDirty:Boolean=false;
		public var gpuBlendMode:int=0; // 0=Normal, 1=Transparency
		public var gpuBuffers:int=0;	// Assigned vertex buffers
		public var textures:int=0;
		
		public var defaultSession_viewId:int;
		public var defaultSession_scene:Scene3d;
		public var defaultSession_polys:Array;
		public var defaultSession_sprites:Array;
		public var defaultSession_container:Sprite;
		public var defaultSession_nativeContainer:Sprite;
		public var defaultSession_sortSprites:Boolean;
		public var defaultSession_sortPolys:Boolean;
		public var defaultSession__graphics:Graphics;
		public var defaultSession_bmp:BitmapData;
		public var defaultSession_width:Number=0;
		public var defaultSession_height:Number=0;
		public var defaultSession_currentFrame:Number=1;
		public var defaultSession_camera:Camera3d;
		public var defaultSession_dispatcher:EventDispatcher;
		public var defaultSession_context3d:Object;
		
		public function useDefaultSession () :void {
			_graphics = defaultSession__graphics;
			bmp = defaultSession_bmp;
			height = defaultSession_height;
			width = defaultSession_width;
			sortSprites = defaultSession_sortSprites;
			sortPolys = defaultSession_sortPolys;
			polys = defaultSession_polys;
			sprites = defaultSession_sprites;
			scene = defaultSession_scene;
			viewId = defaultSession_viewId;
			currentFrame = defaultSession_currentFrame;
			camera = defaultSession_camera;
			container = defaultSession_container;
			nativeContainer = defaultSession_nativeContainer;
			dispatcher = defaultSession_dispatcher;
			context3d = defaultSession_context3d;
		}
		
		public function setDefaultSession (session:RenderSession) :void {
			defaultSession__graphics = session._graphics;
			defaultSession_bmp = session.bmp;
			defaultSession_height = session.height;
			defaultSession_polys = session.polys;
			defaultSession_sprites = session.sprites;
			defaultSession_container = session.container;
			defaultSession_nativeContainer = session.nativeContainer;
			defaultSession_sortSprites = session.sortSprites;
			defaultSession_sortPolys = session.sortPolys;
			defaultSession_scene = session.scene;
			defaultSession_viewId = session.viewId;
			defaultSession_width = session.width;
			defaultSession_currentFrame = session.currentFrame;
			defaultSession_camera = session.camera;
			defaultSession_dispatcher = session.dispatcher;
			defaultSession_context3d = session.context3d;
		}
		
	}
	
}