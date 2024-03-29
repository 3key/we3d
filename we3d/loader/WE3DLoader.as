package we3d.loader 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import fl.motion.easing.Sine;
	
	import we3d.we3d;
	import we3d.animation.EnvelopeChannel;
	import we3d.animation.IChannel;
	import we3d.animation.LinearChannel;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.core.transform.Hierarchy;
	import we3d.filter.ZBuffer;
	import we3d.layer.Layer;
	import we3d.loader.ImageLoadEvent;
	import we3d.loader.SceneLoader;
	import we3d.material.BitmapAttributes;
	import we3d.material.MaterialManager;
	import we3d.material.Surface;
	import we3d.math.Vector3d;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;
	import we3d.scene.LightGlobals;
	import we3d.scene.SceneLight;
	import we3d.scene.SceneObject;
	import we3d.scene.SceneObjectMorph;
	import we3d.scene.SceneParticles;
	import we3d.scene.SceneSprite;
	import we3d.scene.SceneSpriteF10;
	import we3d.scene.dynamics.ParticleDotRenderer;
	import we3d.scene.dynamics.ParticleSpriteRenderer;
	import we3d.ui.Console;
	import we3d.view.View3d;
	
	use namespace we3d;
	
	/**
	* Load WE3D XML Files. <br/>
	* <code>
	
	<we3d>

	<version>1</version>
	
	<res>
		<clip id="Clip_1" file="files/pg.png"/>
		<clip id="Clip_2" file="files/test.swf"/>
	</res>
	
	<materials>
		<surface id="Mat_1" texture="Clip_1" lighting="true" scanline="true" zbuffer="true" />
		<surface id="Mat_2" color="#323459" lineColor="#ff9900" alpha="0.5" lineAlpha="0.75" scanline="true" zbuffer="true" />
	</materials>
	
	<channels>
		<c id="Chan_1" type="linear" loop="true">
			<key frame="1" value="0" ease="in"/>
			<key frame="2500" value="360" />
		</c>
		<c id="Chan_2" type="ease" unit="percent" loop="true">
			<key frame="1" value="50" ease="Regular.easeIn"/>
			<key frame="200" value="100" ease="Regular.easeOut"/>
			<key frame="400" value="50" ease="Regular.easeInOut"/>
		</c>
	</channels>
	
	<view width="800" height="400">
		<layer id="Layer_1" type="background"/>
		<layer id="Layer_2" type="sorted"/>
		<layer id="Layer_3" type="sorted"/>
		<layer id="Layer_4" type="foreground"/>
	</view>
	
	<scene>
		
		<cam id="Camera_1" z="-250" fov="55" width="800" height="400"/>
		<light id="Light_1" type="point" color="#ff9944" y="500" z="-900" intensity="1.5"/>
		
		<light id="Light_2" type="directional" color="#88ccff" rx="-45" ry="45">
			<c>
				<c id="Chan_1" target="transform.rotationY"/>
			</c>
		</light>
		
		<obj id="Mesh_2" x="0" y="0" z="0" rx="0" ry="0" rz="0" sx="1" sy="1" sz="1">
			<c>
				<c id="Chan_1" target="transform.rotationX"/>
			</c>
		</obj>
		
		<obj id="Mesh_1" x="100" parent="Mesh_2">
			<v>
				<v>0 0 0</v>
				<v>10 0 0</v>
				<v>100 0 0</v>
				<v>0 10 0</v>
				<v>0 0 10</v>
			</v>
			<t>
				<t>0 0</t>
				<t>0 .5</t>
				<t>.5 0</t>
				<t>.5 .5</t>
				<t>1 .5</t>
				<t>.5 1</t>
				<t>1 1</t>
			</t>
			<f>
				<m>Mat_1</m> 
				<f>0 1 2</f>
				<u>0 1 2</u>
				<f>2 1 3</f>
				<u>2 1 3</u>
				<m>Mat_2</m>
				<f>3 4 5</f>
				<u>3 4 5</u>
			</f>
		</obj>
		
		<morph  x="200" rx="90" parent="Mesh_2">
		 	
			<v id="framename-001">
				<v>0 0 0</v>
				<v>10 0 0</v>
				<v>100 0 0</v>
				<v>0 10 0</v>
				<v>0 0 10</v>
			</v>
			<v id="framename-003">
				<v>300 0 0</v>
				<v>30 300 0</v>
				<v>300 300 0</v>
				<v>0 30 0</v>
				<v>0 0 30</v>
			</v>
			
			<t>
				<t>0 0</t>
				<t>0 .5</t>
				<t>.5 0</t>
				<t>.5 .5</t>
				<t>1 .5</t>
				<t>.5 1</t>
				<t>1 1</t>
			</t>
			<f>
				<m>Mat_1</m> 
				<f>0 1 2</f>
				<u>0 1 2</u>
				<f>2 1 3</f>
				<u>2 1 3</u>
				<m>Mat_2</m>
				<f>3 4 5</f>
				<u>3 4 5</u>
			</f>
			<playlist>
				<frame id="framename-001" duration="0"/>
				<frame id="framename-002" duration="0.9" ease="SinEaseIn"/>
			</playlist>
		</morph>
		
		
		<obj id="Mesh_3" x="100" y="0" z="0" rx="0" ry="0" rz="0" sx="1" sy="1" sz="1"/>
		<sprite id="Sprite_1" type="2d" clip="Clip_1" x="100"/>
		<sprite id="Sprite_2" type="3d" clip="Clip_2" x="-100" ry="-90"/>
		
		<particles type="dot" id="Particles_1" x="0" y="0" z="0" rx="0" ry="0" rz="0" sx="1" sy="1" sz="1">
			<emitter type="basic" generatePerTick="250" />
		</particles>
		
		
		
		<bones>
		</bones> 
		  
		
		
	</scene>
	
</we3d>
 * 
 * </code>
	*/
	public class WE3DLoader extends SceneLoader 
	{
		public function WE3DLoader () {
			subdirResources = false;
		}
		
		public var scanline:Boolean = false;
		public var zbuffer:ZBuffer = null;
		
		private var matmgr:MaterialManager = new MaterialManager();
		public function get materialManager () :MaterialManager {	return matmgr;		}
		
		private var file:XML;
		private var piid:int=-1;
		private var clipIndex:Object;
		private var channelIndex:Object;
		private var channels:Array;
		
		private var layerIndex:Object;
		private var layers:Array;
		
		private var chunkId:int;
		private var chunks:Array=["materials", "channels", "view", "scene"];
		private var sceneChunkId:int;
		private var objectChunkId:int;
		private var sceneChunks:Array=["cam", "light", "obj", "morph", "sprite", "particles"];
		
		public var view:View3d;
		
		private var objDone:int=-1;
		private var objlist:XMLList;
		
		private var parents:Array;
		
		private var ldr:FileLoader;
		
		private var lastMat:String="";
		
		public override function parseFile (b:ByteArray) :void 
		{
			clipIndex = {};
			images = [];
			channelIndex = {};
			channels = [];
			layerIndex = {};
			layers = [];
			spritesByName = {};
			fileSprites = [];
			parents = [];
			status = 0;
			lightGlobals = new LightGlobals();
			
			super.init();
			
			file = new XML(b);
			
			if(!this.loadResources) 
			{
				startParse();
			}
			else
			{
				if( file.res && file.res.clip.length() > 0) {
					var clips:XMLList = file.res.clip;
					var L:int = clips.length();
					
					addEventListener(EVT_IMAGES_LOADED, allImagesLoaded);
					//addEventListener(EVT_IMAGE_LOADED, imageLoaded);
					
					for(var i:int=0; i<L; i++) 
					{
						images.push( clips[i].@file );
						
						clipIndex[ clips[i].@id ] = images.length-1;
						loadBitmap( images.length-1 );
					}
				}else{
					startParse();
				}
			}
		}
		
		private function allImagesLoaded (e:Event) :void 
		{
			removeEventListener(EVT_IMAGES_LOADED, allImagesLoaded);
			startParse();
		}
		
		private function startParse () :void 
		{
			chunkId = sceneChunkId = objectChunkId = 0;
			objDone = -1;
			
			if(blocking) {
				while(parseChunk()){};
				finishParse();
			}else{
				if(piid != -1) clearInterval(piid);
				piid = setInterval(parseStep, loadParseInterval);
			}
		}
		
		private function parseChunk () :Boolean 
		{
			if( this[ "__" + chunks[chunkId] ]() ) return true;
			if(chunkId < chunks.length-1) chunkId++;
			
			status = chunkId * 25;
			return false;
		}
		
		public function getBitmap ( s:String ) :BitmapData 
		{
			return bitmaps[ clipIndex[s] ].bmp;
		}
		
		public function cssColor ( s:String ) :int 
		{
			if(s.charAt(0).toLowerCase() == "r") 
			{
				var o:int = s.indexOf("(",0);
				var c:int = s.indexOf(")",0);
				
				if(o == -1 || c == -1 ||  o >= c) return 0;
				
				var a:Array = s.substring(o+1, c).split(",");
				
				return int(a[0]) << 16 | int(a[1]) << 8 | int(a[2]);
			}
			else
			{
				if(s.charAt(1).toLowerCase() == "x") {
					return parseInt(s);
				}else if( isNaN(Number(s.charAt(0))) ) {
					return parseInt("0x"+s.substring(1, s.length));
				}else{
					return int(s);
				}
			}
		}
		
		public function trim (e:String) :String {
			var str:String = "";
			var i:int;
			var igstart:int=0;
			
			for(i=0; i<e.length; i++) {
				if(e.charCodeAt(i) > 32) {
					igstart = i;	
					break;	
				}
			}
			if(igstart > 0) e = e.substring(igstart, e.length);
			
			str = e.charCodeAt(e.length-1) <= 32 ? "" : e.charAt(e.length-1);
			for(i=e.length-2; i>=0; i--) {
				if(e.charCodeAt(i) > 32 || e.charCodeAt(i+1) > 32) {
					str = e.charAt(i) + str;
				}
			}
			
			return str;
		}
		
		public function strToBool (v:String) :Boolean {
			if(v=="1" || v.toLowerCase() == "true") return true;
			return false;
		}
		
		public function isColor (str:String) :Boolean {
			return str.indexOf("#") != -1 || str.indexOf("rgb") != -1;
		}
		
		public function parse (v:*) :* {
			if(v is String) 
			{
				if(isNaN(Number(v))) 
				{
					v = trim(v);
					
					if( v=="true") return true
					else if( v=="false") return false;
					
					//if(defaultColors[v] != null) return defaultColors[v];
					
					if(v.charAt(0) =="#" || v.substring(0,3).toLowerCase() == "rgb") {
						return cssColor(v);
					}
					
					var nm:String="";
					var unit:String="";
					var c:String;
					
					// Parse px, em and % Numbers
					for(var i:int=0; i<v.length; i++) {
						if(v.charCodeAt(i)>32) {
							c = v.charAt(i);
							if(isNaN(Number(c))) unit += c;
							else nm += c;
						}
					}
					
					switch( unit ) {
						case "px":
						case "m":
							v = Number( nm );
							break;
						case "em":
							v = Number( nm ) * .0625;
							break;
						case "cm":
							v = Number( nm ) * .01;
							break;
						case "mm":
							v = Number( nm ) * .001;
							break;
						case "km":
							v = Number( nm ) * 1000;
							break;
						/*case "%":
							if(container != null) {
								var o:Object = Object(container);
								var w:Number = o.cssWidth ? o.cssWidth : o.width;
								var h:Number = o.cssHeight ? o.cssHeight : o.height;
								return (hv == "h" ? w : h) * (Number(nm)/100);
							} 
							break;*/
						/*default: 
							v = Number( nm );
							break;*/
					}
				}
			}
			
			return v;
		}
	
		private function __materials () :Boolean 
		{
			var list:XMLList = file.materials.surface;
			var L:int = list.length();
			var atb:Object;
			var sfo:Object;
			var sf:Surface;
			var nm:String;
			
			for(var i:int=0; i<L; i++) 
			{
				sfo = {};
				sf = new Surface();
				fileSurfaces.push(sf);
				
				atb = list[i].attributes();
				
				for(var name:String in atb) 
				{
					nm = atb[name].name().toString();
					
					switch (nm) 
					{
						case "id":
						case "name":
							sfo[nm] = atb[name].toString();
							break;
						
						case "alpha":
						case "lineAlpha":
						case "luminosity":
						case "diffuse":
						case "lineStyle":
							sfo[nm] = Number(atb[name].toString());
							break;
						
						case "hideBackfaces":
						case "lighting":
						case "scanline":
						case "zbuffer":
						case "wireframe":
						case "curved":
						case "transparent":
							sfo[nm] = strToBool(atb[name].toString());
							break;
						
						case "color":
						case "lineColor":
							sfo[nm] = cssColor(atb[name].toString());
							break;
						
						case "bitmap":
							sfo[nm] = getBitmap(atb[name].toString());
							break;
						
						case "lightGlobals":
							sfo.lightGlobals = lightGlobals;
							break;
						
						default:
							sf.shared[nm] = parse( atb[name].toString() );
							break;
					}
					
					//sfo[atb[name].name().toString()] = atb[name].toString();
				}
				
				if( sfo.lightGlobals is String ) 
				{
					sfo.lightGlobals = this.lightGlobals;
				}
				surfacesByName[sfo.id] = fileSurfaces[fileSurfaces.length-1];
				matmgr.setupMaterial(sf, sfo);
			}
			
			return false;	
		}
		
		public static var easeFuncs:Object = { 	SineEaseIn: fl.motion.easing.Sine.easeIn,
												SineEaseOut: fl.motion.easing.Sine.easeOut,
												SineEaseInOut: fl.motion.easing.Sine.easeInOut
		}
		
		public static function easeFunc (id:String) :* {
			return easeFuncs[id];
		}
		public static function easeFuncName (id:Function) :String {
			
			for( var name:String in easeFuncs ) {
				if( easeFuncs[name] === id ) { 
					return name;
				}
			}
			return "";
		}
		 /**
		 *  <c id="Chan_2" type="ease" unit="percent" loop="true">
		 *	  <key frame="1" value="50" ease="SineEaseIn"/>
		 *    <key frame="99" value="0" ease="SineEaseInOut"/>
		 *  </c>
		 **/
		private function __channels () :Boolean 
		{
			var chans:XMLList = file.channles.c;
			var L:int = chans.length();
			
			var c:IChannel;
			var j:int;
			var L2:int;
			var keys:XMLList;
			var val:Number;
			var tp:String;
			
			for(var i:int=0; i<L; i++) 
			{
				tp = chans[i].@unit || "";
				if( chans[i].@type == undefined || chans[i].@type == "linear" ) {
					c = new LinearChannel();
				}else{
					c = new EnvelopeChannel();
				}
				
				keys = chans[i].key;
				for(j=0; j<L2; j++) 
				{
					val = keys[i].@value;
					
					if(tp=="degree") val *= Math.PI/180;
					else if(tp=="percent") val /= 100;
					
					c.storeFrame( keys[i].@frame, val, easeFunc(keys[i].@ease) );
				}
				
				channels.push(c);
				channelIndex[ chans[i].@id ] = c;
			}
			
			return false;
		}
		
		/**
		* <view width="800" height="400" allowBitmap="1">
		*	<layer id="Layer_1" type="background"/>
		*	<layer id="Layer_2" type="sorted"/>
		*	<layer id="Layer_3" type="sorted"/>
		*	<layer id="Layer_4" type="foreground"/>
		* </view>
		*/ 
		private function __view () :Boolean 
		{
			if(file.view != undefined)
			{
				view = new View3d( file.view.@width, file.view.@height );
				var lyrs:XMLList = file.view.layer;
				
				if(lyrs != null) 
				{
					var lyr:Layer;
					var L:int = lyrs.length();
					
					for(var i:int=0; i<L; i++) 
					{
						lyr = new Layer(lyrs[i].@allowBitmap=="1"?true:false);
						
						layerIndex[ lyrs[i].@id ] = lyr;
						layers.push(lyr);
						
						view.addLayer( lyr );
					}
				}
			}
			
			return false;
		}
		
		// event timer function
		private function __scene () :Boolean 
		{
			if( this[ "__"+sceneChunks[sceneChunkId] ]() ) // true if all items are processed
			{
				objDone = -1;
				sceneChunkId++;
				if(sceneChunkId >= sceneChunks.length) return true;
			}
			return false;
		}
		
		private function __cam () :Boolean 
		{
			if(objDone==-1) 
			{
				objectChunkId = 0;
				if(file.scene.cam==undefined) return true;
				objlist = file.scene.cam;
				objDone = 0;
			}
			
			var cam:Camera3d = new Camera3d( objlist[ objectChunkId ].@width, objlist[ objectChunkId ].@height );
			
			if( objlist[ objectChunkId ].@fov != undefined) cam.fov = Number(objlist[ objectChunkId ].@fov );
			if( objlist[ objectChunkId ].@near != undefined) cam.nearClipping = Number(objlist[ objectChunkId ].@near );
			if( objlist[ objectChunkId ].@far != undefined) cam.farClipping = Number(objlist[ objectChunkId ].@far );
			if( objlist[ objectChunkId ].@fovh != undefined) cam.fovH = Number(objlist[ objectChunkId ].@fovh );
			
			parseTransform( cam, objlist[objectChunkId] );
			parseItemChannels( cam, objlist[objectChunkId] );
			
			camerasByName[ objlist[ objectChunkId ].@id ] = cam;
			fileCameras.push( cam );
			
			objectChunkId++;
			if(objectChunkId < objlist.length()) 
			{
				return false;
			}
			
			return true;
		}
		
		private function parseTransform (obj:Object3d, node:XML) :void 
		{		
			if(node) {
				if(node.@parent != null) {
					obj.transform = new Hierarchy();
					parents.push( [obj, node.@parent] );
				}
				
				if(node.@x != undefined) obj.transform.x = Number( node.@x );
				if(node.@y != undefined) obj.transform.y = Number( node.@y );
				if(node.@z != undefined) obj.transform.z = Number( node.@z );
				
				if(node.@rx != undefined) obj.transform.rotationX = Number( node.@rx );
				if(node.@ry != undefined) obj.transform.rotationY = Number( node.@ry );
				if(node.@rz != undefined) obj.transform.rotationZ = Number( node.@rz );
				
				if(node.@sx != undefined) obj.transform.scaleX = Number( node.@sx );
				if(node.@sy != undefined) obj.transform.scaleY = Number( node.@sy );
				if(node.@sz != undefined) obj.transform.scaleZ = Number( node.@sz );
			}
			
		}
		
		private function parseItemChannels (obj:Object3d, node:XML) :void 
		{
			
		}
		
		/*
		<v>
			<v x="0" y="0" z="0"/>
		</v>
		<t>
			<t u="0" v="0"</t>
		</t>
		<f>
			<f mat="Surface_1" vts="0,1,2" uvs="0,1,2"/>
			<f vts="1,2,3" uvs="1,2,3"/>
		</f>
		*/
		private function parseItemMesh (obj:SceneObject, node:XML) :void 
		{
			var list:XMLList;
			var L:int;
			var i:int;
			var uvs:Vector.<UVCoord> = new Vector.<UVCoord>();
			
			if(node.v.v) 
			{
				list = node.v.v;
				L = list.length();
				var pt:Vertex;
				
				for(i=0; i<L; i++) 
				{
					//obj.addPoint( Number(list[i].@x), Number(list[i].@y), Number(list[i].@z) );
					
					pt = new Vertex(Number(list[i].@x), Number(list[i].@y), Number(list[i].@z));
					obj.addVertex(pt);
					
					if( list[i].@nx != null) {
						pt.normal = new Vector3d( Number(list[i].@nx), Number(list[i].@ny), Number(list[i].@nz));
					}
					if(list[i].@color != null) {
						pt.color = this.cssColor( list[i].@color);
					}
					if(list[i].@alpha != null ) {
						pt.alpha = Number(list[i].@alpha);
					}
					
					
				}
			}
			
			if(node.t.t) 
			{				
				list = node.t.t;
				L = list.length();
				
				for(i=0; i<L; i++) 
				{
					uvs.push(  new UVCoord(Number(list[i].@u), Number(list[i].@v))  );
				}
			}
			
			if(node.f.f) 
			{
				var tuv:Array;
				var tvs:Array;
				
				list = node.f.f;
				L = list.length();
				
				var j:int;
				var jL:int;
				var puvs:Vector.<UVCoord>;
				var pvts:Vector.<int>;
				var uvid:int;
				var uvError:Boolean;
				
				for(i=0; i<L; i++) 
				{
					if( list[i].@vts == undefined) continue; 
					
					pvts = new Vector.<int>();
					tvs = list[i].@vts.toString().split(",");
					
					jL = tvs.length;
					
					if(list[i].@mat != undefined) lastMat = list[i].@mat.toString();
					
					if( list[i].@uvs != undefined) 
					{
						tuv = list[i].@uvs.toString().split(",");
						
						if( tuv.length == tvs.length) 
						{
							puvs = new Vector.<UVCoord>();
							uvError = false;
							
							for(j=0; j<jL; j++) 
							{
								uvid = int(tuv[j]);
								
								if(uvs.length > uvid) {
									puvs.push( uvs[uvid] );
								}else{
									uvError = true;
								}
								pvts.push( int(tvs[j]) );
							}
							if(uvError) 
							{
								obj.addPolygonVector( surfacesByName[lastMat], pvts );
							}else{
								
								obj.addPolygonVector( surfacesByName[lastMat], pvts, puvs );
							}
						}
					}
					else
					{
						for(j=0; j<jL; j++) 
						{
							pvts.push( int(tvs[j]) );
						}
						obj.addPolygonVector( surfacesByName[lastMat], pvts ); 
					}
				}
			}
			
		}
		/*
		<morph>
			<v id="frame1">
				<v x="0" y="0" z="0"/>
			</v>
			<v id="frame2">
				<v x="0" y="0" z="0"/>
			</v>
			
			<t>
			<t u="0" v="0"</t>
			</t>
			<f>
			<f mat="Surface_1" vts="0,1,2" uvs="0,1,2"/>
			<f vts="1,2,3" uvs="1,2,3"/>
			</f>
			<playlist>
			<frame id="framename-001" duration="0"/>
			<frame id="framename-002" duration="0.9"/>
			</playlist>
		</morph>
		*/
		private function parseMorphMesh (obj:SceneObjectMorph, node:XML) :void 
		{
			var list:XMLList;
			var L:int;
			var i:int;
			var uvs:Vector.<UVCoord> = new Vector.<UVCoord>();
			
			
			if(node.v) 
			{
				var frames:XMLList = node.v;
				var fL:int = frames.length();
				var fpts:Vector.<Vertex>;
				var pt:Vertex;
				
				if( fL > 0 ) 
				{
					for(var fi:int=0; fi < fL; fi++) {
						list = frames[fi].v;
						L = list.length();
						fpts = new Vector.<Vertex>();
						
						for(i=0; i<L; i++) 
						{
							pt = new Vertex(Number(list[i].@x), Number(list[i].@y), Number(list[i].@z));
							if(fi == 0) {
								obj.points.push(new Vertex(pt.x,pt.y,pt.z));
							}
							fpts.push(  pt );
							if( list[i].@nx != null) {
								pt.normal = new Vector3d( Number(list[i].@nx), Number(list[i].@ny), Number(list[i].@nz));
							}
							if(list[i].@color != null) {
								pt.color = this.cssColor( list[i].@color);
							}
							if(list[i].@alpha != null ) {
								pt.alpha = Number(list[i].@alpha);
							}
							
						}
						
						trace("Frame Name: " + frames[fi].@id);
						
						obj.addMorph( frames[fi].@id, fpts );
					}
				}
			}
			if(node.playlist) {
				list = node.playlist.frame;
				L = list.length();
				
				for(i=0; i<L; i++) {
					obj.addToPlayList( list[i].@id, Number(list[i].@duration) );
				}
			}
				
			if(node.t.t) 
			{				
				list = node.t.t;
				L = list.length();
				
				for(i=0; i<L; i++) 
				{
					uvs.push(  new UVCoord(Number(list[i].@u), Number(list[i].@v))  );
				}
			}
			
			if(node.f.f) 
			{
				var tuv:Array;
				var tvs:Array;
				
				list = node.f.f;
				L = list.length();
				
				var j:int;
				var jL:int;
				var puvs:Vector.<UVCoord>;
				var pvts:Vector.<int>;
				var uvid:int;
				var uvError:Boolean;
				
				for(i=0; i<L; i++) 
				{
					if( list[i].@vts == undefined) continue; 
					
					pvts = new Vector.<int>();
					tvs = list[i].@vts.toString().split(",");
					
					jL = tvs.length;
					
					if(list[i].@mat != undefined) lastMat = list[i].@mat.toString();
					
					if( list[i].@uvs != undefined) 
					{
						tuv = list[i].@uvs.toString().split(",");
						
						if( tuv.length == tvs.length) 
						{
							puvs = new Vector.<UVCoord>();
							uvError = false;
							
							for(j=0; j<jL; j++) 
							{
								uvid = int(tuv[j]);
								
								if(uvs.length > uvid) {
									puvs.push( uvs[uvid] );
								}else{
									uvError = true;
								}
								pvts.push( int(tvs[j]) );
							}
							if(uvError) 
							{
								obj.addPolygonVector( surfacesByName[lastMat], pvts );
							}else{
								
								obj.addPolygonVector( surfacesByName[lastMat], pvts, puvs );
							}
						}
					}
					else
					{
						for(j=0; j<jL; j++) 
						{
							pvts.push( int(tvs[j]) );
						}
						obj.addPolygonVector( surfacesByName[lastMat], pvts ); 
					}
				}
			}
			
		}
		/**
		 * <light id="Light_2" type="directional" color="#88ccff" rx="-45" ry="45">
			<c>
				<c id="Chan_1" target="transform.rotationY"/>
			</c>
		</light>
		 */ 
		private function __light () :Boolean 
		{
			if(objDone==-1) {
				objectChunkId = 0;
				if(file.scene.light==undefined) return true;
				objlist = file.scene.light;
				objDone = 0;
			}
			
			var light:SceneLight = new SceneLight( objlist[ objectChunkId ].@type=="point"?true:false );
			
			if( objlist[ objectChunkId ].@intensity != undefined) light.intensity = Number(objlist[ objectChunkId ].@intensity );
			if( objlist[ objectChunkId ].@color != undefined) light.color = cssColor(objlist[ objectChunkId ].@color );
			if( objlist[ objectChunkId ].@r != undefined) light.r = Number(objlist[ objectChunkId ].@r );
			if( objlist[ objectChunkId ].@g != undefined) light.g = Number(objlist[ objectChunkId ].@g );
			if( objlist[ objectChunkId ].@b != undefined) light.b = Number(objlist[ objectChunkId ].@b );
			if( objlist[ objectChunkId ].@radius != undefined) light.radius = Number(objlist[ objectChunkId ].@radius );
			
			parseTransform( light, objlist[objectChunkId] );
			parseItemChannels( light, objlist[objectChunkId] );
			
			lightsByName[ objlist[ objectChunkId ].@id ] = light;
			fileLights.push( light );
			
			lightGlobals.lightList.push( light );
			
			objectChunkId++;
			if(objectChunkId < objlist.length()) 
			{
				return false;
			}
			
			return true;
		}
		
		private function __morph () :Boolean 
		{
			if(objDone==-1) {
				objectChunkId = 0;
				if(file.scene.obj==undefined) return true;
				objlist = file.scene.morph;
				objDone = 0;
			}
			
			var obj:SceneObjectMorph = new SceneObjectMorph();
			
			parseTransform( obj, objlist[objectChunkId] );
			parseItemChannels( obj, objlist[objectChunkId] );
			parseMorphMesh( obj, objlist[objectChunkId] );
			
			objectsByName[ objlist[ objectChunkId ].@id ] = obj;
			fileObjects.push( obj );
			
			objectChunkId++;
			if(objectChunkId < objlist.length()) 
			{
				return false;
			}
			
			return true;
		}
		
		private function __obj () :Boolean 
		{
			if(objDone==-1) {
				objectChunkId = 0;
				if(file.scene.obj==undefined) return true;
				objlist = file.scene.obj;
				objDone = 0;
			}
			
			var obj:SceneObject = new SceneObject();
			
			parseTransform( obj, objlist[objectChunkId] );
			parseItemChannels( obj, objlist[objectChunkId] );
			parseItemMesh( obj, objlist[objectChunkId] );
			
			objectsByName[ objlist[ objectChunkId ].@id ] = obj;
			fileObjects.push( obj );
			
			objectChunkId++;
			if(objectChunkId < objlist.length()) 
			{
				return false;
			}
			
			return true;
		}
				
		private function __sprite () :Boolean 
		{
			if(objDone == -1) {
				objectChunkId = 0;
				if(file.scene.sprite==undefined) return true;
				objlist = file.scene.sprite;
				objDone = 0;
			}
			var o:Object = bitmaps[clipIndex[objlist[objectChunkId].@clip]];
			
			if( objlist[ objectChunkId ].@type=="screen") 
			{
				var sp:SceneSprite = new SceneSprite();
				
				if( objlist[ objectChunkId ].@clip != undefined) sp.clip = o.sprite == null ? new Bitmap(o.bmp) : o.sprite;
				if( objlist[ objectChunkId ].@clipheight != undefined) sp.clipHeight = objlist[objectChunkId].@clipheight;
				
				parseTransform( sp, objlist[objectChunkId] );
				parseItemChannels( sp, objlist[objectChunkId] );
				
				spritesByName[ objlist[objectChunkId].@id ] = sp;
				fileSprites.push( sp );
			}
			else
			{
				var sp10:SceneSpriteF10 = new SceneSpriteF10();
				
				if( objlist[ objectChunkId ].@clip != undefined) sp10.clip = o.sprite == null ? new Bitmap(o.bmp) : o.sprite;
			
				parseTransform( sp10, objlist[objectChunkId] );
				parseItemChannels( sp10, objlist[objectChunkId] );
				
				spritesByName[ objlist[ objectChunkId ].@id ] = sp10;
				fileSprites.push( sp10 );
			}
			
			objectChunkId++;
			if(objectChunkId < objlist.length()) 
			{
				return false;
			}
			
			return true;
		}
		
		/*
		<particles type="dot" id="Particles_1" x="0" y="0" z="0" rx="0" ry="0" rz="0" sx="1" sy="1" sz="1">
		<emitter type="basic" generatePerTick="250" />
		<clips>
			<c id="Clip_1"/>
			<c id="Clip_2"/>
		</clips>
		</particles>
		
		
		<particles type="sprite" id="Particles_1" x="0" y="0" z="0" rx="0" ry="0" rz="0" sx="1" sy="1" sz="1">
		<emitter type="basic" generatePerTick="250" />
		</particles>
		
		
		*/
		private function __particles () :Boolean 
		{
			if(objDone == -1) 
			{
				objectChunkId = 0;
				if(file.scene.particles == undefined) return true;
				objlist = file.scene.particles;
				objDone = 0;
			}
			
			var pts:SceneParticles;
			
			if(objlist[objectChunkId].@type!=undefined) 
			{
				if( objlist[objectChunkId].@type == "dot") 
				{
					pts = new SceneParticles( new ParticleDotRenderer() );
				}
				else
				{
					var clips:Array = [];
					var list:XMLList = objlist[objectChunkId].clips.c;
					var L:int = list.length();
					var o:Object;
					
					for(var i:int=0; i<L; i++) {
						o = bitmaps[ clipIndex[list[i].@id] ];
						clips.push( o.sprite == null ? new Bitmap(o.bmp) : o.sprite );
					}
					pts = new SceneParticles( new ParticleSpriteRenderer(clips) ); 
				} 
			}
			else
			{
				pts = new SceneParticles();
			}
			
			if( objlist[ objectChunkId].emitter != undefined ) {
				var emt:XMLList = objlist[ objectChunkId].emitter;
				if(emt.@generate != undefined) pts.emitter.generatePerTick = emt.@generate;
				if(emt.@alpha != undefined) pts.emitter.alpha = emt.@alpha;
				if(emt.@centerx != undefined) pts.emitter.center.x = emt.@centerx;
				if(emt.@centery != undefined) pts.emitter.center.y = emt.@centery;
				if(emt.@centerz != undefined) pts.emitter.center.z = emt.@centerz;
				if(emt.@color != undefined) pts.emitter.color = emt.@color;
				if(emt.@constrainrandomcolor != undefined) pts.emitter.constrainRandomColor = emt.@constrainrandomcolor == "1"?true:false;
				if(emt.@explosion != undefined) pts.emitter.explosion = emt.@explosion;
				if(emt.@gravityx != undefined) pts.emitter.gravity.x = emt.@gravityx;
				if(emt.@gravityy != undefined) pts.emitter.gravity.y = emt.@gravityy;
				if(emt.@gravityz != undefined) pts.emitter.gravity.z = emt.@gravityz;
				if(emt.@lifetime != undefined) pts.emitter.lifeTime = emt.@lifetime;
				if(emt.@nozzle != undefined) pts.emitter.nozzle = emt.@nozzle;
				if(emt.@particlesize != undefined) pts.emitter.particleSize = emt.@particlesize;
				if(emt.@randomalpha != undefined) pts.emitter.randomAlpha = emt.@randomalpha;
				if(emt.@randomblue != undefined) pts.emitter.randomBlue = emt.@randomblue;
				if(emt.@randomcolor != undefined) pts.emitter.randomColor = emt.@randomcolor;
				if(emt.@randomexplosion != undefined) pts.emitter.randomExplosion = emt.@randomexplosion;
				if(emt.@randomgreen != undefined) pts.emitter.randomGreen = emt.@randomgreen;
				if(emt.@randomlifetime != undefined) pts.emitter.randomLifeTime = emt.@randomlifetime;
				if(emt.@randomparticlesize != undefined) pts.emitter.randomParticleSize = emt.@randomparticlesize;
				if(emt.@randomred != undefined) pts.emitter.randomRed = emt.@randomred;
				if(emt.@randomresistance != undefined) pts.emitter.randomResistance = emt.@randomresistance;
				if(emt.@randomweight != undefined) pts.emitter.randomWeight = emt.@randomweight;
				if(emt.@resistance != undefined) pts.emitter.resistance = emt.@resistance;
				if(emt.@sizex != undefined) pts.emitter.size.x = emt.@sizex;
				if(emt.@sizey != undefined) pts.emitter.size.y = emt.@sizey;
				if(emt.@sizez != undefined) pts.emitter.size.z = emt.@sizez;
				if(emt.@velocityx != undefined) pts.emitter.velocity_x = emt.@velocityx;
				if(emt.@velocityy != undefined) pts.emitter.velocity_y = emt.@velocityy;
				if(emt.@velocityz != undefined) pts.emitter.velocity_z = emt.@velocityz;
				if(emt.@weight != undefined) pts.emitter.weight = emt.@weight;
				if(emt.@playing != undefined && emt.@playing=="1") pts.emitter.start();
			}
			
			parseTransform( pts, objlist[objectChunkId] );
			parseItemChannels( pts, objlist[objectChunkId] );
				
			objectsByName[ objlist[objectChunkId].@id ] = pts;
			fileObjects.push( pts );
			
			objectChunkId++;
			if(objectChunkId < objlist.length()) {
				return false;
			}
			
			return true;
		}
		
		private function parseStep () :void 
		{
			for(var i:int=0; i<chunksPerFrame; i++) {
				if(parseChunk()) {
					finishParse();
					break;
				}
			}
		}
		
		private function finishParse() :void 
		{
			if(!blocking) {
				clearInterval(piid);
				piid = -1;
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
			
			file = null;
			clipIndex = null;
			channelIndex=null;
			channels = null;
			layerIndex = null;
			layers = null;
			spritesByName = null;
			fileSprites = null;
			parents =  null;
			
			clearMemory();
		}
	}
	
}