package we3d.rasterizer 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import we3d.we3d;
	import we3d.material.FlatLightAttributes;
	import we3d.material.Surface;
	import we3d.math.Matrix3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Experimental software rasterizer
	* Draws gradient color shades with colors from lighting.
	* The ScanlineSmoothLight rasterizer requires point normals to be calculated wich have to be done after geometry is created or modified
	* Use the SceneObject.calculatePointNormals method to calculate the normal of all points
	*/
	public class ScanlineSmoothLight extends RasterizerLight 
	{
		public function ScanlineSmoothLight () {
			splitFace.vLen = 3;
		}
		
		public override function clone () :IRasterizer {
			var r:ScanlineSmoothLight = new ScanlineSmoothLight();
			return r;
		}
		
		private var splitFace:Face = new Face();
		
		public override function draw (material:Surface, session:RenderSession, f:Face) :void {
			
			var sf:FlatLightAttributes = FlatLightAttributes(material.attributes);
			var bmpref:BitmapData = session.bmp;
			
			if(f.vLen < 3) {
				/*if(f.vLen == 2) {
					drawLine (f.a.sx, f.a.sy, f.b.sx, f.b.sy, sf._color32, bmpref);
				}*/
				return;
			}
			var a:Vertex=f.a;	var b:Vertex=f.b;	var c:Vertex=f.c;
			
			if(a.sy > b.sy) {
				if(a.sy > c.sy) {
					if(b.sy > c.sy) {
						a = f.c;	c = f.a;
					}else{
						a = f.b;	b = f.c;	c = f.a;
					}
				}else{
					a = f.b;	b = f.a;
				}
			}else{
				if(b.sy > c.sy) {
					if(a.sy > c.sy){
						a = f.c;	b = f.a;	c = f.b;
					}else{
						b = f.c;	c = f.b;
					}
				}
			}
			
			var y1:Number = a.sy;
			var y2:Number = b.sy;
			var y3:Number = c.sy;
			
			var x1:Number = a.sx;
			var x2:Number = b.sx;
			var x3:Number = c.sx;
			
			var lo:Matrix3d = f.so.transform.gv;
			var x:Number = a.x;	
			var y:Number = a.y;	
			var z:Number = a.z;
			
			var x0:Number = lo.a*x + lo.e*y + lo.i*z + lo.m;
			var y0:Number = lo.b*x + lo.f*y + lo.j*z + lo.n;
			var z0:Number = lo.c*x + lo.g*y + lo.k*z + lo.o;
			
			var xp:Number = a.normal.x;
			var yp:Number = a.normal.y;
			var zp:Number = a.normal.z;
			
			x = lo.a*xp + lo.e*yp + lo.i*zp;
			y = lo.b*xp + lo.f*yp + lo.j*zp;
			z = lo.c*xp + lo.g*yp + lo.k*zp;
			
			var lv:int = getLightValueW(x, y, z, x0, y0, z0, sf.lightGlobals);
			var col1:int = scaleColor(sf._color, lv, sf.luminosity, sf.diffuse);
			
			x = b.x;	
			y = b.y;	
			z = b.z;
			x0 = lo.a*x + lo.e*y + lo.i*z + lo.m;
			y0 = lo.b*x + lo.f*y + lo.j*z + lo.n;
			z0 = lo.c*x + lo.g*y + lo.k*z + lo.o;
			xp = b.normal.x;
			yp = b.normal.y;
			zp = b.normal.z;
			
			x = lo.a*xp + lo.e*yp + lo.i*zp;
			y = lo.b*xp + lo.f*yp + lo.j*zp;
			z = lo.c*xp + lo.g*yp + lo.k*zp;
			lv = getLightValueW(x, y, z, x0, y0, z0, sf.lightGlobals);
			var col2:int = scaleColor(sf._color, lv, sf.luminosity, sf.diffuse);
			
			x = c.x;	
			y = c.y;	
			z = c.z;
			x0 = lo.a*x + lo.e*y + lo.i*z + lo.m;
			y0 = lo.b*x + lo.f*y + lo.j*z + lo.n;
			z0 = lo.c*x + lo.g*y + lo.k*z + lo.o;
			xp = c.normal.x;
			yp = c.normal.y;
			zp = c.normal.z;
			x = lo.a*xp + lo.e*yp + lo.i*zp;
			y = lo.b*xp + lo.f*yp + lo.j*zp;
			z = lo.c*xp + lo.g*yp + lo.k*zp;
			lv = getLightValueW(x, y, z, x0, y0, z0, sf.lightGlobals);
			var col3:int = scaleColor(sf._color, lv, sf.luminosity, sf.diffuse);
			
			var r1:int = col1 >> 16 & 255;		var g1:int = col1 >> 8 & 255;		var b1:int = col1 & 255;
			var r2:int = col2 >> 16 & 255;		var g2:int = col2 >> 8 & 255;		var b2:int = col2 & 255;
			var r3:int = col3 >> 16 & 255;		var g3:int = col3 >> 8 & 255;		var b3:int = col3 & 255;
			
			var r21:Number = r2-r1;		var g21:Number = g2-g1;		var b21:Number = b2-b1;
			var r31:Number = r3-r1;		var g31:Number = g3-g1;		var b31:Number = b3-b1;
			
			var rw2:Number = x2-x1;
			var rw3:Number = x3-x1;
			var rh2:Number = y2-y1;
			var rh3:Number = y3-y1;
			
			var i:int = Math.ceil(y1);
			if(i < 0) i = 0;
			
			var ps:Number = i-y1;
			var l:Number = ((rw3 * ps)/rh3) + x1;
			var r:Number = ((rw2 * ps)/rh2) + x1;
			var vs:Number = rw3/rh3;
			var ws:Number = rw2/rh2;
			
			var step1:Number = 1/int((y2-y1));
			var step2:Number = 1/int((y3-y1));
				
			if(i<0) {
				var ty:int = -int(y1);
				i = 0;
				l += vs*ty;
				r += ws*ty;
			}
			
			var screenHeight:int = bmpref.height;
			var h:int = Math.ceil(y2);
			if(h > screenHeight) h = screenHeight;
			
			var j:int;
			var s:int;
			var e:int;
			
			var sr1:int;	var sg1:int;	var sb1:int;
			var sr2:int;	var sg2:int;	var sb2:int;
			var ir:int;		var ig:int;		var ib:int;
			var isr:int;	var isg:int;	var isb:int;
			var cr1:int;	var cg1:int;	var cb1:int;
			var cr2:int;	var cg2:int;	var cb2:int;
			var dx:Number;
			
			var st1:Number = 0;
			var st2:Number = 0;
			var ist:Number;
			var istep:Number;
			
			if(vs > ws) {
				if(y2 > 0) {
					if(int(y2) > int(y1)) {
						while(i<h) {
							
							s = Math.ceil(r);
							e = Math.ceil(l);
							
							cr1 = r1 + r21*st1;
							cg1 = g1 + g21*st1;
							cb1 = b1 + b21*st1;
							
							cr2 = (r1 + r31*st2)-cr1;
							cg2 = (g1 + g31*st2)-cg1;
							cb2 = (b1 + b31*st2)-cb1;
							
							st1 += step1;
							st2 += step2;
							
							dx = e-s;
							istep = 1/dx;
							ist = 0;
							
							for(j=s; j<e; j++) {
								ir = cr1 + cr2 * ist;
								ig = cg1 + cg2 * ist;
								ib = cb1 + cb2 * ist;
								bmpref.setPixel32(j, i,  0xff000000 | ir << 16 | ig << 8 | ib);
								ist += istep;
							}
							
							l += vs;
							r += ws;
							i++;
						}
					}else{
						step1 = 1/int((y3-y1));
					}
				}
				else{
					i = 0;
				}
				
				if(int(y3) > int(y2)) {
					ps = i - y2;
					rh3 = y3 - y2;
					rw3 = x3 - x2;
					r =  x2 + (rw3 * ps)/rh3;
					ws = rw3/rh3;
					step1 = 1/int((y3-y2));
					st1 = 0;
					h = Math.ceil(y3);
					if(h > screenHeight) h = screenHeight;
					
					while(i<h) {
						s = Math.ceil(r);
						e = Math.ceil(l);
						
						cr1 = r2 + (r3-r2)*st1;
						cg1 = g2 + (g3-g2)*st1;
						cb1 = b2 + (b3-b2)*st1;
						
						cr2 = (r1 + r31*st2)-cr1;
						cg2 = (g1 + g31*st2)-cg1;
						cb2 = (b1 + b31*st2)-cb1;
						
						st1 += step1;
						st2 += step2;
						
						dx = e-s;
						istep = 1/dx;
						ist = 0;
						
						for(j=s; j<e; j++) {
							ir = cr1 + cr2 * ist;
							ig = cg1 + cg2 * ist;
							ib = cb1 + cb2 * ist;
							bmpref.setPixel32(j, i,  0xff000000 | ir << 16 | ig << 8 | ib);
							ist += istep;
						}
						
						l += vs;
						r += ws;
						i++;
					}
				}
			}
			else{
				
				if(y2 > 0) {
					if(int(y2) > int(y1)) {
						while(i<h) {
							s = Math.ceil(l);
							e = Math.ceil(r);
							
							cr1 = r1 + r31*st1;
							cg1 = g1 + g31*st1;
							cb1 = b1 + b31*st1;
							
							cr2 = (r1 + (r21)*st2)-cr1;
							cg2 = (g1 + (g21)*st2)-cg1;
							cb2 = (b1 + (b21)*st2)-cb1;
							
							st1 += step2;
							st2 += step1;
							
							dx = e-s;
							istep = 1/dx;
							ist = 0;
							
							for(j=s; j<e; j++) {
								ir = cr1 + cr2 * ist;
								ig = cg1 + cg2 * ist;
								ib = cb1 + cb2 * ist;
								bmpref.setPixel32(j, i,  0xff000000 | ir << 16 | ig << 8 | ib);
								ist += istep;
							}
							
							l += vs;
							r += ws;
							i++;
						}
					}else{
						step1 = 1/int((y3-y1));
					}
				}else{
					i = 0;
				}
				
				if(int(y3) > int(y2)) {
					ps = i - y2;
					rh3 = y3 - y2;
					rw3 = x3 - x2;
					r =  x2 + (rw3 * ps)/rh3;
					ws = rw3/rh3;
					step1 = 1/int((y3-y2));
					st2 = 0;
					h = Math.ceil(y3);
					if(h > screenHeight) h = screenHeight;
					
					while(i<h) {
						s = Math.ceil(l);
						e = Math.ceil(r);
						
						cr1 = r1 + (r31)*st1;
						cg1 = g1 + (g31)*st1;
						cb1 = b1 + (b31)*st1;
						
						cr2 = (r2 + (r3-r2)*st2)-cr1;
						cg2 = (g2 + (g3-g2)*st2)-cg1;
						cb2 = (b2 + (b3-b2)*st2)-cb1;
						
						st1 += step2;
						st2 += step1;
						
						dx = e-s;
						istep = 1/dx;
						ist = 0;
						
						for(j=s; j<e; j++) {
							ir = cr1 + cr2 * ist;
							ig = cg1 + cg2 * ist;
							ib = cb1 + cb2 * ist;
							bmpref.setPixel32(j, i,  0xff000000 | ir << 16 | ig << 8 | ib);
							ist += istep;
						}
						
						l += vs;
						r += ws;
						i++;
					}
				}
			}
			
			if(f.vLen > 3) {
				
				splitFace.so = f.so;
				splitFace.normal.wx = f.normal.wx;
				splitFace.normal.wy = f.normal.wy;
				splitFace.normal.wz = f.normal.wz;
				
				h = f.vLen;
				
				for(i=3; i<h; i++) {
					splitFace.a = f.a;
					splitFace.b = f.vtxs[i];
					splitFace.c = f.vtxs[i-1];
					
					draw(material, session, splitFace);
				}
			}
			
		}
		
	}
}