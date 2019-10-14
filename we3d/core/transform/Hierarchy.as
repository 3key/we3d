package we3d.core.transform
{
	import we3d.we3d;
	import we3d.core.transform.Transform3d;
	import we3d.math.Matrix3d;

	use namespace we3d;
	
	/**
	* The Hierarchy transform provides scale and parent properties
	*/
	public class Hierarchy extends Transform3d 
	{
		public function Hierarchy () {}
		
		public function setScale (sx:Number=0, sy:Number=0, sz:Number=0) :void {
			scaleX = sx;
			scaleY = sy;
			scaleZ = sz;
		}
		
		/**
		* Matrix with local transformation (position, rotation, scale)
		*/
		public var tgv:Matrix3d = new Matrix3d();
		
		/** 
		* The parent property can be set to a Transform3d <br/>
		* Use null to set the root as the parent </br>
		* 
		* NOTE: Parents have to be created before childs in the parent hierarchy. 
		* If this is not possible, cause of async loading etc. you have to sort the 
		* objectList of the scene with parents first or use scene.utils.sortHierarchy <br/><br/>
		* 
		* If a child is before it's parent in the objectList, then the object matrix of the parent <br/>
		* is not ready when processing the child (the matrix from the previous frame is taken) 
		*/
		public function get parent () :Transform3d {
			return _parent;		
		}
		public function set parent (o:Transform3d) :void {
			_parent = o;
		}
		
		/**
		* Get or set the transform
		*/
		public override function get transform () :Matrix3d {
			return tgv;
		}
		public override function set transform (tm:Matrix3d) :void {
			var m:Matrix3d = tgv;
			m.a = tm.a;	m.b = tm.b;	m.c = tm.c;
			m.e = tm.e;	m.f = tm.f;	m.g = tm.g;
			m.i = tm.i;	m.j = tm.j;	m.k = tm.k;
			m.m = tm.m;	m.n = tm.n;	m.o = tm.o;
			updateRotation(m);
		}
		
		/** 
		* @private
		*/
		public override function initFrame (f:Number) :void {
			
			var scx:Number = scaleX;
			var scy:Number = scaleY;
			var scz:Number = scaleZ;
			
			var t:Matrix3d = tgv;
			var rv:Matrix3d = gv;
			
			if(_parent != null) {
				
				if(_parent.frameCounter != frameCounter) _parent.initFrame(f);
				
				var ta:Number = t.a*scx;	var tb:Number = t.b*scx;	var tc:Number = t.c*scx;
				var te:Number = t.e*scy;	var tf:Number = t.f*scy;	var tg:Number = t.g*scy;
				var ti:Number = t.i*scz;	var tj:Number = t.j*scz;	var tk:Number = t.k*scz;
				var tm:Number = t.m;		var tn:Number = t.n;		var to:Number = t.o;
				
				var mat:Matrix3d = _parent.gv;
				
				rv.a = ta*mat.a + tb*mat.e + tc*mat.i;
				rv.b = ta*mat.b + tb*mat.f + tc*mat.j;
				rv.c = ta*mat.c + tb*mat.g + tc*mat.k;
					
				rv.e = te*mat.a + tf*mat.e + tg*mat.i;
				rv.f = te*mat.b + tf*mat.f + tg*mat.j;
				rv.g = te*mat.c + tf*mat.g + tg*mat.k;
					
				rv.i = ti*mat.a + tj*mat.e + tk*mat.i;
				rv.j = ti*mat.b + tj*mat.f + tk*mat.j;
				rv.k = ti*mat.c + tj*mat.g + tk*mat.k;
					
				rv.m = tm*mat.a + tn*mat.e + to*mat.i + mat.m;
				rv.n = tm*mat.b + tn*mat.f + to*mat.j + mat.n;
				rv.o = tm*mat.c + tn*mat.g + to*mat.k + mat.o;
			}
			else {
				rv.a = t.a*scx;	rv.b = t.b*scx;	rv.c = t.c*scx;
				rv.e = t.e*scy;	rv.f = t.f*scy;	rv.g = t.g*scy;
				rv.i = t.i*scz;	rv.j = t.j*scz;	rv.k = t.k*scz;
				rv.m = t.m;		rv.n = t.n;		rv.o = t.o;
			}
		}
		
		public override function clone ():Transform3d {
			var r:Hierarchy = new Hierarchy();
			r.transform = transform;
			r.parent = parent;
			return Transform3d(r);
		}
	
	}
}
