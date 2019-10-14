package we3d.layer 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Point;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.mesh.Face;
	import we3d.renderer.RenderSession;
	import we3d.ui.Console;
	
	use namespace we3d;
	
	/**
	* A Layer is used for 2d output. Every Layer have a Sprite and optional a Bitmap. 
	* By default the containers of the layer are created and attached to the root target of the View <br/><br/>
	* 
	* Multiple layers in a View can be sorted by the polygons the Layer contains <br/><br/>
	* 
	* A Layer can be added to one View only
	*/
	public class Layer 
	{
		public function Layer (allowBitmap:Boolean=false) {
			useBitmap = allowBitmap;
		}
		
		/**
		* The width of the Layer, read only
		*/
		we3d var width:Number=0;
		/**
		* The height of the Layer, read only
		*/
		we3d var height:Number=0;
		/**
		* The main container of the layer. It contains a sprite for native polygons and optional a bitmap if useBitmap is true
		*/
		we3d var target:Sprite;
		/**
		* The Bitmap contains rendered polygons from all Scanline Rasterizers.
		*/
		we3d var bmpContainer:Bitmap=null;
		/**
		* The BitmapData of the Bitmap
		*/
		public var bmp:BitmapData;
		/**
		* If backToFront is true, the polygons are sorted from back to front, otherwise the reverse order from front to back.
		*/
		public var backToFront:Boolean=true;
		/**
		* If swapDepth is true, the Layer is sorted with other Layers in the view
		*/
		public var swapDepth:Boolean=false;
		/**
		 * If sortPolys is true, the polygons in the Layer are sorted
		 */
		public var sortPolys:Boolean=true;
		/**
		* To use a background in the layer assign a Backdrop instance
		*/
		public var backdrop:Backdrop;
		/**
		* If graphics2Bitmap is true, all vector graphics from native rasterizer will be copied over the scanline polygons in the bitmap of the layer. This will free all vector graphics from memory after rendering
		*/
		public var graphics2Bitmap:Boolean=false;
		/**
		* If autoClear is true, the graphics in the layer will be cleared before every render
		*/
		we3d var autoClear:Boolean=true;
		/**
		 * If autoResize is true, the layer is resized when the size of the view changes
		 */
		public var autoResize:Boolean=true;
		/**
		* @private
		*/
		we3d var totalAvg:Number=0;
		/**
		* @private
		*/
		we3d var polys:Array=[];
		/**
		* @private
		*/
		we3d var sprites:Array=[];
		
		/**
		* @private
		*/
		we3d var _nativeContainer:Sprite;
		/**
		* @private
		*/
		we3d var _container:Sprite;
		/**
		* @private
		*/
		we3d var _graphics:Graphics;
		
		private var useBitmap:Boolean=false;
		
		private var camCenter:Point = new Point();
		private var sizeUpdated:Boolean = true;
		private var _gpuEnabled:Boolean=false;
		
		
		// default GPU background color
		public var bgrRed:Number=0;
		public var bgrGreen:Number=0;
		public var bgrBlue:Number=0;
		public var bgrAlpha:Number=1;
		
		// GPU Properties
		public var antiAliasing:int=0;
		public var errorChecking:Boolean=false;
		public var depthAndStencil:Boolean=true;
		public var context3d:Object=null;
		private var stageId:int=0;
		private var tmpSession:RenderSession;
		
		/**
		* Returns the graphics container of this Layer
		*/
		public function get container () :Sprite {
			return _container;
		}
		public function set container (mc:Sprite) :void {
			_container = mc;
			_graphics = mc.graphics;
		}
		
		we3d var _sortSprites:Boolean = true;
		public function get sortSprites () :Boolean {	return _sortSprites;	}
		public function set sortSprites (v:Boolean) :void {	_sortSprites;	}
		
		/**
		* @private
		* Called by a view when the layer is added to the view
		* @param	view
		* @param	rootTarget	background, foreground or sorted target
		*/
		we3d function initialize (session:RenderSession, rootTarget:Sprite) :void {
			
			if(width<=0) width = session.width;
			if(height<=0) height = session.height;
			
			if(target == null) {
				target = new Sprite();
				rootTarget.addChild(target);
			}
			
			if(useBitmap) {
				if(bmpContainer == null) {
					bmpContainer = new Bitmap(null);
					target.addChild(bmpContainer);
				}
				
				if(width == 0) width = session.width;
				if(height == 0) height = session.height;
				
				createBitmapData();
			}
			
			if(!_container) {
				container = new Sprite();
				target.addChild(_container);
			}
			if(!_nativeContainer) {
				_nativeContainer = new Sprite();
				target.addChild(_nativeContainer);
			}
		}
			
		/**
		* @private
		* Called by a view when the layer is removed from the view
		* @param	view
		* @param	rootTarget	background, foreground or sorted target
		*/
		we3d function remove (session:RenderSession, rootTarget:Sprite) :void {
			rootTarget.removeChild(target);
			bmpContainer = null;
			_container = null;
			target = null;
			if(context3d && context3d.driverInfo != "Disposed") context3d.dispose();
			context3d = null;
		}
		
		we3d function updateSession (session:RenderSession) :void {
			session._graphics = _graphics;
			session.container = _container;
			session.nativeContainer = _nativeContainer;
			session.sprites = sprites;
			session.sortSprites = _sortSprites;
			session.sortPolys = sortPolys;
			session.bmp = bmp;
			session.polys = polys;
			session.context3d = context3d;
		}
		
		/**
		* @private
		*/
		we3d function createBitmapData () :void {
			if(bmp) bmp.dispose();
			
			if(width > 0 && height > 0) {
				bmp = new BitmapData(width, height, true, 0);
				bmpContainer.bitmapData = bmp;
			}
		}
		
		/**
		* @private
		*/
		we3d function initFrame (session:RenderSession) :void {
			
			if(polys.length > 0) 
			{
				polys = [];
				session.polys = polys;
			}
			
			if(useBitmap) bmp.lock();
			
			if(context3d) 
			{
				context3d.clear( bgrRed, bgrGreen, bgrBlue, bgrAlpha );
				session.currPrg = null;
			}
			
			if(backdrop) 
			{
				if(session.context3d != null) {
					backdrop.drawToGPU(session, this);
				}
				else if(useBitmap) 
				{
					backdrop.drawToBitmap(session, this);
				}
				else backdrop.drawToSprite(session, this);
			}
			
			if(_nativeContainer != null && _nativeContainer.numChildren > 0) {
				
				var cam:Camera3d = session.scene.cam;
				Camera3d.ct.transpose(cam.transform.gv);
				
				if( sizeUpdated ) 
				{
					var space:Sprite = _nativeContainer;
					
					camCenter.x = cam.t;
					camCenter.y = cam.s;
					
					var psp = new (Class(Object3d.getClass("flash.geom::PerspectiveProjection")));
					
					space.transform.perspectiveProjection = psp;
					
					space.transform.perspectiveProjection.projectionCenter = camCenter;
					space.transform.perspectiveProjection.fieldOfView = cam.fov/Math.PI*180;
					space.transform.perspectiveProjection.focalLength = cam.focalLength;
					sizeUpdated = false;
				}
			}
						
		}
		
		/**
		* @private
		* Draw and sort the list of polygons
		* @param	view
		*/
		we3d function endFrame (session:RenderSession) :void {
			
			var L:int = polys.length;
			var i:int;
			
			if(L>0) {
				
				if(backToFront) polys.sortOn("z", Array.NUMERIC | Array.DESCENDING);
				else polys.sortOn("z", Array.NUMERIC);
				
				var p:Face;
				
				if(swapDepth) {
					var t:Number = 0;
					for(i=0; i<L; i++) {
						p = polys[i];
						t -= p.z;
						p.surface.rasterizer.draw(p.surface, session, p);
					}
					totalAvg = t/L;
				}else{
					for(i=0; i<L; i++) {
						p = polys[i];
						p.surface.rasterizer.draw(p.surface, session, p);
					}
				}
			}
			
			if(sortSprites) 
			{
				
				if(_nativeContainer != null && _nativeContainer.numChildren > 0) 
				{
					L = _nativeContainer.numChildren;
					
					sprites.sortOn( "zdepth", Array.NUMERIC | Array.DESCENDING);
					for(i=0; i<L; i++) {
						_nativeContainer.setChildIndex( sprites[i].clip, i );
					}
				}
			}
			
			if(graphics2Bitmap) {
				bmp.draw( _container );
				_graphics.clear();
			}
			
			if(context3d != null) {
				context3d.present();
			}
			
			if( session.allBuffersDirty ){
				session.allBuffersDirty = false;
			}
			
			if(useBitmap) {
				bmp.unlock();
			}
			
		}
		
		we3d function clearRenderData (session:RenderSession) :void 
		{
			polys = [];
			//session.polys = polys;
		}
		
		/**
		* Called when the view clears the last render, view.autoClear and layer.autoClear have to be true
		*/
		public function clear () :void {
			
			_graphics.clear();
			if(useBitmap) bmp.fillRect(bmp.rect, 0);
			
		}
		
		/**
		* Resize the Layer
		* @param	w	width in pixels
		* @param	h	height in pixels
		*/
		public function setSize (w:int, h:int) :void {
			width = w;
			height = h;
			sizeUpdated = true;
			if(useBitmap && bmpContainer) createBitmapData();
			
			if(context3d != null && context3d.driverInfo != "Disposed") 
			{
				var p:Point = _container.localToGlobal(new Point(0,0));
				_container.stage.stage3Ds[stageId].x = p.x;
				_container.stage.stage3Ds[stageId].y = p.y;  // w, h);
				 
				//context3d.setScissorRectangle( new Rectangle(0, 0, w, h) );
				context3d.configureBackBuffer(w, h, antiAliasing, depthAndStencil);
			}
		}
		
		
		public function get bgrColor () :uint {
			return int(bgrRed*255) << 16 | int(bgrGreen*255) << 8 | (bgrBlue*255);
		}
		
		public function set bgrColor (v:uint) :void {
			bgrRed = (v >> 16 & 255)/255;
			bgrGreen = (v >> 8 & 255)/255;
			bgrBlue = (v & 255)/255;
		}
		
		private function onContext (e:Event):void 
		{
			var stage3d = e.currentTarget;
			
			try 
			{
				if(stage3d.context3D == null) 
				{
					tmpSession.dispatcher.dispatchEvent( new Event("evtOnGpuError") );
					context3d = null;
					return;
				}
				
				context3d = stage3d.context3D;
				
				Console.log( "On Context3D: " + context3d.driverInfo); 
				
				// re-upload all data to gpu
				tmpSession.allBuffersDirty = true;
				
				context3d.enableErrorChecking = errorChecking;
				context3d.configureBackBuffer( width, height, antiAliasing, depthAndStencil );
				context3d.setCulling( /*Context3DTriangleFace.FRONT*/ "front" );
				
				if(width > 0 && height > 0) setSize(width, height);
				Object(tmpSession.dispatcher).invalidate();
				
				tmpSession.dispatcher.dispatchEvent( new Event("evtOnGpu") );
			}
			catch(e:Error)
			{
				// GPU Not Available
				tmpSession.dispatcher.dispatchEvent( new Event("evtOnGpuError") );
				context3d = null;
			}
		}
		
		we3d function enableGPU (enabled:Boolean, session:RenderSession) :void 
		{
			_gpuEnabled = enabled;
			tmpSession = session;
			
			width = session.width;
			height = session.height;
			
			if(_container.stage) {
				stageAdded( null );
			}else{
				_container.addEventListener( Event.ADDED_TO_STAGE, stageAdded );
			}
		
		}
		
		private function stageAdded (e:Event) :void 
		{
			var stage3d;
			
			_container.removeEventListener( Event.ADDED_TO_STAGE, stageAdded ); 
			
			if(!_gpuEnabled) {
				if( context3d != null ) 
				{
					if(stageId >= 0) {
						stage3d = _container.stage.stage3Ds[stageId];
						stage3d.removeEventListener( Event.CONTEXT3D_CREATE, onContext );
						stage3d.removeEventListener( ErrorEvent.ERROR, contextCreationError );
					}
					if(context3d.driverInfo != "Disposed") context3d.dispose();
					context3d = null;
					stageId = -1;
				}
				
			}else{
			
				try {
					
					if( context3d != null && context3d.driverInfo != "Disposed" ) context3d.dispose();
					
					stageId = -1;
					
					var L:int = _container.stage.stage3Ds.length;
					
					for(var i:int=0; i<L; i++ ) 
					{
						if( _container.stage.stage3Ds[i].context3D == null ||  _container.stage.stage3Ds[i].context3D.driverInfo == "Disposed") {
							stageId = i;
							break;
						}
					}
					
					if(stageId == -1) {
						Console.log("Run out of stages");
						throw new Error("Run out of stages");
					}else{
						
						Console.log("Request Context3D, StageId " + stageId);
						
						stage3d = _container.stage.stage3Ds[stageId];
						stage3d.addEventListener( Event.CONTEXT3D_CREATE, onContext );
						stage3d.addEventListener( ErrorEvent.ERROR, contextCreationError );
						stage3d.requestContext3D();
					
					}
					
				} 
				catch(e:Error) 
				{
					tmpSession.dispatcher.dispatchEvent( new Event("evtOnGpuError") );
					context3d = null;
				}
			}
		}
		
		private function contextCreationError( error:ErrorEvent ):void
		{
			Console.log( "Contect3D Create Error: " + error.errorID + ": " + error.text );
			tmpSession.dispatcher.dispatchEvent( new Event("evtOnGpuError") );
			context3d = null;
		}
		
	}
	
}