package we3d.view
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.filter.BackgroundFilter;
	import we3d.layer.*;
	import we3d.renderer.IRenderer;
	import we3d.renderer.RenderSession;
	import we3d.renderer.realistic.ClipFrustum;
	import we3d.scene.Scene3d;
	use namespace we3d;
	
	/**
	* The View contains the rendered image. The View renders the Scene automatically if the Scene is invalid or every frame if forceUpdate is true. 
	* Use scene.invalidate() if something in the scene has changed. If autoRendering is disabled, you have to call the render method if you want to draw the scene.  
	* To display the rendered image, add  the <code>viewport</code> somewere to the stage. The <code>viewport</code> contains all layers of the view.  
	* The width and height of the view will be inherited to Layers if their size is zero. Note that the size of the Camera in the scene is not resized. You should keep the same width and height in View3d and Camera3d.
	*/
	public class View3d extends EventDispatcher 
	{	
		/**
		* View3d constructor
		* @param	_width width for layers
		* @param	_height height for layers
		* @param	_mc viewport container
		* @param	_firstLayer optional set the first layer, default is a Bitmap Layer
		* @param	_firstLayerType the type of the first layer (BACKGROUND, SORTED or FOREGROUND)
		* @param	_renderer the renderer of the View, if null, renderer.realistic.ClipFrustum is used
		*/
		public function View3d (_width:Number=550, _height:Number=400, 
								_mc:Sprite=null, 
								_firstLayer:Layer=null, 
								_firstLayerType:String=SORTED, 
								_autoRender:Boolean=true, 
								_renderer:IRenderer=null) {
			
			uid = ++viid;
			
			renderSession.viewId = uid;
			renderSession.dispatcher = this;
			renderSession.width = _width;
			renderSession.height = _height;
			
			if(_mc==null) {
				_mc = new Sprite();
				_mc.name = "viewport";
				viewport = _mc;
			}else{
				viewport = _mc;
				if(_mc.stage) {
					stageAdded(null);
				}
			}
			
			scene = new Scene3d();
			camera = scene.cam;
			
			stTarget = new Sprite();
			bgTarget = new Sprite();
			fgTarget = new Sprite();
			
			viewport.addChild(bgTarget);
			viewport.addChild(stTarget);
			viewport.addChild(fgTarget);
								
			lyrTable[SORTED]     = sortedLayers;
			lyrTable[BACKGROUND] = bgLayers;
			lyrTable[FOREGROUND] = fgLayers;
			
			tgtTable[SORTED]     = stTarget;
			tgtTable[BACKGROUND] = bgTarget;
			tgtTable[FOREGROUND] = fgTarget;
			
			if(_renderer) renderer = _renderer;
			
			width = _width;
			height = _height;
			
			if(!_firstLayer) _firstLayer = new Layer(true);
			setLayerAt(0, _firstLayer, _firstLayerType);
			
			autoRendering = _autoRender;
		}
		
		private static var viid:int=0;
		
		/**
		 * @private
		 */ 
		public var uid:int;
		
		/**
		* Event before the View renders a frame
		*/
		public static var EVT_BEGIN_DRAW:String = "evtBeginDraw";
		/**
		* Event after the View has rendered a frame
		*/
		public static var EVT_END_DRAW:String = "evtEndDraw";
		/**
		* Event when the View has cleared the previous render
		*/
		public static var EVT_CLEAR:String = "evtClear";
		/**
		* Event when the gpu context is created
		*/
		public static var EVT_ON_GPU:String = "evtOnGpu";
		/**
		 * Event when the gpu context can not be ceated
		 */
		public static var EVT_ON_GPU_ERROR:String = "evtOnGpuError";
		/**
		* Layer type for addLayer method, Sorted layers are sorted with other layers by the average depth of all polygons in the layer
		*/
		public static const SORTED:String = "sorted";
		/**
		* Layer type for addLayer method, Foreground layers are always in front of background and sorted layers, multiple foreground layers appear in the order they have been added to the View
		*/
		public static const FOREGROUND:String = "foreground";
		/**
		* Layer type for addLayer method, Background layers are always behind all other layers, multiple background layers appear in the order they have been added to the View
		*/
		public static const BACKGROUND:String = "background";
		/**
		* Reference to the first Layer wich is created in the View3d constructor
		*/
		public var firstLayer:Layer;
		/**
		* Renderer of the view
		*/
		public var renderer:IRenderer = new ClipFrustum();
		/**
		* Main target of all layers
		*/
		public var viewport:Sprite;
		/**
		* If true, the scene will be redrawn every frame, otherwise only if the scene has been invalidated with scene.invalidate method
		*/
		public var forceUpdate:Boolean=false;
		/**
		* If true, the screen will be cleared before every render, default is true
		*/
		public var autoClear:Boolean=true;
		/**
		* If camera is not null, the view uses its own camera for every scene it renders, otherwise the cam property of the scene
		*/
		public var camera:Camera3d = null;
		/**
		 * Read Only, the time in miliseconds of the last render
		 */
		public var lastRenderTime:int=0;
		/**
		* @private Read Only
		*/
		we3d var _width:Number = 550;
		/**
		* @private Read Only
		*/
		we3d var _height:Number = 400;
		/**
		* @private Read Only
		*/
		public var renderSession:RenderSession=new RenderSession();
		
		private var _gpuEnabled:Boolean=false;
		public function get gpuEnabled () :Boolean {
			return _gpuEnabled;
		}
		public function set gpuEnabled (v:Boolean) :void 
		{
			_gpuEnabled = v;
			firstLayer.enableGPU (v, renderSession);
		}
		
		/**
		* Get and set the scene
		*/ 
		public function set scene (s:Scene3d) :void {
			_scene = s;
			renderSession.camera = s.cam;
			camera = s.cam;
			renderSession.scene = s;
		}
		public function get scene () :Scene3d {
			return _scene;
		}
		private var _scene:Scene3d;
		
		/**
		 * Get and set the width of the view
		 */
		public function get width () :Number {
			return _width;
		}
		public function set width (w:Number) :void {
			_width = w;
			renderSession.width = w;
			if(camera != null) camera.width = w;
			else if(scene && scene.cam) scene.cam.width = w;
			resizeLayers();
			invalidate();
		}
		
		/**
		* Get and set the height of the view
		*/
		public function get height () :Number {
			return _height;
		}
		public function set height (h:Number) :void {
			_height = h;
			if(camera != null) camera.height = h;
			else if(scene && scene.cam) scene.cam.height = h;
			renderSession.height = h;
			resizeLayers();
			invalidate();
		}
		
		/**
		* @private
		*/ 
		public function resizeLayers () :void {
			var L:int = allLayers.length;
			for(var i:int=0; i<L; i++) {
				if(allLayers[i].autoResize) {
					allLayers[i].setSize( _width, _height );
				}
			}
		}
		
		/**
		* Set the size of the view, this is the same as setting the width and the height properties
		*/ 
		public function setSize (w:Number, h:Number) :void {
			_width = renderSession.width = w;
			_height = renderSession.height = h;
			if(camera) {
				camera.width = w;
				camera.height = h;
			}else if(scene && scene.cam){
				scene.cam.width = w;
				scene.cam.height = h;
			}
			resizeLayers();
			invalidate();
		}
		
		/**
		* @private
		* Target for depth-sorted layers
		*/
		public var stTarget:Sprite;
		/**
		* @private
		* Target for background layers
		*/
		public var bgTarget:Sprite;
		/**
		* @private
		* Target for foreground layers
		*/
		public var fgTarget:Sprite;
		/**
		* @private
		* Contains layers wich are sorted by depth
		*/
		public var sortedLayers:Array=[];
		/**
		* @private
		* Contains foreground layers
		*/
		public var fgLayers:Vector.<Layer>=new Vector.<Layer>();
		/**
		* @private
		* Contains background layers
		*/
		public var bgLayers:Vector.<Layer>=new Vector.<Layer>();
		/**
		* @private
		* contains all layers (sorted, bg and fg) in the order the layers have been added
		*/
		public var allLayers:Vector.<Layer>=new Vector.<Layer>();
		/**
		* @private
		*/
		public var currentLayer:Layer;
		/**
		* @private
		*/
		public var lyrTable:Object={};
		/**
		* @private
		*/
		public var tgtTable:Object={};
		/**
		* @private
		* Array with filters, default is null 
		*/
		public var filters:Vector.<BackgroundFilter> = new Vector.<BackgroundFilter>();
		/**
		* Determines if the view is invalid and need to be redrawn, you can also set renderState to true instead of calling invalidate()
		*/
		public var renderState:Boolean=false;
		/**
		* If true, clears internal render data after a render, default is true
		*/
		public var clearRenderData:Boolean=true;
		
		private var changeEvent:Event=new Event(Event.CHANGE);
		private var _autoRendering:Boolean=false;
		
		/**
		* Invalidates the view for redraw
		*/
		public function invalidate () :void {
			renderState = true;
		}
		
		/**
		* Returns true if the scene can be rendered
		*/
		public function get isModified () :Boolean {
			return scene != null && (forceUpdate || renderState || scene.renderState);
		}
		
		/**
		* Render the scene 
		*/
		public function render () :void {
			//if((forceUpdate && scene) || isModified) {
			//if( scene != null && (forceUpdate || renderState || scene.renderState)) 
			//{			
				var t:int = getTimer();
				if(camera != null) scene.cam = camera;
				
				if(autoClear) clear();
				
				renderSession.currentFrame = scene.currentFrame;
				renderSession.camera = scene.cam;
				
				
				if(renderSession.context3d != null && renderSession.context3d.driverInfo != "Disposed") {
					var i:int;
					if(renderSession.textures > 0) {
						// reset textures
						for (i=0; i<renderSession.textures;  i++) {
							renderSession.context3d.setTextureAt( i, null );
						}
						renderSession.textures = 0;
					}
					if(renderSession.gpuBuffers > 0) {
						// reset vertex buffers
						for ( i=0; i<renderSession.gpuBuffers; i++) {
							renderSession.context3d.setVertexBufferAt ( i, null );
						}
						renderSession.gpuBuffers = 0;
					}
					
				}
				
				
				firstLayer.updateSession( renderSession );
				renderSession.setDefaultSession( renderSession );
				
				initFrame(scene.currentFrame);
				
				renderer.draw(renderSession);
				renderState = false;
				
				endFrame(scene.currentFrame);
				lastRenderTime = getTimer()-t;
			//}
		}
		
		/**
		* Clears all layers from previous render 
		*/
		public function clear () :void {
			
			var L:int = allLayers.length;
			var i:int;
			var lyr:Layer;
			for(i=0; i<L; i++) {
				lyr = allLayers[i];
				if(lyr.autoClear) lyr.clear();
			}
			
			dispatchEvent(new Event(EVT_CLEAR));
		}
		/**
		* Add a filter 
		* @param	filter
		*/
		public function addFilter (filter:BackgroundFilter) :void {
			if(filters == null) {
				filters = new Vector.<BackgroundFilter>();
			}else{
				if(filters.indexOf(filter) >= 0) return;
			}
			filter.initialize(renderSession);
			filters.push(filter);
		}
		/**
		* Remove a filter
		* @param	filter
		*/
		public function removeFilter (filter:BackgroundFilter) :void {
			if(filters != null) {
				var id:int = filters.indexOf(filter);
				if(id >= 0) {
					filter.remove(renderSession);
					filters.splice(id, 1);
				}
			}
		}
		/**
		 * Add a layer 
		 * @param	lyr
		 * @return
		 */
		public function setLayerAt (id:int, lyr:Layer, type:String=SORTED) :void 
		{
			
			if( lyrTable[type].length > id && lyrTable[type][id] ) {
				var sid:int =  allLayers.indexOf(lyrTable[type][id]);
				if(sid >= 0) allLayers.splice(sid,1);
			}
			
			lyrTable[type][id] = lyr;
			
			allLayers.push(lyr);
			
			lyr.initialize (renderSession, tgtTable[type]);
			
			if( id == 0 ) {
				firstLayer = lyr;
			}
		}
		
		/**
		* Add a layer 
		* @param	lyr
		* @return
		*/
		public function addLayer (lyr:Layer, type:String=SORTED) :int {
			
			var id:int = layerId(lyr, type);
			if(id != -1) return id;
			
			id = lyrTable[type].push(lyr)-1;
			
			allLayers.push(lyr);
			
			lyr.initialize (renderSession, tgtTable[type]);
			return id;
		}
		
		/**
		* Remove a layer
		* @param	lyr
		* @return
		*/
		public function removeLayer (lyr:Layer, type:String=SORTED) :Boolean {
			var id:int = layerId(lyr, type);
			if(id >= 0) {
				lyr.remove(renderSession, tgtTable[type]);
				lyrTable[type].splice(id,1);
				id = allLayers.indexOf(lyr);
				if(id >= 0) allLayers.splice(id, 1);
				return true;
			}
			return false;
		}
		
		/**
		* Remove all layers except the firstLayer
		*/ 
		public function removeAllLayers () :void {
			var L:int;
			var i:int;
			var arr:Array;
			var vec:Vector.<Layer>;
			
			for(var type:String in lyrTable) 
			{
				if( lyrTable[type] is Array) {
					arr = lyrTable[type];
					L = arr.length;
					
					for(i = arr.length-1; i>=0; i--) 
					{
						if(arr[i] != this.firstLayer) {
							removeLayer( arr[i], type );
						}
					}
				}else{
					vec = lyrTable[type];
					
					for(i = vec.length-1; i>=0; i--) 
					{
						if(vec[i] != this.firstLayer) {
							removeLayer( vec[i], type );
						}
					}
				}
			}
			
		}
		
		/**
		* Returns the id of layer
		* @param	lyr
		* @return
		*/
		public function layerId (lyr:Layer, type:String=SORTED) :int {
			return lyrTable[type].indexOf(lyr);
		}
		
		/**
		* Returns a layer by id 
		* @param	id
		* @return
		*/
		public function layerAt (id:int, type:String=SORTED) :Layer {
			return lyrTable[type][id];
		}
		
		/**
		* @private 
		*/
		public function initFrame (cf:Number) :void {
			
			dispatchEvent(new Event(EVT_BEGIN_DRAW));
			
			scene.initFrame(cf);
						
			var L:int = allLayers.length;
			var i:int;
			var lyr:Layer;
			for(i=0; i<L; i++) {
				lyr = allLayers[i];
				lyr.initFrame(renderSession);
			}
			
			if(filters != null) {
				var ft:BackgroundFilter;
				L = filters.length;
				for(i=0; i<L; i++) {
					ft = filters[i];
					if(ft.enabled) ft.initFrame(renderSession);
				}
			}
		}
		
		/**
		* @private 
		*/
		public function endFrame (cf:Number) :void {
			
			scene.endFrame(cf);
			
			var lyr:Layer;
			var L:int = allLayers.length;
			var i:int;
			
			for(i=0; i<L; i++) {
				lyr = allLayers[i];
				lyr.endFrame(renderSession);
			}
			
			if(filters != null) {
				var ft:BackgroundFilter;
				L = filters.length;
				for(i=0; i<L; i++) {
					ft = filters[i];
					if(ft.enabled) ft.endFrame(renderSession);
				}
			}
			
			L = sortedLayers.length;
			if(L > 1) {
				var lyrs:Array = sortedLayers.sortOn("totalAvg", Array.NUMERIC | Array.RETURNINDEXEDARRAY);
				var k:int=0;
				for(i=0; i<L; i++) {
					lyr = sortedLayers[lyrs[i]];
					if(lyr.swapDepth && stTarget.contains(lyr.target)) stTarget.setChildIndex(lyr.target, k++);
				}
			}
			dispatchEvent(new Event(EVT_END_DRAW));
			
			if(clearRenderData) {
				L = allLayers.length;
				for(i=0; i<L; i++) {
					lyr = allLayers[i];
					lyr.clearRenderData(renderSession);
				}
			}
		}
		
		/**
		* Enable or disable auto rendering, if forceUpdate is false and autoRendering is true, the view redraws only if the scene or the view is invalid. 
		* If autoRendering is false you have to call the view.render method yourself and also invalidate the view or the scene. 
		*/ 
		public function set autoRendering (value:Boolean) :void {
			if(value && !_autoRendering) {
				viewport.addEventListener(Event.ADDED_TO_STAGE, stageAdded);
				viewport.addEventListener(Event.REMOVED_FROM_STAGE, stageRemoved);
				if(viewport.stage != null) stageAdded(null);
			}else if(!value && _autoRendering) {
				viewport.removeEventListener(Event.ADDED_TO_STAGE, stageAdded);
				viewport.removeEventListener(Event.REMOVED_FROM_STAGE, stageRemoved);
				viewport.removeEventListener(Event.ENTER_FRAME, frameHandler);
			}
			_autoRendering = value;
		}
		public function get autoRendering () :Boolean {
			return _autoRendering;
		}
		
		private function stageAdded (e:Event) :void {
			if(e==null || e.target == viewport) viewport.addEventListener(Event.ENTER_FRAME, frameHandler);
		}
		private function stageRemoved (e:Event) :void {
			if(e==null || e.target == viewport) viewport.removeEventListener(Event.ENTER_FRAME, frameHandler);
		}
		private function frameHandler (e:Event) :void {
			if( scene != null && (forceUpdate || renderState || scene.renderState)) {
				render();
			}
		}
	}
}