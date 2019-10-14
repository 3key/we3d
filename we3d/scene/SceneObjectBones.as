package we3d.scene 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.math.Matrix3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;
	import we3d.scene.Bone;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/** 
	* SceneObjectBones can transform their mesh with bones.  A bones object should contain only triangles and two point polys
	*/
	public class SceneObjectBones extends SceneObject 
	{
		public function SceneObjectBones () {}
		
		/**
		 * The polygons wich contain a point from the bones.points list 
		 */
		public var polyTable:Vector.<Face>;
		/**
		* Array with all Bones of the object
		*/
		public var bones:Vector.<Bone>;
		/**
		* Add a bone to the object
		*/
		public function addBone (b:Bone) :void {
			if(bones==null) bones = new Vector.<Bone>();
			bones.push(b);
		}
		/**
		* Update the polyTable of a bone, the polytable have to be updated after the point list of a bone has changed
		*/ 
		public function updateBoneTable () :void 
		{
			polyTable = new Vector.<Face>();
			for(var i:int=0; i<bones.length; i++) 
			{
				updateBoneTbl( bones[i] );
			}
		}
		
		/**
		* The bone table have to be updated if a bone is added or removed from the object
		*/ 
		public function updateBoneTbl (b:Bone) :void {
			var pts:Vector.<int> = b.points;
			var bL:int = pts.length;
			var L:int = polygons.length;
			var id:int;
			var j:int;
			var f:Face;
			var v:Vertex;
			
			for(var i:int=0; i<L; i++) {
				f = polygons[i];
				if(polyTable.indexOf(f) >= 0) continue;
				
				for(j=0; j<bL; j++) {
					id = pts[j];
					v = points[id];
					if( f.vtxs.indexOf(v) >= 0 ) {
						polyTable.push( f );
						break;
					}
				}
			}
		}
		
		/**
		* @private
		*/
		public override function initFrame (session:RenderSession) :Boolean {
			var cam:Camera3d = session.camera;
			var cam_cgv:Matrix3d = camMatrix;
			if( super.initFrame(session) ) return true;
			
			if(bones) {
				var L:int = bones.length;
				var b:Bone;
				var f:Number = session.currentFrame;
				
				for(var i:int=0; i<L; i++) {
					b = bones[i];
					if(b.frameInit) b.transform.initFrame(f);
				}
			}
			return false;
		}
		
		/**
		* @private
		*/
		public override function initMesh (session:RenderSession) :Boolean {
			
			var cam:Camera3d = session.camera;
			var cgv:Matrix3d = camMatrix;
			
			if(super.initMesh(session)) return true; // todo... render bones in molehill
			
			if(bones == null) {
				return false;
			}
			
			var v:Vertex;
			var bgv:Matrix3d;
			var bn:Bone;
			var _p:Vector.<Vertex> = points;
			var _bp:Vector.<int>;
			
			var _bl:int = bones.length;
			var _w:Number = cam.t;	var _h:Number = cam.s;
			var x:Number;	var y:Number;	var z:Number;	var w1:Number;
			var restposx:Number;	var restposy:Number;	var restposz:Number;
			
			var gv:Matrix3d = transform.gv;
			
			var a:Number = gv.a;	var b:Number = gv.b;	var c:Number = gv.c;
			var e:Number = gv.e;	var f:Number = gv.f;	var g:Number = gv.g;
			var i:Number = gv.i;	var j:Number = gv.j;	var k:Number = gv.k;
			var m:Number = gv.m;	var n:Number = gv.n;	var o:Number = gv.o;
			var ptsL:int;
			var _j:int;
			var _i:int;
			
			var _l:int = bones.length;
			var wgt:Number;
			
			// copy points
			_l = _p.length;
			for( _i = 0; _i < _l; _i++) {
				v = _p[_i];
				
				v.wx = v.x;
				v.wy = v.y;
				v.wz = v.z;
			}
			
			// for bones
			for (_i=0; _i<_bl; _i++) 
			{
				bn = bones[_i];
				
				restposx = bn.restPosition.x;	restposy = bn.restPosition.y;	restposz = bn.restPosition.z;
				_bp = bn.points;
				ptsL = _bp.length;
				
				bgv = bn.transform.gv;
				a = bgv.a;	b = bgv.b;	c = bgv.c;
				e = bgv.e;	f = bgv.f;	g = bgv.g;
				i = bgv.i;	j = bgv.j;	k = bgv.k;
				m = bgv.m;	n = bgv.n;	o = bgv.o;
				
				if( bn.weights.length == ptsL ) {
					for(_j = 0; _j<ptsL; _j++) {
						v = _p[_bp[_j]];
						wgt = bn.weights[_j];
						x = v.wx-restposx;	y = v.wy-restposy;	z = v.wz-restposz;
						
						v.wx = ((a*x + e*y + i*z + m)-x) * wgt + x;
						v.wy = ((b*x + f*y + j*z + n)-y) * wgt + y;
						v.wz = ((c*x + g*y + k*z + o)-z) * wgt + z;
					}
				}else{
					// for bone points
					for(_j = 0; _j<ptsL; _j++) {
						v = _p[_bp[_j]];
						x = v.wx-restposx;	y = v.wy-restposy;	z = v.wz-restposz;
						v.wx = a*x + e*y + i*z + m;
						v.wy = b*x + f*y + j*z + n;
						v.wz = c*x + g*y + k*z + o;
					}
				}
			}
			
			// update polygon center and normals
			var bf:Vector.<Face> = polyTable;
			if(bf != null ) 
			{
				var L2:int = bf.length;
				var fc:Face;
				var ax:Number;	var ay:Number;	var az:Number;
				var x1:Number;	var y1:Number;	var z1:Number;
				var x2:Number;	var y2:Number;	var z2:Number;
				
				for(_i=0; _i<L2; _i++) 
				{
					fc = bf[_i];
					
					if( fc.vLen > 2 ) {
						
						fc.ax = (fc.a.wx + fc.b.wx + fc.c.wx ) / 3;
						fc.ay = (fc.a.wy + fc.b.wy + fc.c.wy ) / 3;
						fc.az = (fc.a.wz + fc.b.wz + fc.c.wz ) / 3;
						
						x1 = fc.b.wx-fc.a.wx;	
						y1 = fc.b.wy-fc.a.wy;	
						z1 = fc.b.wz-fc.a.wz;
						
						x2 = fc.c.wx-fc.a.wx;		
						y2 = fc.c.wy-fc.a.wy;		
						z2 = fc.c.wz-fc.a.wz;
						
						ax = y1 * z2 - z1 * y2;
						ay = z1 * x2 - x1 * z2;
						az = x1 * y2 - y1 * x2;
						
						x1 = -Math.sqrt(ax*ax + ay*ay + az*az);
						
						fc.normal.x = ax/x1;		
						fc.normal.y = ay/x1;
						fc.normal.z = az/x1;
						
					}else if( fc.vLen == 2 ) {
						fc.ax = (fc.a.wx + fc.b.wx ) / 2;
						fc.ay = (fc.a.wy + fc.b.wy ) / 2;
						fc.az = (fc.a.wz + fc.b.wz ) / 2;
					}
				}
			}
			
			
			
			a = cgv.a;	b = cgv.b;	c = cgv.c;
			e = cgv.e;	f = cgv.f;	g = cgv.g;
			i = cgv.i;	j = cgv.j;	k = cgv.k;
			m = cgv.m;	n = cgv.n;	o = cgv.o + cam._nearClipping;
			
			for(_i=0; _i<_l; _i++) {
				
				v = _p[_i];
				v.frameCounter1 = v.frameCounter2 = frameCounter;
				
				x = v.wx;	y = v.wy; 	z = v.wz;
				
				v.wy = b*x + f*y + j*z + n;
				v.wx = a*x + e*y + i*z + m;
				w1 = c*x + g*y + k*z + o;
				v.wz = w1;
				v.culled = (w1 < cam._nearClipping || w1 > cam._farClipping || v.wy > w1 || v.wy < -w1 || v.wx > w1 || v.wx < -w1);
				
				if(w1!=0) {
					v.sy = _h - v.wy/w1 * _h;
					v.sx = _w + v.wx/w1 * _w;
				}else{
					v.sy = _h - v.wy * _h;
					v.sx = _w + v.wx * _w;
				}
			}
					
			return false;
		}
	
	}
}