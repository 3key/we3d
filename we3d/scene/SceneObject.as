package we3d.scene 
{
	import flash.utils.Dictionary;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.core.transform.Transform3d;
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
	use namespace we3d;
	
	/** 
	* SceneObjects are the mesh objects in a 3d scene
	*/
	public class SceneObject extends Object3d 
	{
		public function SceneObject() {}
		
		/** 
		* Points of the object (Vertex) 
		*/
		public var points:Vector.<Vertex>=new Vector.<Vertex>();
		/** 
		* Polygons of the object (Face)
		*/
		public var polygons:Vector.<Face>=new Vector.<Face>();
		/** 
		 * @private
		 */ 
		we3d var layer:Dictionary;
		/**
		 * @private
		 */
		we3d var layerId:int=-1;
		/**
		* Used to render single points, need a call of updateSinglePoints after every change in the points list
		*/
		public var singlePoints:Vector.<Vertex>;
		
		we3d var viewVec:Vector.<Number> = new Vector.<Number>(16);
		
		we3d var modelViewVec:Vector.<Number> = new Vector.<Number>(32);
		
		we3d var meshBuffer:Vector.<MeshBuffer>;
		we3d var surfaceIndex:Dictionary;
		
		
		/**
		 * Enable GPU rendering.
		 * Disabling objects on the gpu allows to render them with AS3 Software renderer on top of the Stage3D
		 */ 
		public var gpuEnabled:Boolean = true;
		
		/**
		* Set the 2d layer for the scene object. It's possible to set more layers for different views if multiple views are used with the same SceneObjects.
		* Note: Objects with GPU enbaled have to be in the firstLayer (view.firstLayer) wich is the default Layer. 
		* @param	scene	the scene wich provides the layer
		* @param	lyr		the layer were the object should be rendered
		*/
		public function setLayer (view_id:int, lyr:Layer) :void {
			if(layer == null) layer = new Dictionary(true);
			layer[view_id] = lyr;
		}
		
		/**
		* Remove a 2d layer set with setLayer.
		* @param	view_id	the id of the view wich provides the layer
		* @param	lyr		the layer of the object
		*/
		public function clearLayer (view_id:int, lyr:Layer) :void {
			if(layer != null){
				if(layer[view_id]) delete layer[view_id];
			}
		}
		
		/**
		* Remove all 2d layers set with setLayer.
		*/
		public function removeLayers () :void {
			layer = null;
		}
		/**
		* Clear points, polygons, and reset the bounding box
		*/ 
		public function clearGeometry () :void 
		{
			points = new Vector.<Vertex>();
			polygons = new Vector.<Face>();
			
			objectCuller.reset();
		}
		 
		/** 
		* Add a point to the Object's point list
		* @param	x
		* @param	y
		* @param	z
		* @param	testPoints	if true test if the point is already available“
		* @return The id of the point in the points list
		*/
		public function addPoint (x:Number=0, y:Number=0, z:Number=0, testPoints:Boolean=false) :int {
			if(testPoints) {
				var id:int = indexOfPoint(x,y,z);
				if(id >= 0) return id;
			}
			objectCuller.testPoint(x, y, z);
			return points.push(new Vertex(x,y,z)) - 1;
		}
		
		/**
		* Add a Vertex to the SceneObject
		* @param	v the Vertex to add
		* @return The id of the point in the points list
		*/
		public function addVertex (v:Vertex) :int {
			var id:int = points.indexOf(v);
			if(id >= 0) return id;
			objectCuller.testPoint(v.x, v.y, v.z);
			return points.push(v)-1;
		}
		
		/**
		* Calculate point normals for smooth lighting
		*/
		public function calculatePointNormals () :void {
			
			var ax:Number;
			var ay:Number;
			var az:Number;
			var c:Number;
			
			var L:int =  points.length;
			var i:int;
			var j:int;
			var k:int;
			var plg:Face;
			var plgs:int = polygons.length;
			var p:Vertex;
			
			for(i=0; i<L; i++) {
				
				ax = ay = az = c = 0;
				p = points[i];
				
				for(j=0; j<plgs; j++) {
					
					plg = polygons[j];
					
					for(k=0; k<plg.vtxs.length; k++) {
						if(plg.vtxs[k] == p) {
							ax += plg.normal.x;
							ay += plg.normal.y;
							az += plg.normal.z;
							c++;
						}
					}
				}
				
				ax /= c;
				ay /= c;
				az /= c;
				if(p.normal == null) p.normal = new Vector3d(ax,ay,az);
				else p.assign(ax,ay,az);
				
			}
		}
		public function addLine ( surface:Surface, a:int, b:int ) :Face 
		{
			var pts:Vector.<Vertex> = new Vector.<Vertex>();
			pts.push( points[a], points[b] );
			
			var fc:Face = new Face();
			fc.surface = surface;
			fc.vtxs = pts;
			fc.init(this);
			
			polygons.push(fc);
			return fc;
		}
		
		public function addTriangle ( surface:Surface, a:int, b:int, c:int, uv1:UVCoord=null, uv2:UVCoord=null, uv3:UVCoord=null) :Face 
		{
			var pts:Vector.<Vertex> = new Vector.<Vertex>();
			pts.push( points[a], points[b], points[c] );
			
			var fc:Face = new Face();
			fc.surface = surface;
			fc.vtxs = pts;
			fc.init(this);
			
			polygons.push(fc);
			
			if(uv1 && uv2 && uv3) {
				fc.setUvCoordAt( 0, uv1 );
				fc.setUvCoordAt( 1, uv2 );
				fc.setUvCoordAt( 2, uv3 );
			}
			
			return fc;
		}
		
		/**
		* Add a new polygon to the SceneObject 
		* 
		* <code><pre>
		* 	import we3d.scene.SceneObject;
		* 	import we3d.material.Surface;
		* 	
		* 	var obj:SceneObject = new SceneObject();
		* 
		* 	obj.addPoint(0,0,0);
		* 	obj.addPoint(100,0,0);
		* 	obj.addPoint(-100,0,0);
		* 
		* 	var sf:Surface = new Surface();
		* 
		* 	obj.addPolygon(sf, 0, 1, 2);
		* 	obj.addPolygon(sf, [2, 1, 0]);
		* </pre></code>
		*  
		* @param	surface	surface of the polygon
		* @param	... verts	vertices of the polygon
		* @return the id in the polygons array
		*/
		public function addPolygon (surface:Surface, ...verts:Array) :Face {
			var pts:Vector.<Vertex> = new Vector.<Vertex>();
			var i:int;
			var L:int;
			
			if(verts[0] is Array) {
				var a:Array = verts[0];
				L = a.length;
				for(i=0; i<L; i++) {
					pts.push(points[a[i]]);
				}
			}else{
				L = verts.length;
				for(i=0; i<L; i++) {
					pts.push(points[verts[i]]);
				}
			}
			
			var fc:Face = new Face();
			fc.surface = surface;
			fc.vtxs = pts;
			fc.init(this);
			
			polygons.push(fc);
			
			return fc;
		}
		
		public function addPolygonVector (surface:Surface, verts:Vector.<int>, uvs:Vector.<UVCoord>=null) :Face {
			var pts:Vector.<Vertex> = new Vector.<Vertex>();
			var i:int;
			var L:int;
			
			L = verts.length;
			for(i=0; i<L; i++) {
				pts.push(points[verts[i]]);
			}
			
			var fc:Face = new Face();
			fc.surface = surface;
			fc.vtxs = pts;
			fc.init(this);
			
			polygons.push(fc);
			
			if(uvs) {
				fc.setUvCoords( uvs );
			}
			
			return fc;
		}
		
		/**
		* Copy the polygons from the array into this SceneObject
		*/
		public function copyPolygons (arr:Vector.<Face>) :void {
			var f:Face;
			var L:int = arr.length;
			var j:int;
			var L2:int;
			var vt:Vertex;
			var pid:int;
			var vertices:Array;
			var nf:Face;
			
			for(var i:int=0; i<L; i++) {
				f = arr[i];
				if(polygons.indexOf(f) == -1) {
					L2 = f.vtxs.length;
					vertices = [];
					for(j=0; j<L2; j++) {
						vt = f.vtxs[j];
						pid = indexOfPoint( vt.x, vt.y, vt.z );
						
						if(pid == -1) {
							vertices.push( addVertex(vt.clone()) );
						}else{
							vertices.push( pid );
						}
					}
					nf = addPolygon( f.surface, vertices );
					
					if( f.uvs != null ) {
						L2 = f.uvs.length;
						for(j=0; j<L2; j++) {
							nf.setUvCoordAt( j, f.uvs[j].clone() );
						}
					}
				}
			}
		}
		
		/**
		* Returns the number of points in the object
		*/
		public function get numPoints () :int {
			return points.length;
		}
		
		/**
		* Returns the number of polygons in the object
		*/
		public function get numPolygons () :int {
			return polygons.length;
		}
		
		/**
		* Returns a polygon from the polygons array
		* @param	id the array id
		* @return	a polygon
		*/
		public function polygonAt (id:int) :Face {
			return polygons[id];
		}
		
		/**
		* Returns a point from the points array
		* @param	id the array id
		* @return	a point
		*/
		public function pointAt (id:int) :Vertex {
			return points[id];
		}
		
		/**
		* Returns the id of a point
		* @param	v the point
		* @return	array id
		*/
		public function getPointId (v:Vertex) :int {
			return points.indexOf(v);
		}
		
		/**
		* Returns the id of a polygon
		* @param	f the polygon
		* @return	array id
		*/
		public function getPolygonId (f:Face) :int {
			return polygons.indexOf(f);
		}
		
		/**
		* Returns the first point in the points list or -1
		*/
		public function indexOfPoint (x:Number, y:Number, z:Number, start:int=0) :int {
			var p:Vertex;
			var L:int = points.length
			for(var i:int = start; i<L; i++) {
				p = points[i];
				if(p.x == x && p.y == y && p.z == z) return i;
			}
			return -1;
		}
		
		public override function disposeGPU () :void {
			if(meshBuffer && meshBuffer.length > 0) {
				var L:int = meshBuffer.length;
				for(var i:int=0; i<L; i++) {
					meshBuffer[i].dispose();
				}
			}
		}
		
		/**
		* @private
		*/
		public function initMesh (session:RenderSession) :Boolean {
			
			if(layer) {
				var lyr:Layer = layer[session.viewId] || null;
				if(lyr != null) {
					lyr.updateSession(session);
				}
			}else{
				// set default layer
				if(session._graphics != session.defaultSession__graphics) session.useDefaultSession();
			}
			var L:int;
			var _i:int;
			var cgv:Matrix3d;
			
			if(singlePoints != null) {
				var _p:Vector.<Vertex> = singlePoints;
				L = _p.length;
				
				if(L>0) {
					cgv = camMatrix;
					var v:Vertex;
					var cam:Camera3d = session.camera;
					var _nearClipping:Number = cam._nearClipping;
					var _farClipping:Number = cam._farClipping;
					var ofc:int = frameCounter;
					var _w:Number = cam.t;	var _h:Number = cam.s;
					var x:Number;	var y:Number;	var z:Number;
					var a:Number = cgv.a;	var b:Number = cgv.b;	var c:Number = cgv.c;
					var e:Number = cgv.e;	var f:Number = cgv.f;	var g:Number = cgv.g;
					var i:Number = cgv.i;	var j:Number = cgv.j;	var k:Number = cgv.k;
					var m:Number = cgv.m;	var n:Number = cgv.n;	var o:Number = cgv.o + _nearClipping;
					
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
			
			if(gpuEnabled && session.context3d && session.context3d.driverInfo != "Disposed") 
			{
				if(buffersDirty || session.allBuffersDirty || !meshBuffer) 
				{
					buffersDirty = false;
					
					try {
						if(meshBuffer && meshBuffer.length > 0) {
							L = meshBuffer.length;
							for(_i=0; _i<L; _i++) {
								meshBuffer[_i].dispose();
							}
						}
					}catch(e:Error) {
						// var tm;
						// Buffers already disposed...
					}
					
					// create one meshbuffer for every surface
					meshBuffer = new Vector.<MeshBuffer>();
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
								
								if( sf.programDirty || session.allBuffersDirty) {
									sf.program.setMaterial(sf, session);
									sf.programDirty = false;
								}
								
								mb.prg = sf.program;
								
								surfaceIndex[sf] = meshBuffer.push(mb)-1;
							}
							else
							{
								mb = meshBuffer[surfaceIndex[sf]];
							}
							mb.addFace(fc, fc.a, fc.b, fc.c);
						}
					}
					
					L = meshBuffer.length;
					for(_i=0; _i<L; _i++) {
						meshBuffer[_i].upload(session);
					}
				
				}
				
				if(meshBuffer != null) {
					
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
					L = meshBuffer.length;
					for(_i=0; _i<L; _i++) {
						meshBuffer[_i].draw(session);
					}
				}
				
				// abort any as3 renderer
				return true;
			}
			
			return false;
		}
		
		public function isSinglePoint (vt:Vertex) :Boolean {
			var i:int=0;
			var L:int = polygons.length;
			var p:Face;
			var k:int;
			var pL:int;
			
			for(i=0; i<L; i++) {
				p = polygons[i];
				pL = p.vtxs.length;
				for(k=0; k<pL; k++) {
					if(p.vtxs[k] === vt) return false;
				}
			}
			return true;
		}
		
		public function updateSinglePoints () :void {
			var polys:int=polygons.length;
			var L:int=points.length;
			var spts:Vector.<Vertex> = new Vector.<Vertex>();
			var sp:Boolean=false;
			var f:Face;
			var p:Vertex;
			var i:int;
			var j:int;
			var k:int;
			var L2:int;
			
			for (j=0; j<L; j++) {
				p = points[j];
				sp = true;
				for(k=0; k<polys; k++) {
					f = polygons[k];
					L2 = f.vtxs.length;
					for(i=0; i<L2; i++) {
						if(f.vtxs[i] === p) {
							sp = false;
							break;
						}
					}
					if(sp==false) break;
				}
				if(sp) spts.push( p );
			}
			if(spts.length > 0)
				singlePoints = spts;
			else 
				singlePoints = null;
		}
		
		public function clone () :SceneObject
		{
			var r:SceneObject = new SceneObject();
			r.objectCuller = objectCuller.clone();
			r.setTransform( transform.clone() );
			r.copyPolygons(polygons);
			if(shared) {
				for(var id:String in shared) {
					r.shared[id] = shared[id];
				}
			}
			return r;
		}
		
	}
}