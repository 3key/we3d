package we3d.scene 
{
	import flash.display.DisplayObject;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.core.transform.Transform3d;
	import we3d.math.Matrix3d;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* 3D Sprite using front projection (2D movieclips).
	*/
	public class SceneSprite extends SceneObject
	{
		public function SceneSprite() {}
		
		/**
		* The zdepth of the Sprite is assigned during rendering but sprites arent sorted by the engine, this value can be used to sort the Sprites in the scene
		*/
		public var zdepth:Number=0;
		/**
		* If false, the sprite will not be scaled
		*/
		public var depthScale:Boolean=true;
		
		private var _clip:DisplayObject;
		private var _clipHeight:Number=0;
		
		/**
		* The Sprite to transform, the clip can be added anywere the stage or just off screen, only the transformation of the sprite is modified during rendering
		*/
		public function set clip (c:DisplayObject) :void {
			_clip = c;
			if(_clipHeight == 0)
				clipHeight = c.height;
		}
		public function get clip () :DisplayObject {
			return _clip;
		}
		
		/**
		* The height of the sprite in 3d units
		*/
		public function set clipHeight (h:Number) :void {
			_clipHeight = h;
		}
		public function get clipHeight () :Number {
			return _clipHeight;
		}
		/**
		* @private
		*/
		public override function initFrame (session:RenderSession) :Boolean 
		{
			var c:Camera3d = session.camera;
			
			frameCounter = transform.frameCounter = Transform3d.FCounter;
			if(frameInit) transform.initFrame(session.currentFrame);
			
			var m:Matrix3d = camMatrix;
			m.concatM4(transform.gv, c.cgv, m);
			
			
			var w:Number = m.o;
			var x1:Number;
			var y1:Number;
			
			zdepth = w;
			
			if(w > 0) {
				y1 = c.s - m.n/w*c.s;
				x1 = c.t + m.m/w*c.t;
			}else{
				_clip.visible = false;
				return true;
			}
			
			_clip.visible = true;
			_clip.x = x1;
			_clip.y = y1;
			
			var x:Number;
			var y:Number;
			
			if(depthScale) {
				var mt:Matrix3d = c.transform.gv;
			
				x = mt.e * _clipHeight;
				y = mt.f * _clipHeight;
				var z:Number = mt.g * _clipHeight;
				
				w = m.c*x + m.g*y + m.k*z + m.o;
				
				var y2:Number;
				var x2:Number;
				
				if(w > 0) {
					y2 = c.s - (m.b*x + m.f*y + m.j*z + m.n)/w*c.s;
					x2 = c.t + (m.a*x + m.e*y + m.i*z + m.m)/w*c.t;
				}else{
					y2 = c.s - (m.b*x + m.f*y + m.j*z + m.n)*c.s;
					x2 = c.t + (m.a*x + m.e*y + m.i*z + m.m)*c.t;
				}
				
				x = x2-x1;
				y = y2-y1;
				
				_clip.height = Math.sqrt(x*x + y*y);
				_clip.scaleX = _clip.scaleY;
			}
			
			x = _clip.width/2;
			y = _clip.height/2;
			
			if(x1 < -x || x1 > c._width + x || y1 < -y || y1 > c._height + y) {
				_clip.visible = false;
			}
			
			return true;
		}
	}
}