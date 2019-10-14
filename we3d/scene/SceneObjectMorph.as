
package we3d.scene 
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.layer.Layer;
	import we3d.material.Surface;
	import we3d.math.Matrix3d;
	import we3d.math.Vector3d;
	import we3d.mesh.Face;
	import we3d.mesh.MeshBuffer;
	import we3d.mesh.MeshProgram;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;
	import we3d.scene.MorphFrame;

	use namespace we3d;
	
	/**
	* Morph object with vertex map frames. For best render results, a morph should contain only triangles and two point polys.
	* The MD2 file loader generates SceneObjectMorph objects and assign the frames. 
	*/
	public class SceneObjectMorph extends SceneObject
	{
		public function SceneObjectMorph () {}
			
		private var timer:Timer;
		private var _frameTime:int = int(1000/24);
		private var _currentFrame:int=0;
		
		private var frameDone:Event=new Event("frameDone");
		private var toFrame:MorphFrame=null;
		private var fromFrame:MorphFrame = new MorphFrame("fromFrame");
		private var _frameIndex:Dictionary=new Dictionary(true);
		
		/**
		* Contains all morph frames 
		*/ 
		protected var frames:Vector.<MorphFrame> = new Vector.<MorphFrame>();
		
		private var _playList:Vector.<int>;
		private var _playListKeyFrames:Vector.<MorphKeyFrame>;
		private var currDuration:Number=0;
		private var endDuration:Number=0;
		private var displayFrame:int=0;
		
		public function set frameBuffersDirty (v:Boolean) :void {
			for(var i:int=frames.length-1; i >= 0; i--) {
				frames[i].buffersDirty = v;
			}
		}
		
		public override function initMesh (session:RenderSession) :Boolean {
			if(layer) {
				var lyr:Layer = layer[session.viewId] || null;
				if(lyr != null) {
					lyr.updateSession(session);
				}
			}else{
				// set default layer
				if(session._graphics != session.defaultSession__graphics) session.useDefaultSession();
			}
			
			if(singlePoints != null) {
				var _p:Vector.<Vertex> = singlePoints;
				var L:int = _p.length;
				var _i:int;
				var cgv:Matrix3d;
				
				if(L>0) {
					cgv = camMatrix;
					var v:Vertex;
					var cam:Camera3d = session.scene.cam;
					var _nearClipping:Number = cam._nearClipping;
					var _farClipping:Number = cam._farClipping;
					var ofc:int = frameCounter;
					var _w:Number = cam.t;	var _h:Number = cam.s;
					var x:Number;	var y:Number;	var z:Number;
					var a:Number = cgv.a;	var b:Number = cgv.b;	var c:Number = cgv.c;
					var e:Number = cgv.e;	var f:Number = cgv.f;	var g:Number = cgv.g;
					var i:Number = cgv.i;	var j:Number = cgv.j;	var k:Number = cgv.k;
					var m:Number = cgv.m;	var n:Number = cgv.n;	var o:Number = cgv.o + cam._nearClipping;
					
					
					if(cam.ortho) {
						var scale:Number = cam.orthoScale;
						o = cgv.o
						for(_i=0; _i<L; _i++) {
							v = _p[_i];
							x = v.x;	y = v.y; 	z = v.z;
							v.wz = c*x + g*y + k*z + o;
							v.wy = b*x + f*y + j*z + n;
							v.wx = a*x + e*y + i*z + m;
							v.sy = _h - v.wy/scale * _h;
							v.sx = _w + v.wx/scale * _w;
							
							if( v.sx < 0 || v.sy < 0 || v.sx > cam._width || v.sy > cam._height ) continue;
							v.frameCounter2 = ofc;
						}
					}
					else{
						for(_i=0; _i<L; _i++) {
							v = _p[_i];
							x = v.x;	y = v.y; 	z = v.z;
							v.wz = c*x + g*y + k*z + o;
							v.wy = b*x + f*y + j*z + n;
							v.wx = a*x + e*y + i*z + m;
							if(v.wz < _nearClipping || v.wz > _farClipping || v.wy < -v.wz || v.wy > v.wz || v.wx < -v.wz || v.wx > v.wz) continue;
							
							v.frameCounter2 = ofc;
							if(v.wz>0) {
								v.sy = _h - v.wy/v.wz * _h;
								v.sx = _w + v.wx/v.wz * _w;
							}else{
								v.sy = _h - v.wy * _h;
								v.sx = _w + v.wx * _w;
							}
						}
					}
				}
			}
			hwRend = false;
			
			if(gpuEnabled && session.context3d && session.context3d.driverInfo != "Disposed") 
			{
				var currFrame:MorphFrame = this.currentFrame;
				
				if(currFrame) 
				{
					if(buffersDirty || currFrame.buffersDirty || session.allBuffersDirty || !currFrame.meshBuffer) 
					{
						if(session.allBuffersDirty) {
							L = frames.length;
							for(_i=0; _i<L; _i++) {
								frames[_i].buffersDirty = true;
							}
						}
						
						//buffersDirty = false;
						//currFrame.buffersDirty = false;
						
						// upload current frame to gpu
					
						currFrame.initBuffers(session);
						surfaceIndex = new Dictionary(true);
						
						var mb:MeshBuffer;
						var fc:Face;
						var sf:Surface;
						
						L = polygons.length;
						for(_i=0; _i<L; _i++) 
						{
							fc = polygons[_i];
							
							if(fc.vLen >= 3) 
							{
								sf = fc.surface;
								
								if( surfaceIndex[sf] == null) 
								{
									mb = new MeshBuffer();
									mb.so = this;
									
									if( !sf.program ) sf.program = new MeshProgram();
									if( sf.programDirty || session.allBuffersDirty ) {
										sf.program.setMaterial(sf, session);
										sf.programDirty = false;
									}
									
									mb.prg = sf.program;
									surfaceIndex[sf] = currFrame.meshBuffer.push(mb)-1;
								}
								else
								{
									mb = currFrame.meshBuffer[surfaceIndex[sf]];
								}
								mb.addFace(fc, currFrame.points[ getPointId(fc.a) ],
									currFrame.points[ getPointId(fc.b) ],currFrame.points[ getPointId(fc.c) ]
								);
							}
						}
						
						L = currFrame.meshBuffer.length;
						for(_i=0; _i<L; _i++) {
							currFrame.meshBuffer[_i].upload(session);
						}
						
						buffersDirty = false;
						currFrame.buffersDirty = false;
					}
					
					if(currFrame.meshBuffer != null) 
					{
						cgv = camMatrix;
						viewVec[0] = cgv.a; viewVec[1] = cgv.e; viewVec[2] = cgv.i; viewVec[3] = cgv.m;
						viewVec[4] = cgv.b; viewVec[5] = cgv.f; viewVec[6] = cgv.j; viewVec[7] = cgv.n;
						viewVec[8] = cgv.c; viewVec[9] = cgv.g; viewVec[10] = cgv.k; viewVec[11] = cgv.o;
						viewVec[12] = cgv.c; viewVec[13] = cgv.g; viewVec[14] = cgv.k;
						viewVec[15] = cgv.o + session.camera._nearClipping;
						
						cgv = transform.gv;
						modelViewVec[0] = cgv.a; modelViewVec[1] = cgv.e; modelViewVec[2] = cgv.i; modelViewVec[3] = cgv.m;
						modelViewVec[4] = cgv.b; modelViewVec[5] = cgv.f; modelViewVec[6] = cgv.j; modelViewVec[7] = cgv.n;
						modelViewVec[8] = cgv.c; modelViewVec[9] = cgv.g; modelViewVec[10] = cgv.k; modelViewVec[11] = cgv.o;
						modelViewVec[12] = 0; modelViewVec[13] = 0; modelViewVec[14] = 0; modelViewVec[15] = 1;
						
						// render all surfaces of the object
						L = currFrame.meshBuffer.length;
						for(_i=0; _i<L; _i++) {
							currFrame.meshBuffer[_i].draw(session);
						}						
					
						hwRend = true;
						// abort any as3 renderer
						 return true;
					}
				}
			}// if gpu enabled
			
			return false;
		}
		
		private var hwRend:Boolean=false;
		
		public override function addPoint (x:Number=0, y:Number=0, z:Number=0, testPoints:Boolean=false) :int {
			if(testPoints) {
				var id:int = indexOfPoint(x,y,z);
				if(id >= 0) return id;
			}
			objectCuller.testPoint(x, y, z);
			
			var L:int = frames.length;
			var fr:MorphFrame;
			for(var i:int=0; i<L; i++) {
				fr = frames[i];
				fr.points.push(new Vertex(x,y,z));
				fr.objectCuller.testPoint(x,y,z);
			}
			
			return points.push(new Vertex(x,y,z)) - 1;
		}
		
		/**
		 * Add a Vertex to the SceneObject
		 * @param	v the Vertex to add
		 * @return The id of the point in the points list
		 */
		public override function addVertex (v:Vertex) :int {
			var id:int = points.indexOf(v);
			if(id >= 0) return id;
			
			var L:int = frames.length;
			var fr:MorphFrame;
			for(var i:int=0; i<L; i++) {
				fr = frames[i];
				fr.points.push(new Vertex(v.x,v.y,v.z));
				fr.objectCuller.testPoint(v.x,v.y,v.z);
			}
			
			objectCuller.testPoint(v.x, v.y, v.z);
			return points.push(v)-1;
		}
		
		/**
		 * Calculate point normals for smooth lighting
		 */
		public override function calculatePointNormals () :void {
			
			var L:int = frames.length;
			var fr:MorphFrame;
			var tmpPoints:Vector.<Vertex> = points;
			
			for(var i:int=0; i<L; i++) {
				fr = frames[i];
				points = fr.points;
				super.calculatePointNormals();
			}
			
			points = tmpPoints;
			super.calculatePointNormals();	
		}
		
		public function get morphFrames () :Vector.<MorphFrame> {	return frames;	}
		
		/** Play all frames */
		public function play () :void {
			if(timer == null) timer = new Timer(_frameTime, 0);
			timer.addEventListener( TimerEvent.TIMER, frameHandler );
			if(_playList != null) {
				if(_currentFrame >= _playList.length) _currentFrame = 0;
				else if(_currentFrame < 0) _currentFrame = 0;
			}
			timer.start();
			_isPlaying = true;
		}
		
		/** Stop playing */ 
		public function stop () :void {
			if(timer != null) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, frameHandler);
				timer = null;
			}
			_isPlaying = false;
		}
		
		private function frameHandler (e:TimerEvent) :void 
		{
			var id:int;
			var mkf:MorphKeyFrame;
			var mf:MorphFrame;
			var L:int;
			var vt:Vertex;
			var i:int;
			var t:Number;
			
			if( _playList == null || _playList.length == 0 ) 
			{
				// play all frames without playlist
				if(frames && frames.length > 0) {
					setFrame( _currentFrame );
					displayFrame = _currentFrame;
					_currentFrame++;
					// loop
					if(_currentFrame >= frames.length) _currentFrame = 0;
				}
			} 
			else if(_playList.length == 1) 
			{
				// transition
				
				id = _playList[0];
				mkf = _playListKeyFrames[0];
				
				if(hwRend == false && mkf.duration > 0) 
				{					
					// Interpolate to next frame
					if(fromFrame.points.length == 0) {
						L = points.length;
						for(i=0; i<L; i++) {
							vt = points[i];
							fromFrame.points[i] = new Vertex( vt.x, vt.y, vt.z );
						}
						mkf.startTime = getTimer();
						return;
					}
					
					t = (getTimer() - mkf.startTime) / mkf.duration;
					if(t >= 1) { 
						setFrame( id );
						displayFrame = 0;
						dispatchEvent( frameDone );
						fromFrame.points = new Vector.<Vertex>();
						stop();
					}else{ 
						interpolateToFrame( fromFrame, frames[id], t );
					}					
				}
				else
				{
					// set next frame
					setFrame( id );
					dispatchEvent( frameDone );
					stop();
				}
			} 
			else 
			{ 
				// play the playlist
				
				if(_currentFrame >= _playList.length) _currentFrame=0;
				
				id = _playList[_currentFrame];
				mkf = _playListKeyFrames[_currentFrame];
				mf = frames[id];
				
				if(hwRend == false && mkf.duration > 0) 
				{
					if(fromFrame.points.length == 0) {
						L = points.length;
						for(i=0; i<L; i++) {
							vt = points[i];
							fromFrame.points[i] = new Vertex( vt.x, vt.y, vt.z );
						}
						mkf.startTime = getTimer();
						return;
					}
					
					t = (getTimer() - mkf.startTime) / mkf.duration;
					if(t >= 1) {
						setFrame( id );
						displayFrame = 0;
						dispatchEvent( frameDone );
						fromFrame.points = new Vector.<Vertex>();
						
						_currentFrame++;
						if(_currentFrame >= _playList.length) _currentFrame = 0;
						
					}else{
						interpolateToFrame( fromFrame, mf, t );
					}	
				}
				else
				{
					setFrame( id );
					dispatchEvent( frameDone );
					_currentFrame++;  
					if(_currentFrame >= _playList.length) _currentFrame = 0;
				}
				
			}
		}
		
		/**
		* Set the playlist, 
		* @param list the array contains either names of morph frames or int ids, if list is null the mkf list is used for the playlist
		* @param mkf optional set the playlist from a Vector of MorphKeyFrames, if mkf is null it will be created automatically
		* @param defaultDuration the time for a frame
		*/ 
		public function setPlayList (list:Array=null, mkf:Vector.<MorphKeyFrame>=null, defaultDuration:Number=0) :void {
			_playList = new Vector.<int>();
			var L:int, i:int;
			if(list) {
				if(mkf == null)	mkf = new Vector.<MorphKeyFrame>();
				L = list.length;
				for(i=0; i<L; i++) {
					if(typeof(list[i]) == "string") {
						_playList[i] = _frameIndex[ list[i] ];
					}else{
						_playList[i] = list[i];
					}
					if(mkf.length <= i || mkf[i] == null) { // add morphkeyframe
						mkf[i] = new MorphKeyFrame( _playList[i], defaultDuration );
					}
				}
			}else if(mkf) {
				L = mkf.length;
				for(i=0; i<L; i++) {
					_playList[i] = mkf[i].id;
				}
			}
			_playListKeyFrames = mkf;
		}
		
		/**
		* Get the playList.
		* @param getNames if getNames is false the list contains MorphKeyFrame objects
		*/ 
		public function getPlayList (getNames:Boolean=true) :Array {
			var rv:Array = [];
			var L:int, i:int;
			if(_playList != null && _playList.length > 0) {
				L = _playList.length;
				if(getNames) {
					for(i=0; i<L; i++) {
						rv[i] = frames[ _playList[i] ].name;
					}
				}else{
					for(i=0; i<L; i++) {
						rv[i] = _playListKeyFrames[i];
					}
				}
			}/*else{
				var fr:Vector.<MorphFrame> = this.frames;
				L = fr.length;
				for(i=0; i<L; i++) rv[i] = fr[i];
			}*/
			return rv;
		}
		
		/**
		* Add a frame to the playlist
		* @param frame a string or int frame id
		*/ 
		public function addToPlayList( frame:*, duration:Number=0 ) :int {
			if(_playList == null) _playList = new Vector.<int>();
			if(_playListKeyFrames == null) _playListKeyFrames = new Vector.<MorphKeyFrame>();
			
			var i:int = _playList.length;
			
			if(frame is String) {
				_playList[i] = _frameIndex[ frame ];
			}else{
				_playList[i] = frame;
			}
			
			_playListKeyFrames[i] = new MorphKeyFrame( _playList[i], duration );
			return i;
		}
		
		/**
		* Remove a frame from the playList
		* @param frame a string or int frame id
		*/ 
		public function removeFromPlayList( frame:* ) :void {
			var id:int;
			if(frame is String) {
				if(!_frameIndex[frame]) return;
				id = _frameIndex[frame];
			}else{
				id = frame;
			}
			for(var i:int = _playList.length-1; i>=0; i--) {
				if(_playList[i] == id) {
					_playList.splice(i,1);
					if(_playListKeyFrames.length > i) _playListKeyFrames.splice(i,1);
				}
			}
		}
		public function clearPlayList () :void {
			_playList = null;
			this._playListKeyFrames = null;
		}
		/**
		* Returns true if a frame is in the playList
		* @param frame the name of the frame or the int id 
		*/ 
		public function isOnPlayList (frame:*) :Boolean {
			var id:int;
			if(frame is String) {
				if(!_frameIndex[frame]) return false;
				id = _frameIndex[frame];
			}else{
				id = frame;
			}
			if(_playList && _playList.indexOf(id) >= 0 ) return true;
			return false;
		}
		
		/** Returns the totalframes, if no playlist is set it returns the length of all frames otherwise the length of the playlist */ 
		public function get totalFrames () :Number {
			if( _playList == null || _playList.length == 0 ) {
				return frames.length;
			}
			return _playList.length;
		}
		
		/** Returns the name of the currentFrame */ 
		public function get currentFrame () :MorphFrame 
		{
			if(_playList == null || _playList.length == 0) {
				if(_currentFrame >= 0 && _currentFrame < frames.length) {
					return frames[_currentFrame];	
				} 
			}else{
				if(_currentFrame >= 0 && _currentFrame < _playList.length) {
					return frames[_playList[_currentFrame]];	
				}
			}
				
			return null;
		}	
		/** Returns the name of the currentFrame */ 
		public function get currentFrameName () :String 
		{
			return currentFrame.name || "";
		}
		
		/** Returns an Array with the names of all frames */ 
		public function get frameNames () :Array {
			var rv:Array = [];
			for( var nm:String in _frameIndex ) {
				rv.push(nm);
			}
			return rv;
		}
		
		public override function clearGeometry():void {
			frames = new Vector.<MorphFrame>();
			_frameIndex = new Dictionary(true);
			_currentFrame = 0;
		}
				
		/** Add a morph frame. The MD2 Loader automatically adds the morph frames */ 
		public function addMorph (name:String, pts:Vector.<Vertex>) :int {
			var mf:MorphFrame = new MorphFrame(name);
			mf.points = pts;
			mf.updateBounds();
			var id:int = frames.push( mf )-1;
			_frameIndex[name] = id;
			return id;
		}
		
		/** Returns the id of a morph frame */
		public function getFrameId (fr:MorphFrame) :int {	return frames.indexOf(fr);	}
		/** Returns a morphframe by name */
		public function getFrameByName (name:String) :MorphFrame {	return frames[_frameIndex[name]] || null;	}
		/** Returns a morph frame by id */
		public function getFrameById (id:int) :MorphFrame {
			if(id>=0 && id<frames.length) {
				return frames[id];
			}
			return null;
		}
		
		/** Apply a frame by name */ 
		public function setFrameByName (name:String) :void {
			if(_frameIndex[name]) {
				if(_playList != null) {
					var fr:int = _playList.indexOf( _frameIndex[name] );
					if(fr >= 0) {
						_currentFrame = fr;
					}
				}else{
					_currentFrame = _frameIndex[name];
					setFrame( _currentFrame );
				}
			}
		}
		
		/** True if the animation is playing */
		private var _isPlaying:Boolean=false;
		public function get isPlaying () :Boolean {	return _isPlaying;	}
		
		/** Set the frame time of the animation */
		public function set frameFps (v:Number) :void {	frameTime = 1000/v;		}
		public function get frameFps () :Number {	return int(1000/_frameTime);	}
		
		/** Set the frame time of the animation */
		public function set frameTime (v:int) :void {
			_frameTime = v;
			if(timer != null) {
				timer.delay = _frameTime;
			}
		}
		public function get frameTime () :int {
			return _frameTime;
		}
		
		/** 
		* Apply a interpolated frame between two frames
		* @param from frame id
		* @param to frame id
		* @param time a number between 0 and 1
		*/ 
		public function interpolateToFrame (frFrom:MorphFrame, frTo:MorphFrame, time:Number) :void 
		{
			var pts:Vector.<Vertex> = frFrom.points;
			var ptsTo:Vector.<Vertex> = frTo.points;
			
			var L:int = pts.length;
			if(L > points.length) L = points.length;
			
			var v:Vertex;
			var mv:Vertex;
			var tv:Vertex;
			var i:int;
			
			objectCuller.reset();
			objectCuller.testPoint(  	frFrom.objectCuller.minx + (frTo.objectCuller.minx - frFrom.objectCuller.minx)*time,  
										frFrom.objectCuller.miny + (frTo.objectCuller.miny - frFrom.objectCuller.miny)*time,
										frFrom.objectCuller.minz + (frTo.objectCuller.minz - frFrom.objectCuller.minz)*time  
			);
			
			objectCuller.testPoint(  	frFrom.objectCuller.maxx + (frTo.objectCuller.maxx - frFrom.objectCuller.maxx)*time,  
										frFrom.objectCuller.maxy + (frTo.objectCuller.maxy - frFrom.objectCuller.maxy)*time,
										frFrom.objectCuller.maxz + (frTo.objectCuller.maxz - frFrom.objectCuller.maxz)*time  
			);
			
			
			for(i = 0; i<L; i++) {
				v = points[i];
				mv = pts[i];
				tv = ptsTo[i];
				v.x = mv.x + (tv.x-mv.x)*time;	
				v.y = mv.y + (tv.y-mv.y)*time;
				v.z = mv.z + (tv.z-mv.z)*time;
			}
			
			var bf:Vector.<Face> = polygons;
			
			if(bf != null ) {
				L = bf.length;
				var fc:Face;
				var ax:Number;	var ay:Number;	var az:Number;
				var x1:Number;	var y1:Number;	var z1:Number;
				var x2:Number;	var y2:Number;	var z2:Number;
				var _j:int;
				
				for(i=0; i<L; i++) 
				{
					fc = bf[i];
					
					if( fc.vLen > 2 ) {
						// only triangles are fully supported with morphs
						fc.ax = (fc.a.x + fc.b.x + fc.c.x ) / 3;
						fc.ay = (fc.a.y + fc.b.y + fc.c.y ) / 3;
						fc.az = (fc.a.z + fc.b.z + fc.c.z ) / 3;
						
						// calculating the normal for lighting is very slow..
						x1 = fc.b.x-fc.a.x;	
						y1 = fc.b.y-fc.a.y;	
						z1 = fc.b.z-fc.a.z;
						
						x2 = fc.c.x-fc.a.x;		
						y2 = fc.c.y-fc.a.y;		
						z2 = fc.c.z-fc.a.z;
						
						ax = y1 * z2 - z1 * y2;
						ay = z1 * x2 - x1 * z2;
						az = x1 * y2 - y1 * x2;
						
						x1 = -Math.sqrt(ax*ax + ay*ay + az*az);
						
						fc.normal.x = ax/x1;		
						fc.normal.y = ay/x1;		
						fc.normal.z = az/x1;
						
					}else if(fc.vLen == 2) {
						fc.ax = (fc.a.x + fc.b.x ) / 2;
						fc.ay = (fc.a.y + fc.b.y ) / 2;
						fc.az = (fc.a.z + fc.b.z ) / 2;
					}
				}
			}
		}
		
		/** Apply a frame by id */ 
		public function setFrame (f:int) :void 
		{
			if( f >= 0 && f < frames.length ) 
			{
				var fr:MorphFrame = frames[f];
				objectCuller.reset();
				objectCuller.testPoint( fr.objectCuller.minx, fr.objectCuller.miny, fr.objectCuller.minz );
				objectCuller.testPoint( fr.objectCuller.maxx, fr.objectCuller.maxy, fr.objectCuller.maxz );
				
				if(hwRend) return;
				
				var pts:Vector.<Vertex> = fr.points;
				var L:int = pts.length;
				if( L > points.length) L = points.length;
				
				var v:Vertex;
				var mv:Vertex;
				var i:int;
				
				for(i = 0; i<L; i++) {
					v = points[i];
					mv = pts[i];
					v.x = mv.x;	v.y = mv.y;	v.z = mv.z;
				}

				var bf:Vector.<Face> = polygons;
				
				if(bf != null ) 
				{
					var L2:int = bf.length;
					var fc:Face;
					var ax:Number;	var ay:Number;	var az:Number;
					var x1:Number;	var y1:Number;	var z1:Number;
					var x2:Number;	var y2:Number;	var z2:Number;
					var _j:int;
					
					for(i=0; i<L2; i++) 
					{
						fc = bf[i];
						
						if( fc.vLen > 2 ) {
							// only triangles are fully supported with morphs
							fc.ax = (fc.a.x + fc.b.x + fc.c.x ) / 3;
							fc.ay = (fc.a.y + fc.b.y + fc.c.y ) / 3;
							fc.az = (fc.a.z + fc.b.z + fc.c.z ) / 3;
							
							// calculating the normal for lighting is very slow..
							x1 = fc.b.x-fc.a.x;	
							y1 = fc.b.y-fc.a.y;	
							z1 = fc.b.z-fc.a.z;
							
							x2 = fc.c.x-fc.a.x;		
							y2 = fc.c.y-fc.a.y;		
							z2 = fc.c.z-fc.a.z;
							
							ax = y1 * z2 - z1 * y2;
							ay = z1 * x2 - x1 * z2;
							az = x1 * y2 - y1 * x2;
							
							x1 = -Math.sqrt(ax*ax + ay*ay + az*az);
							
							fc.normal.x = ax/x1;		
							fc.normal.y = ay/x1;		
							fc.normal.z = az/x1;
							
						}else if(fc.vLen == 2) {
							fc.ax = (fc.a.x + fc.b.x ) / 2;
							fc.ay = (fc.a.y + fc.b.y ) / 2;
							fc.az = (fc.a.z + fc.b.z ) / 2;
						}
					}
				}
			}
		}
		
		
		public override function clone () :SceneObject 
		{
			var r:SceneObjectMorph = new SceneObjectMorph();
			if(shared) {
				for(var id:String in shared) {
					r.shared[id] = shared[id];
				}
			}
			r.objectCuller = objectCuller.clone();
			r.setTransform( transform.clone() );
			var L:int;
			var j:int;
			var i:int;
			var pt:Vertex;
			var fc:Face;
			var k:int;
			var L2:int;
			// copy points
			L = points.length;
			for(i=0; i<L; i++) {
				pt = points[i];
				r.addPoint( pt.x, pt.y, pt.z );
			}
			
			// copy polys
			var uvs:Vector.<UVCoord>;
			var verts:Vector.<int>;
			
			L = polygons.length;
			for(i=0; i<L; i++) {
				fc = polygons[i];
				if(fc.vLen == 2) {
					r.addLine( fc.surface, getPointId(fc.a), getPointId(fc.b));
				}else if(fc.vLen == 3) {
					r.addTriangle( fc.surface, 
									getPointId(fc.a),
									getPointId(fc.b),
									getPointId(fc.c), 
									new UVCoord(fc.u1,fc.v1), 
									new UVCoord(fc.u2,fc.v2),
									new UVCoord(fc.u3,fc.v3));
				
				}else if(fc.vLen >= 4) {
					
					verts = new Vector.<int>();
					uvs = new Vector.<UVCoord>();
					
					L2 = fc.vtxs.length;
					for(k=0; k<L2; k++) {
						verts[k] = getPointId( fc.vtxs[k] );
					}
					
					if(fc.uvs) {
						L2 = fc.uvs.length;
						for(k=0; k<L2; k++) {
							uvs[k] = new UVCoord( fc.uvs[k].u, fc.uvs[k].v );
						}
					}
					
					r.addPolygonVector(fc.surface, verts, uvs);
				}
			}
			
			var fr:MorphFrame;
			var pts:Vector.<Vertex>;
			
			for(i=0; i<frames.length; i++) {
				fr = frames[i];
				pts = new Vector.<Vertex>();
				L = fr.points.length;
				for(j=0; j<L; j++) {
					pts[j] = fr.points[j].clone();
				}
				
				r.addMorph(fr.name, pts);
			}
			
			// copy playlist
			if(_playList != null) {
				L = _playList.length;
				for(j=0; j<L; j++) 
				{
					r.addToPlayList( _playListKeyFrames[j].id, _playListKeyFrames[j].duration);
				}
			}
			
			r.setFrame( _currentFrame );
			
			if(this._isPlaying) r.play();
			
			
			return SceneObject(r);
		}
		
		
	}
}