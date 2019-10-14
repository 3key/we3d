package we3d.scene 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.culling.BoxCulling;
	import we3d.core.transform.Transform3d;
	import we3d.layer.Layer;
	import we3d.math.Matrix3d;
	import we3d.math.Vector3d;
	import we3d.renderer.RenderSession;
	
	use namespace we3d;
	
	/**
	* Flash 3D Sprite using flash 10's 3D renderer. Requires Flash Player 10.1. The SceneSpriteF10 renders 3D movieclips with full interactivity. The movieclips have to be linked with the library in order to be instanciated if they get rendered.
	* The movieclips are added to the nativeContainer of a Layer. Sprites are always rendered over polygons but it is possible to change the depth of the native container to render sprites behind all polygons.
	* The sprites in the nativeContainer are sorted by z depth. Sprites work well with multiple views in a project.
	*/
	public class SceneSpriteF10 extends SceneObject
	{
		public function SceneSpriteF10 () {
			BoxCulling(objectCuller).rectMode = true;
			v[15] = 1;
		}
		
		we3d var _clip:DisplayObject;
		private var def:Object;
		private var bmp:BitmapData;
		private var viewClips:Dictionary = new Dictionary(true);
		private var clipUpdate:Boolean=false;
		
		public function get viewSprites () :Dictionary {
			return viewClips;
		}
		
		/**
		* The Sprite to transform
		*/
		public function get clip () :DisplayObject {	return _clip;	}
		public function set clip (c:DisplayObject) :void 
		{
			if( _clip != null) {
				for(var i:String in viewClips) {
					if(viewClips[i].clip.parent)
						viewClips[i].clip.parent.removeChild( viewClips[i].clip );
				}
				def = null;
				bmp = null;
				clipUpdate = true;
			}
			
			if( c ) {
				_clip = c;
				
				var w2:Number= c.width/2;
				var h2:Number= c.height/2;
				
				if(c is Bitmap) {
					bmp = Bitmap(c).bitmapData.clone();
				}else{
					try{
						def = getDefinitionByName( getQualifiedClassName(c) );
					}catch(e:Error){
						def=null;
					}
					bmp = null;
				}
				
				objectCuller.reset();
				objectCuller.testPoint(-w2, -h2, 0);
				objectCuller.testPoint(w2, h2, 0);
			}
		}
		
		private var tr:Matrix3d = new Matrix3d();
		private var rt:Matrix3d = new Matrix3d();
		private var v:Vector.<Number> = new Vector.<Number>(16, true);
		
		public override function initFrame (session:RenderSession) :Boolean 
		{
			if(_clip == null) return true;
			frameCounter = transform.frameCounter = Transform3d.FCounter;
			if(frameInit) transform.initFrame(session.currentFrame);
			
			culled = objectCuller.cull(this, session.camera);
			if(culled) {
				var o:Object = viewClips[session.viewId];
				if(o!=null) {
					var clp:DisplayObject = o.clip;
					if(clp) {
						if( session.nativeContainer.contains(clp) ) {
							session.nativeContainer.removeChild( clp );
							if(session.sortSprites) {
								var id:int = session.sprites.indexOf(o);
								if(id >= 0) {
									session.sprites.splice(id,1);
								}
							}
						}
					}
				}
			}
			return culled;
		}
		
		public override function initMesh (session:RenderSession) :Boolean 
		{
			if(_clip == null) return true;
			
			var c:Camera3d = session.camera;
			if(c.ortho) {
				 //render wireframe rectangle...
				return true;
			}
			
			var clp:DisplayObject;
			var o:Object;
			var id:int;
			
			if( clipUpdate ) {
				if(session.sprites) {
					id = session.sprites.indexOf(viewClips[session.viewId]);
					if(id >= 0) {
						session.sprites.splice(id,1);
					}
				}
				delete viewClips[session.viewId];
				clipUpdate = false;
			}else{
				o = viewClips[session.viewId];
			}
			
			if( o == null ) {
				if( bmp == null) {
					if(def == null) {
						clp = _clip;
					}else{
						clp = new def();
					}
				}else{
					clp = new Sprite();
					var b:Bitmap=new Bitmap(bmp);
					b.x = -b.width * .5;
					b.y = -b.height * .5;
					Sprite(clp).addChild( b );
				}
				
				o = { clip: clp, zdepth: 0, sp: this, idm: new (Class(getClass("flash.geom::Matrix3D"))) };
				viewClips[session.viewId] = o;
				
			}else{
				o = viewClips[session.viewId];
				clp = o.clip;
			}
			
			var idm:* = o.idm;
			
			if( !session.nativeContainer.contains(clp) ) {
				session.nativeContainer.addChild( clp );
				if(session.sortSprites) session.sprites.push(o);
			}
			
			tr.assign( transform.gv );
			tr.e = -tr.e;	tr.f = -tr.f;	tr.g = -tr.g;
			
			rt.concatM4( tr, Camera3d.ct, rt );
			
			v[0]  = rt.a;	v[1]  = -rt.b;	v[2]  = rt.c;
			v[4]  = rt.e;	v[5]  = -rt.f;	v[6]  = rt.g;
			v[8]  = rt.i;	v[9]  = -rt.j;	v[10] = rt.k;
			v[12] = rt.m + c.t;	v[13] = -(rt.n - c.s);  v[14] = rt.o - c._focalLength;
			
			o.zdepth = v[14];
			
			idm.rawData = v;
			clp.transform.matrix3D = idm;
			
			return true;
		}
		
		public override function clone () :SceneObject {
			var r:SceneSpriteF10 = new SceneSpriteF10();
			r.objectCuller = objectCuller.clone();
			r.setTransform( transform.clone() );
			r.copyPolygons(polygons);
			r.clip = clip;
			if(shared) {
				for(var id:String in shared) {
					r.shared[id] = shared[id];
				}
			}
			return r;
		}
		
	}
}