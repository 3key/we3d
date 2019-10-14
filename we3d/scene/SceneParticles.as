package we3d.scene 
{
	import flash.utils.Dictionary;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.Object3d;
	import we3d.core.culling.BoxCulling;
	import we3d.core.transform.Transform3d;
	import we3d.layer.Layer;
	import we3d.material.Surface;
	import we3d.math.Matrix3d;
	import we3d.math.Vector3d;
	import we3d.mesh.Face;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;
	import we3d.scene.dynamics.Particle;
	import we3d.scene.dynamics.ParticleBasicEmitter;
	import we3d.scene.dynamics.ParticleDotRenderer;
	import we3d.scene.dynamics.ParticleEmitter;
	import we3d.scene.dynamics.ParticleRenderer;

	use namespace we3d;
		
	/**
	* 3D Particle object, with or without polygons
	*/
	public class SceneParticles extends SceneObject
	{
		public function SceneParticles (rend:ParticleRenderer=null, emt:ParticleEmitter=null) {
			emitter = emt ? emt : new ParticleBasicEmitter();
			renderer = rend ? rend : new ParticleDotRenderer();
		}
		
		private var _emitter:ParticleEmitter;
		public function get emitter () :ParticleEmitter { return _emitter; }
		public function set emitter (emt:ParticleEmitter) :void { 
			_emitter = emt;
			_emitter.so = this;
		}
		
		public var renderer:ParticleRenderer;
		
		public var velocity_x:Number=0;
		public var velocity_y:Number=0;
		public var velocity_z:Number=0;
		
		private var lastPos_x:Number=0;
		private var lastPos_y:Number=0;
		private var lastPos_z:Number=0;
		
		public override function initFrame (session:RenderSession) :Boolean 
		{
			frameCounter = transform.frameCounter = Transform3d.FCounter;
			
			if(frameInit) transform.initFrame(session.currentFrame);
			
			var x:Number=transform.gv.m;
			var y:Number=transform.gv.n;
			var z:Number=transform.gv.o;
			
			velocity_x = x - lastPos_x;
			velocity_y = y - lastPos_y;
			velocity_z = z - lastPos_z;
			
			lastPos_x = x;
			lastPos_y = y;
			lastPos_z = z;
			
			culled = objectCuller.cull(this, session.camera);
			
			if(renderer) 
			{
				if(layer) {
					var lyr:Layer = layer[session.viewId] || null;
					if(lyr != null) {
						lyr.updateSession(session);
					}
				}else{
					// set default layer
					if(session._graphics != session.defaultSession__graphics) session.useDefaultSession();
				}
				
				if(emitter.points != null) 
				{
					var _p:Vector.<Particle> = emitter.points;
					var L:int = _p.length;
					
					if(L>0) 
					{
						var v:Particle;
						var cam:Camera3d = session.camera;
						var cgv:Matrix3d = cam.cgv;
						var _nearClipping:Number = cam._nearClipping;
						var _farClipping:Number = cam._farClipping;
						var ofc:int = frameCounter;
						var _w:Number = cam.t;	var _h:Number = cam.s;
						var a:Number = cgv.a;	var b:Number = cgv.b;	var c:Number = cgv.c;
						var e:Number = cgv.e;	var f:Number = cgv.f;	var g:Number = cgv.g;
						var i:Number = cgv.i;	var j:Number = cgv.j;	var k:Number = cgv.k;
						var m:Number = cgv.m;	var n:Number = cgv.n;	var o:Number = cgv.o + cam._nearClipping;
						var _i:int;
						var out:Boolean = true;
						
						if(cam.ortho) 
						{
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
								
								if( v.sx < 0 || v.sy < 0 || v.sx > cam._width || v.sy > cam._height ) {
									continue;
								}
								v.frameCounter2 = ofc;
								out = false;
							}
						}
						else
						{
							for(_i=0; _i<L; _i++) {
								v = _p[_i];
								x = v.x;	y = v.y; 	z = v.z;
								v.wz = c*x + g*y + k*z + o;
								v.wy = b*x + f*y + j*z + n;
								v.wx = a*x + e*y + i*z + m;
								if(v.wz < _nearClipping || v.wz > _farClipping || v.wy < -v.wz || v.wy > v.wz || v.wx < -v.wz || v.wx > v.wz) {
									continue;
								}
								
								out = false;
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
				if(!out) renderer.render(_emitter, session);
			}
			
			return out && culled;
		}
		
		public override function clone () :SceneObject {
			var r:SceneParticles = new SceneParticles( renderer.clone(), emitter.clone() );
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