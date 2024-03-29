 package we3d.core 
{
	import we3d.we3d;
	import we3d.core.transform.Transform3d;
	import we3d.filter.ZBuffer;
	import we3d.math.Matrix3d;
	import we3d.math.Vector3d;
	import we3d.mesh.Vertex;

	use namespace we3d;
	
	/** 
	* Every scene already have one Camera3d. Use the scene.cam property to access the camera in a scene. <br/>
	* It is also possible to access the camera from the view. This allows easy setup for multiple Views in a project. <br/>
	* By default the camera of the view is a reference to the camera in the scene.
	*/
	public class Camera3d extends Object3d 
	{
		public function Camera3d (w:Number=550, h:Number=400, fov:Number=0.7, near:Number=0.1, far:Number=0x7ffffff) {
			initProjection(fov, near, far, w, h)
		}
		
		/** 
		* @private
		* Read Only, use <code>cam.width</code> setter to set the width 
		*/
		we3d var _width:Number;
		/** 
		* @private
		* Read Only, use <code>cam.height</code> setter to set the height 
		*/
		we3d var _height:Number;
		/** 
		* @private
		* height * .5 
		*/
		we3d var s:Number;
		/** 
		* @private
		* width * .5 
		*/
		we3d var t:Number;
		/** 
		* @private
		* Projection Matrix 
		*/
		we3d var pr:Matrix3d=new Matrix3d();
		/**
		* @private
		*/
		we3d var cgv:Matrix3d=new Matrix3d();
		/**
		* @private
		*/
		public var _nearClipping:Number;
		/**
		* @private
		*/
		public var _farClipping :Number;
		/**
		* @private
		*/
		we3d var _fieldOfView:Number;
		
		we3d static var ct:Matrix3d = new Matrix3d();
		private static var sfc:int=0;
		
		public function set ortho (v:Boolean) :void {
			if(v == _ortho) return;
			_ortho = v;
			initProjection( _fieldOfView );
		}
		public function get ortho () :Boolean {
			return _ortho;
		}
		private var _ortho:Boolean=false;
		
		public var orthoScale:Number=1;
		
		we3d var _focalLength:Number;
		
		public function get focalLength () :Number {
			var f:Number = _fieldOfView/2;
			return _height/2 * (Math.cos(f) / Math.sin(f));
		}
		
		
		/**
		* Set the width of the screen
		*/
		public function set width (val:int) :void {
			initProjection(_fieldOfView, _nearClipping, _farClipping, val); 
		}
		public function get width () :int { 	return _width;	}
		
		/**
		* Set the height of the screen
		*/
		public function set height (val:int) :void {
			initProjection(_fieldOfView, _nearClipping, _farClipping, _width, val); 
		}
		public function get height () :int { 	return _height;	}
		
		/** 
		* Vertical Field Of View in radians
		*/
		public function get fov () :Number { return _fieldOfView; }
		public function set fov (r:Number) :void { 
			initProjection(r, _nearClipping, _farClipping); 
		}
		
		/** 
		* Horizontal Field Of View in radians
		*/
		public function get fovH () :Number {
			return 2*Math.atan(_width*Math.tan(_fieldOfView/2)/_height);					  
		}
		public function set fovH (f:Number) :void {
			fov = 2*Math.atan(_height*Math.tan(f/2)/_width);					  
		}
		
		/** 
		* Near clipping plane
		*/
		public function get nearClipping () :Number { return _nearClipping; }
		public function set nearClipping (n:Number) :void { 
			initProjection(_fieldOfView, n, _farClipping); 
		}
		
		/** 
		* Far clipping plane
		*/
		public function get farClipping () :Number { return _farClipping; }
		public function set farClipping (n:Number) :void { 
			initProjection(_fieldOfView, _nearClipping, n); 
		}
		
		/**
		 * @private
		 * The ZBuffer filter if zbuffer was set to true otherwise null
		 */ 
		we3d var zBufferData:ZBuffer;
		
		/**
		 * If you want to use the Scanline-ZB rasterizer you can just set camera.zbuffer and use null in the rasterizer constructor
		 * <code>
		 *  view.camera.zbuffer = true;
		 *  var sfzb:Surface = new Surface( new ScanlineTXZB(), new BitmapAttributes(bmp.bitmapData) );
		 * </code>
		 */ 
		public function get zbuffer () :Boolean {
			return _zbuffer;
		}
		public function set zbuffer (enabled:Boolean) :void {
			_zbuffer = enabled;
			if(_zbuffer) 
			{
				if(zBufferData == null) {
					zBufferData = new ZBuffer(_width, _height);
					zBufferData.createBitmap();
				}
				else zBufferData.setSize(_width, _height);
			}
			else if(!_zbuffer && zBufferData != null) 
			{
				zBufferData = null;
			}
		}
		private var _zbuffer:Boolean=false;
		
		/**
		* Translates a 3d point to screen space and stores the numeric values in the vertex v and out. <br/><br/>
		* 
		* v.wx, v.wy, v.wz     - camera space <br/>
		* v.sx, v.sy           - screen space <br/>
		* out.x, out.y, out.z  - object space (optional) <br/>
		* 
		* @param	v the vertex to translate
		* @param	cam the camera for projection
		* @param	out if out is not null, the point is first transformed with object transformation
		* @param	cull if cull is true the 2d projection is aborted if the point is outside the camera frustum, only the world coordinates (wx, wy, wz) are calculated. Culling is not supported with orthogonal cameras
		*/
		public function projectPoint (v:Vertex, obj:Object3d=null, out:Vector3d=null, cull:Boolean=false) :void {
			
			var x:Number = v.x;
			var y:Number = v.y;
			var z:Number = v.z;
			
			if(obj != null) 
			{
				var mt:Matrix3d = obj.transform.gv;
				
				x = mt.a*v.x + mt.e*v.y + mt.i*v.z + mt.m;
				y = mt.b*v.x + mt.f*v.y + mt.j*v.z + mt.n;
				z = mt.c*v.x + mt.g*v.y + mt.k*v.z + mt.o;
				
				if(out != null) {
					out.x = x;
					out.y = y;
					out.z = z;
				}
			}
			
			v.wx = cgv.a*x + cgv.e*y + cgv.i*z + cgv.m;
			v.wy = cgv.b*x + cgv.f*y + cgv.j*z + cgv.n;
			v.wz = cgv.c*x + cgv.g*y + cgv.k*z + cgv.o + _nearClipping;
			
			if(ortho) {
				v.sy = s - v.wy/orthoScale * s;
				v.sx = t + v.wx/orthoScale * t;
				
				if( v.sx < 0 || v.sy < 0 || v.sx > _width || v.sy > _height ) return;
			}else{
					if(cull) {
						if(v.wz < _nearClipping || v.wz > _farClipping || v.wy < -v.wz || v.wy > v.wz || v.wx < -v.wz || v.wx > v.wz) {
							v.culled = true;
							return;
						}
					}else{
						v.culled = false;
					}
				if(v.wz>0) {
					v.sy = s - v.wy/v.wz * s;
					v.sx = t + v.wx/v.wz * t;
				}else{
					v.sy = s - v.wy * s;
					v.sx = t + v.wx * t;
				}
			}
			v.frameCounter2 = Transform3d.FCounter;
		}
		
		/** 
		* Initializes the projection matrix: <br/>
		* <code>
		*   view.camera.initProjection( 60 * Math.PI/180, 0, 90000, 1280, 720 );
		* </code>
		* 
		* @param	fov		Vertical Field Of View angle in radian
		* @param	near	Near Clipping Plane in 3d units
		* @param	far		Far Clipping Plane in 3d units
		* @param	w		Width of the camera screen
		* @param	h		Height of the camera screen
		*/
		public function initProjection (_fov:Number, near:Number=-1, far:Number=-1, w:Number=-1, h:Number=-1) :void {
			if(_fov <= 0) _fov = 45*Math.PI/180;
			_fieldOfView = _fov;
			
			if(near != -1) _nearClipping = near;
			if(far != -1) _farClipping = far;
			
			if(w != -1) {
				_width = w;
				t = _width * .5;
			}
			if(h != -1) {
				_height = h;
				s = _height * .5;
			}
			
			_focalLength = focalLength;
			
			if(_zbuffer) {
				if(zBufferData == null) {
					zbuffer = true;
				}else{
					zBufferData.setSize( _width, _height );
				}
			}
			
			if(_ortho) {
				var w2:Number = _width;
				var h2:Number = _height;
				
				pr.initialize();
				pr.a = 2/w2;
				pr.f = 2/h2;
				pr.k = 1/(_farClipping-_nearClipping);
				pr.o = (_nearClipping/(_nearClipping-_farClipping));
				
			}else{
				var aspect:Number = _height/_width;
				var h:Number = Math.cos(_fieldOfView/2)/Math.sin(_fieldOfView/2);
				var w:Number = aspect * h;
				var q:Number = _farClipping/(_farClipping-_nearClipping);
				
				pr.initialize();
				pr.a = w;
				pr.f = h;
				pr.k = q;
				pr.o = -q * _nearClipping;
			}
		}
		
		/**
		* @private
		*/
		public function initCamFrame (f:Number) :void {
			
			if(transform._parent != null) {
				var p:Transform3d = transform._parent;
				var objs:Array = [];
				while(p) {
					objs.push(p);
					p = p._parent;
				}
				for(var i:int=objs.length-1; i>=0; i--)  objs[i].initFrame(f);
			}
			
			Transform3d.FCounter = sfc++;
			
			if(frameInit) transform.initFrame(f);
			
			if(_zbuffer) zBufferData.clear();
			
			var gv:Matrix3d = transform.gv;
			
			cgv.a = gv.a*pr.a;	cgv.b = gv.e*pr.f;	cgv.c = gv.i*pr.k;	
			cgv.e = gv.b*pr.a;	cgv.f = gv.f*pr.f;	cgv.g = gv.j*pr.k;	
			cgv.i = gv.c*pr.a;	cgv.j = gv.g*pr.f;	cgv.k = gv.k*pr.k;
			
			var x:Number = gv.m;
			var y:Number = gv.n;
			var z:Number = gv.o;
			
			cgv.m = -(x * gv.a + y * gv.b + z * gv.c) * pr.a;
			cgv.n = -(x * gv.e + y * gv.f + z * gv.g) * pr.f;
			cgv.o = -(x * gv.i + y * gv.j + z * gv.k) * pr.k + pr.o;
						
		}
		
		public function clone () :Camera3d {
			var r:Camera3d = new Camera3d();
			r.setTransform( transform.clone() );
			r.initProjection( _fieldOfView, _nearClipping, _farClipping, _width, _height);
			r.zbuffer = zbuffer;
			r.ortho = ortho;
			return r;
		}
		
	}
}