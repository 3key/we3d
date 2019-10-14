package we3d.math 
{
	import we3d.math.Vector3d;
	import we3d.mesh.Vertex;
	
	public class Matrix3d
	{
		public function  Matrix3d () {}
		
		public var a:Number=1;	public var b:Number=0;	public var c:Number=0;
		public var e:Number=0;	public var f:Number=1;	public var g:Number=0;
		public var i:Number=0;	public var j:Number=0;	public var k:Number=1;
		public var m:Number=0;	public var n:Number=0;	public var o:Number=0;
		
		public function initialize () :void {
			a = f = k = 1;
			b = c = e = g = i = j = m = n = o = 0;
		}
		
		public function concatM4 (t:Matrix3d, mat:Matrix3d, rv:Matrix3d) :void {
			
			rv.a = t.a*mat.a + t.b*mat.e + t.c*mat.i;
			rv.b = t.a*mat.b + t.b*mat.f + t.c*mat.j;
			rv.c = t.a*mat.c + t.b*mat.g + t.c*mat.k;
				
			rv.e = t.e*mat.a + t.f*mat.e + t.g*mat.i;
			rv.f = t.e*mat.b + t.f*mat.f + t.g*mat.j;
			rv.g = t.e*mat.c + t.f*mat.g + t.g*mat.k;
				
			rv.i = t.i*mat.a + t.j*mat.e + t.k*mat.i;
			rv.j = t.i*mat.b + t.j*mat.f + t.k*mat.j;
			rv.k = t.i*mat.c + t.j*mat.g + t.k*mat.k;
				
			rv.m = t.m*mat.a + t.n*mat.e + t.o*mat.i + mat.m;
			rv.n = t.m*mat.b + t.n*mat.f + t.o*mat.j + mat.n;
			rv.o = t.m*mat.c + t.n*mat.g + t.o*mat.k + mat.o;
		}
		public function vertexMul (v:Vertex, zv:Vertex) :void {
			var x:Number = v.x;
			var y:Number = v.y;
			var z:Number = v.z;
			zv.x = a*x + e*y + i*z + m;
			zv.y = b*x + f*y + j*z + n;
			zv.z = c*x + g*y + k*z + o;
		}
		public function vectorMul (v:Vector3d, zv:Vector3d) :void {
			var x:Number = v.x;
			var y:Number = v.y;
			var z:Number = v.z;
			zv.x = a*x + e*y + i*z + m;
			zv.y = b*x + f*y + j*z + n;
			zv.z = c*x + g*y + k*z + o;
		}
		
		public function rotateVector (v:Vector3d, zv:Vector3d) :void {
			var x:Number = v.x;
			var y:Number = v.y;
			var z:Number = v.z;
			zv.x = a*x + e*y + i*z;
			zv.y = b*x + f*y + j*z;
			zv.z = c*x + g*y + k*z;
		}
		
		public function transpose (from:Matrix3d) :void {
			a = from.a;
			b = from.e;
			c = from.i;
			
			e = from.b;
			f = from.f;
			g = from.j;
			
			i = from.c;
			j = from.g;
			k = from.k;
			
			m = -(from.m * from.a + from.n * from.b + from.o * from.c);
			n = -(from.m * from.e + from.n * from.f + from.o * from.g);
			o = -(from.m * from.i + from.n * from.j + from.o * from.k);
		}
		
		public function clone () :Matrix3d {
			
			var r:Matrix3d = new Matrix3d();
			r.a = a;
			r.b = b;
			r.c = c;
			
			r.e = e;
			r.f = f;
			r.g = g;
			
			r.i = i;
			r.j = j;
			r.k = k;
			
			r.m = m;
			r.n = n;
			r.o = o;
			
			return r;
		}
		
		public function getInverse (outMatrix:Matrix3d,d:Number=0,h:Number=0,l:Number=0,p:Number=1) :Boolean {
			
			var M0 :Number=a;	var M1 :Number=b;	var M2 :Number=c;	var M3 :Number=d;	
			var M4 :Number=e;	var M5 :Number=f;	var M6 :Number=g;	var M7 :Number=h;
			var M8 :Number=i;	var M9 :Number=j;	var M10:Number=k;	var M11:Number=l;
			var M12:Number=m;	var M13:Number=n;	var M14:Number=o;	var M15:Number=p;
			
			var d:Number = (M0 * M5 - M1 * M4) * (M10 * M15 - M11 * M14)	- (M0 * M6 - M2 * M4) * (M9 * M15 - M11 * M13)
					+ (M0 * M7 - M3 * M4) * (M9 * M14 - M10 * M13)	+ (M1 * M6 - M2 * M5) * (M8 * M15 - M11 * M12)
					- (M1 * M7 - M3 * M5) * (M8 * M14 - M10 * M12)	+ (M2 * M7 - M3 * M6) * (M8 * M13 - M9 * M12);
			
			if (d == 0.0)
			{
				return false;
			}
	
			d = 1.0 / d;	
	
			outMatrix.a = d * (M5 * (M10 * M15 - M11 * M14) + M6 * (M11 * M13 - M9 * M15) + M7 * (M9 * M14 - M10 * M13));
			outMatrix.b = d * (M9 * (M2 * M15 - M3 * M14) + M10 * (M3 * M13 - M1 * M15) + M11 * (M1 * M14 - M2 * M13));
			outMatrix.c = d * (M13 * (M2 * M7 - M3 * M6) + M14 * (M3 * M5 - M1 * M7) + M15 * (M1 * M6 - M2 * M5));
			//outMatrix.d = d * (M1 * (M7 * M10 - M6 * M11) + M2 * (M5 * M11 - M7 * M9) + M3 * (M6 * M9 - M5 * M10));
			outMatrix.e = d * (M6 * (M8 * M15 - M11 * M12) + M7 * (M10 * M12 - M8 * M14) + M4 * (M11 * M14 - M10 * M15));
			outMatrix.f = d * (M10 * (M0 * M15 - M3 * M12) + M11 * (M2 * M12 - M0 * M14) + M8 * (M3 * M14 - M2 * M15));
			outMatrix.g = d * (M14 * (M0 * M7 - M3 * M4) + M15 * (M2 * M4 - M0 * M6) + M12 * (M3 * M6 - M2 * M7));
			//outMatrix.h = d * (M2 * (M7 * M8 - M4 * M11) + M3 * (M4 * M10 - M6 * M8) + M0 * (M6 * M11 - M7 * M10));
			outMatrix.i = d * (M7 * (M8 * M13 - M9 * M12) + M4 * (M9 * M15 - M11 * M13) + M5 * (M11 * M12 - M8 * M15));
			outMatrix.j = d * (M11 * (M0 * M13 - M1 * M12) + M8 * (M1 * M15 - M3 * M13) + M9 * (M3 * M12 - M0 * M15));
			outMatrix.k = d * (M15 * (M0 * M5 - M1 * M4) + M12 * (M1 * M7 - M3 * M5) + M13 * (M3 * M4 - M0 * M7));
			//outMatrix.l = d * (M3 * (M5 * M8 - M4 * M9) + M0 * (M7 * M9 - M5 * M11) + M1 * (M4 * M11 - M7 * M8));
			outMatrix.m = d * (M4 * (M10 * M13 - M9 * M14) + M5 * (M8 * M14 - M10 * M12) + M6 * (M9 * M12 - M8 * M13));
			outMatrix.n = d * (M8 * (M2 * M13 - M1 * M14) + M9 * (M0 * M14 - M2 * M12) + M10 * (M1 * M12 - M0 * M13));
			outMatrix.o = d * (M12 * (M2 * M5 - M1 * M6) + M13 * (M0 * M6 - M2 * M4) + M14 * (M1 * M4 - M0 * M5));
			//outMatrix.p = d * (M0 * (M5 * M10 - M6 * M9) + M1 * (M6 * M8 - M4 * M10) + M2 * (M4 * M9 - M5 * M8));
			return true;
		}
		
		public function toString () :String {
			return 	"[ " + getNumberAsString(a) + "\t " + getNumberAsString(b) + "\t " + getNumberAsString(c) + " ]\n"+
					"[ " + getNumberAsString(e) + "\t " + getNumberAsString(f) + "\t " + getNumberAsString(g) + " ]\n"+
					"[ " + getNumberAsString(i) + "\t " + getNumberAsString(j) + "\t " + getNumberAsString(k) + " ]\n"+
					"[ " + getNumberAsString(m) + "\t " + getNumberAsString(n) + "\t " + getNumberAsString(o) + " ]\n";
		}
		
		public static function getNumberAsString(val:Number) :String {
			var y:Number = Math.round(val*100)/100;
			var min:String;
			var str:String;
			var dp:Number;
			
			if(y<0) {
				str = (-y).toString();
				dp = (Math.round((-y-int(-y))*100)/100).toString().length-2;
				min = "-";
			}else{
				min = "";
				dp = (Math.round((y-int(y))*100)/100).toString().length-2;
				str = y.toString();
			}
			if(dp <= 0) {
				str += ".00";
			}else if(dp == 1) {
				str += "0";
			}
			
			if(y >= 0) {
				if(y < 10) {
					str = "000" + str;
				}else if(y<100) {
					str = "00" + str;
				}else if(y<1000) {
					str = "0" + str;
				}
			}else{
				if(y>-10) {
					str = "00" + str;
				}else if(y>-100) { 
					str = "0" + str;
				}
			}
			return min+str;
		}
		
		public function assign (mat:Matrix3d) :void {
			a = mat.a;	b = mat.b;	c = mat.c;
			e = mat.e;	f = mat.f;	g = mat.g;
			i = mat.i;	j = mat.j;	k = mat.k;
			m = mat.m;	n = mat.n;	o = mat.o;
		}
		
		/*
		public function rotateX (rad:Number) :void {
			var _c:Number = Math.cos(rad);
			var _s:Number = Math.sin(rad);
			initialize();
			f = _c;
			g = -_s;
			j = _s;
			k = _c;
		}
		public function rotateY (rad:Number) :void {
			var _c:Number = Math.cos(rad);
			var _s:Number = Math.sin(rad);
			initialize();
			a = _c;
			c = -_s;
			i = _s;
			k = _c;
		}
		public function rotateZ (rad:Number) :void {
			var _c:Number = Math.cos(rad);
			var _s:Number = Math.sin(rad);
			initialize();
			a = _c;
			b = -_s;
			e = _s;
			f = _c;
		}
		*/
		
		public function scale( x:Number, y:Number, z:Number) :void {
			a *= x;	b *= x;	c *= x;
			e *= y;	f *= y;	g *= y;
			i *= z;	j *= z;	k *= z;
		}
		
		public function axisRotation (r:Number, x:Number, y:Number, z:Number) :void {
		
			var _m:Number = Math.sqrt(x*x+y*y+z*z);
			x /= _m; y /= _m; z /= _m;
			
			var s:Number = Math.sin(r);
			var _c:Number = Math.cos(r);
			var u:Number = 1-_c;
			
			var sx:Number = s*x;
			var sy:Number = s*y;
			var sz:Number = s*z;
			var xy:Number = y*x*u;
			var zy:Number = y*z*u;
			var xz:Number = z*x*u;
			
			a = x*x* u + _c;
			b = xy + sz;
			c = xz - sy;
			
			e = xy - sz;
			f = y*y* u + _c;
			g = zy + sx;
			
			i = xz + sy;
			j = zy - sx;
			k = z*z* u + _c;
			
			m = n = o = 0;
			
		}
		
	}
}
