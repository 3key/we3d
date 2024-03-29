package we3d.core.transform 
{
	import we3d.we3d;
	import we3d.math.Matrix3d;
	import we3d.math.Vector3d;

	use namespace we3d;
	
	/**
	* Transform3d is the base and also the default transform object. It provides only position and rotation features.
	*/
	public class Transform3d 
	{
		public function Transform3d () {}
		
		/**
		* @private
		*/
		public var gv:Matrix3d = new Matrix3d();
		/**
		* @private
		*/
		we3d var _parent:Transform3d = null;
		/**
		* @private
		*/
		we3d static var FCounter:int=0;
		
		we3d var frameCounter:int=0;
		
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var scaleZ:Number = 1;
		
		private var _rotationX:Number=0;
		private var _rotationY:Number=0;
		private var _rotationZ:Number=0;
		
		/**
		* Get or set the transform
		*/
		public function get transform () :Matrix3d {
			return gv;
		}
		public function set transform (t:Matrix3d) :void {
			var m:Matrix3d = gv;
			m.a = t.a;	m.b = t.b;	m.c = t.c;
			m.e = t.e;	m.f = t.f;	m.g = t.g;
			m.i = t.i;	m.j = t.j;	m.k = t.k;
			m.m = t.m;	m.n = t.n;	m.o = t.o;
			updateRotation(m);
		}
		
		/**
		* Position on X axis
		*/
		public function get x () :Number {
			return transform.m;
		}
		public function set x (v:Number) :void {
			transform.m = v;
		}
		
		/**
		* Position on Y axis
		*/
		public function get y () :Number {
			return transform.n;
		}
		public function set y (v:Number) :void {
			transform.n = v;
		}
		
		/**
		* Position on Z axis
		*/
		public function get z () :Number {
			return transform.o;
		}
		public function set z (v:Number) :void {
			transform.o = v;
		}
		
		/**
		* World Position on X axis
		*/
		public function get worldX () :Number {
			return gv.m;
		}
		
		/**
		* World Position on Y axis
		*/
		public function get worldY () :Number {
			return gv.n;
		}
		
		/**
		* World Position on Z axis
		*/
		public function get worldZ () :Number {
			return gv.o;
		}
		
		/**
		* Set position on all three axis at once
		* @param	ax
		* @param	ay
		* @param	az
		*/
		public function setPosition (ax:Number=0, ay:Number=0, az:Number=0) :void {
			var tr:Matrix3d = transform;
			tr.m = ax;
			tr.n = ay;
			tr.o = az;
		}
		
		public function getPosition () :Vector3d {
			var tr:Matrix3d = transform;
			return new Vector3d(tr.m, tr.n, tr.o);
		}
		
		/**
		* Move the location
		* @param	axis unit length vector
		* @param	val offset to move on the axis
		*/
		public function moveOnAxis (axis:Vector3d, val:Number) :void {
			var tr:Matrix3d = transform;
			tr.m += axis.x*val;
			tr.n += axis.y*val;
			tr.o += axis.z*val;
		}
		
		/**
		* Rotation X
		*/
		public function get rotationX () :Number {
			return _rotationX;
		}
		public function set rotationX (v:Number) :void {
			_rotationX = v;
			initAxis();
		}
		
		/**
		* Rotation Y
		*/
		public function get rotationY () :Number {
			return _rotationY;
		}
		public function set rotationY (v:Number) :void {
			_rotationY = v;
			initAxis();
		}
		
		/**
		* Rotation Z
		*/
		public function get rotationZ () :Number {
			return _rotationZ;
		}
		public function set rotationZ (v:Number) :void {
			_rotationZ = v;
			initAxis();
		}
		
		/**
		* Set the rotation on all three axis at once. This is much faster then calling three setters for XY and Z rotation.
		* @param	ax
		* @param	ay
		* @param	az
		*/
		public function setRotation (ax:Number=0, ay:Number=0, az:Number=0) :void {
			_rotationX = ax;
			_rotationY = ay;
			_rotationZ = az;
			initAxis();
		}
		
		/**
		* Rotates the transform on an axis.
		* @param	axis unit length vector
		* @param	r angle in radian
		*/
		public function rotateOnAxis (axis:Vector3d, r:Number) :void {
			
			if(Math.abs(r) < 0.0005) return;
			
			var x:Number = axis.x;
			var y:Number = axis.y;
			var z:Number = axis.z;
			
			var _m:Number = Math.sqrt(x*x+y*y+z*z);
			x /= _m; y /= _m; z /= _m;
			
			var s:Number = Math.sin(r);
			var _c:Number = Math.cos(r);
			var u:Number = 1-_c;
			var sx:Number = s*x;	var sy:Number = s*y;	var sz:Number = s*z;
			var xy:Number = y*x*u;	var zy:Number = y*z*u;	var xz:Number = z*x*u;
			
			var mata:Number = x*x* u + _c;	var matb:Number = xy + sz;		var matc:Number = xz - sy;
			var mate:Number = xy - sz;		var matf:Number = y*y* u + _c;	var matg:Number = zy + sx;
			var mati:Number = xz + sy;		var matj:Number = zy - sx;		var matk:Number = z*z* u + _c;
			
			var tr:Matrix3d = transform;
			var ta:Number = tr.a;	var tb:Number = tr.b;	var tc:Number = tr.c;
			var te:Number = tr.e;	var tf:Number = tr.f;	var tg:Number = tr.g;
			var ti:Number = tr.i;	var tj:Number = tr.j;	var tk:Number = tr.k;
			
			tr.a = ta*mata + tb*mate + tc*mati;
			tr.b = ta*matb + tb*matf + tc*matj;
			tr.c = ta*matc + tb*matg + tc*matk;
				
			tr.e = te*mata + tf*mate + tg*mati;
			tr.f = te*matb + tf*matf + tg*matj;
			tr.g = te*matc + tf*matg + tg*matk;
				
			tr.i = ti*mata + tj*mate + tk*mati;
			tr.j = ti*matb + tj*matf + tk*matj;
			tr.k = ti*matc + tj*matg + tk*matk;
			
			updateRotation(tr);
		}
		
		/**
		* @private
		*/
		protected function updateRotation (r:Matrix3d) :void {
			var tx:Number = Math.asin(r.j);
			_rotationY = 0;
			_rotationX = -tx;
			if(tx < Math.PI/2) {
				if(tx > -Math.PI/2) {
					_rotationZ = -Math.atan2(-r.b, r.f);
					_rotationY = -Math.atan2(-r.i, r.k);
				}else{
					_rotationZ = Math.atan2(r.b, r.a);
				}
			}else{
				_rotationZ = -Math.atan2(r.c, r.a);
			}
		}
		
		/**
		* @private
		*/
		public function initAxis () :void {
			
			var ax:Number = -_rotationX;
			var ay:Number =  _rotationY;
			var az:Number = -_rotationZ;
			
			var cx:Number = Math.cos(ax);
			var sx:Number = Math.sin(ax);
			var cy:Number = Math.cos(ay);
			var sy:Number = Math.sin(ay);
			var cz:Number = Math.cos(az);
			var sz:Number = Math.sin(az);
			
			var tr:Matrix3d = transform;
			tr.a = cz*cy-sz*-sx*sy;
			tr.b = -sz*cx;
			tr.c = cz*-sy-sz*-sx*cy;
			
			tr.e = sz*cy+cz*-sx*sy;
			tr.f = cz*cx;
			tr.g = sz*-sy+cz*-sx*cy;
			
			tr.i = cx*sy;
			tr.j = sx;
			tr.k = cx*cy;
		}
		
		/**
		* Local x axis
		*/
		public function get xAxis () :Vector3d {
			var tr:Matrix3d = transform;
			return new Vector3d(tr.a, tr.b, tr.c);
		}
		
		/**
		* Local y axis
		*/
		public function get yAxis () :Vector3d {	
			var tr:Matrix3d = transform;
			return new Vector3d(tr.e, tr.f, tr.g);
		}
		
		/**
		* Local z axis
		*/
		public function get zAxis () :Vector3d {
			var tr:Matrix3d = transform;
			return new Vector3d(tr.i, tr.j, tr.k);
		}
		
		public function set zAxis (v:Vector3d) :void {
			lookAtPoint( x + v.x, y + v.y, z + v.z);
		}
		
		public function set yAxis (v:Vector3d) :void {
			lookAtPoint( x + v.x, y + v.y, z + v.z);
			
			var tr:Matrix3d = transform;
			var tx:Number = tr.e;
			var ty:Number = tr.f;
			var tz:Number = tr.g;
			tr.e = tr.i;	tr.f = tr.j;	tr.g = tr.k;
			tr.i = -tx;		tr.j = -ty;		tr.k = -tz;
		}
		
		public function set xAxis (v:Vector3d) :void {
			lookAtPoint( x + v.x, y + v.y, z + v.z);
			
			var tr:Matrix3d = transform;
			var tx:Number = tr.a;
			var ty:Number = tr.b;
			var tz:Number = tr.c;
			tr.a = tr.i;	tr.b = tr.j;	tr.c = tr.k;
			tr.i = -tx;		tr.j = -ty;		tr.k = -tz;
		}
		
		public function lookAtPoint (px:Number, py:Number, pz:Number) :void {
			
			var zAxisx:Number = px - gv.m;
			var zAxisy:Number = py - gv.n;
			var zAxisz:Number = pz - gv.o;
			
			var mag:Number = Math.sqrt(zAxisx*zAxisx + zAxisy*zAxisy + zAxisz*zAxisz);
			if(mag > 0) {
				zAxisx/=mag;
				zAxisy/=mag;
				zAxisz/=mag;
			}else{
				zAxisx = 0;
				zAxisy = 0;
				zAxisz = 1;
			}
			
			var yAxisx:Number = 0;
			var yAxisy:Number = 1;
			var yAxisz:Number = 0;
			
			var fDot:Number = yAxisx*zAxisx + yAxisy*zAxisy + yAxisz*zAxisz;
			yAxisx = yAxisx - (fDot*zAxisx);
			yAxisy = yAxisy - (fDot*zAxisy);
			yAxisz = yAxisz - (fDot*zAxisz);
			
			mag = Math.sqrt(yAxisx*yAxisx + yAxisy*yAxisy + yAxisz*yAxisz);	
			yAxisx/=mag;
			yAxisy/=mag;
			yAxisz/=mag;
			
			var xAxisx:Number = yAxisy*zAxisz-yAxisz*zAxisy;
			var xAxisy:Number = yAxisz*zAxisx-yAxisx*zAxisz;
			var xAxisz:Number = yAxisx*zAxisy-yAxisy*zAxisx;
			
			mag = Math.sqrt(xAxisx*xAxisx + xAxisy*xAxisy + xAxisz*xAxisz);	
			xAxisx/=mag;
			xAxisy/=mag;
			xAxisz/=mag;
			
			var tr:Matrix3d = transform;
			
			tr.a = xAxisx;	tr.b = xAxisy; tr.c = xAxisz;
			tr.e = yAxisx;	tr.f = yAxisy; tr.g = yAxisz;
			tr.i = zAxisx;	tr.j = zAxisy; tr.k = zAxisz;
			
			updateRotation(tr);
		}
		
		/**
		* World x axis
		*/
		public function get wxAxis () :Vector3d {
			return new Vector3d(gv.a, gv.b, gv.c);
		}
		
		/**
		* World y axis
		*/
		public function get wyAxis () :Vector3d {	
			return new Vector3d(gv.e, gv.f, gv.g);
		}
		
		/**
		* World z axis
		*/
		public function get wzAxis () :Vector3d {
			return new Vector3d(gv.i, gv.j, gv.k);
		}
		
		/**
		* Reset the position and rotation to zero
		*/
		public function reset () :void {
			var tr:Matrix3d = transform;
			tr.initialize();
			_rotationX = _rotationY = _rotationZ = 0;
		}
		
		/**
		* @private
		*/
		public function initFrame (f:Number) :void {}
		
		/**
		* Returns the position in world coordinate as a new Vector
		*/
		public function get worldPosition () :Vector3d {
			return new Vector3d(gv.m, gv.n, gv.o);
		}
		
		public function get worldRotation () :Vector3d {
			
			var rv:Vector3d = new Vector3d();
			var r:Matrix3d = gv;
			
			var tx:Number = Math.asin(r.j);
			rv.y = 0;
			rv.x = -tx;
			if(tx < Math.PI/2) {
				if(tx > -Math.PI/2) {
					rv.z = -Math.atan2(-r.b, r.f);
					rv.y = -Math.atan2(-r.i, r.k);
				}else{
					rv.z = Math.atan2(r.b, r.a);
				}
			}else{
				rv.z = -Math.atan2(r.c, r.a);
			}
			return rv;
		}
		
		public function addChild (c:Transform3d) :void {
			c._parent = this;
		}
		public function removeChild (c:Transform3d) :Boolean {
			c._parent = null;
			return false; 
		}
	
		public function clone () :Transform3d {
			var r:Transform3d = new Transform3d();
			r.transform = transform;
			return r;
		}
		
	}
}