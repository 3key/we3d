package we3d.rasterizer 
{
	import flash.display.BitmapData;
	
	import we3d.we3d;
	import we3d.filter.ZBuffer;
	import we3d.material.FlatLightAttributes;
	import we3d.material.Surface;
	import we3d.math.Matrix3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Solid color and lighting with software rasterizer and zbuffer.
	*/
	public class ScanlineFlatLightZB extends RasterizerZBufferLight 
	{
		public function ScanlineFlatLightZB (zb:ZBuffer=null) {
			splitFace.vLen = 3;
			zbuffer = zb;
		}
		
		public override function clone () :IRasterizer {
			var r:ScanlineFlatLightZB = new ScanlineFlatLightZB();
			r.zBuffer = zbuffer;
			return r;
		}
		
		private var splitFace:Face = new Face();
		private var lightColor:uint=0;
		
		public override function draw (material:Surface, session:RenderSession, f:Face) :void 
		{	
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
						a = f.c;		c = f.a;
					}else{
						a = f.b;		b = f.c;		c = f.a;
					}
				}else{
					a = f.b;		b = f.a;
				}
			}else{
				if(b.sy > c.sy) {
					if(a.sy > c.sy){
						a = f.c;		b = f.a;		c = f.b;
					}else {
						b = f.c;		c = f.b;
					}
				}
			}
			
			var y3:Number = c.sy;
			if(y3 < 0) return;
			
			var y1:Number = a.sy;
			var screenHeight:int = bmpref.height;
			
			if(y1 > screenHeight) return;
			
			var screenWidth:int = bmpref.width;
			
			
			if(f.vtxs != null) {
				var lo:Matrix3d = f.so.transform.gv;
				
				var x:Number = f.ax;
				var y:Number = f.ay;	
				var z:Number = f.az;
				
				var x0:Number = lo.a*x + lo.e*y + lo.i*z + lo.m;
				var y0:Number = lo.b*x + lo.f*y + lo.j*z + lo.n;
				var z0:Number = lo.c*x + lo.g*y + lo.k*z + lo.o;
				
				x = f.normal.wx;
				y = f.normal.wy;
				z = f.normal.wz;
				
				var lv:int = getLightValueW(x, y, z, x0, y0, z0, sf.lightGlobals);
				
				lightColor =  int(sf._alpha*255) << 24 |  scaleColor(sf.color, lv, sf.luminosity, sf.diffuse);
			}
			var col:uint  = lightColor;
			
			var y2:Number = b.sy;
			
			var aOneOverZ0:Number = 1/a.wz;
			var aOneOverZ1:Number = 1/b.wz;
			var aOneOverZ2:Number = 1/c.wz;
			
			var x1:Number = a.sx;	var x2:Number = b.sx;	var x3:Number = c.sx;
			
			var pu:Number  = x2-x3;
			var pv:Number  = y1-y3;
			var ty:Number  = x1-x3;
			var xps:Number = y2-y3;
			
			var OneOverdX:Number = 1 / (pu * pv - ty * xps);
			var OneOverdY:Number = -OneOverdX;
			
			var dOneOverZdX:Number = OneOverdX * (((aOneOverZ1 - aOneOverZ2) * pv) - ((aOneOverZ0 - aOneOverZ2) * xps));
			var dOneOverZdY:Number = OneOverdY * (((aOneOverZ1 - aOneOverZ2) * ty) - ((aOneOverZ0 - aOneOverZ2) * pu));
			
			var rw2:Number = x3-x1;
			var rh2:Number = y3-y1;
			
			var vs:Number = rw2/rh2;
			
			var i:int = Math.ceil(y1);
			var yps:Number = i - y1;
			
			var l:Number = ((rw2 * yps)/rh2) + x1;
			xps = l - x1;
			
			var oneOverZ:Number     = aOneOverZ0 + yps * dOneOverZdY + xps * dOneOverZdX;
			var oneOverZStep:Number = vs * dOneOverZdX + dOneOverZdY;
			
			rw2 = x2-x1;
			rh2 = y2-y1;
			
			var ws:Number = rw2/rh2;
			
			var r:Number = ((rw2 * yps)/rh2) + x1;
			var L:int = Math.ceil(y2);
			if(L> screenHeight) L = screenHeight;
			
			var zbuf:Vector.<Number> = zbuffer ? zbuffer.vec : session.scene.cam.zBufferData.vec;
			
			var esz:Number;
			var re:int;
			var li:int;
			var px:int;
			var zbi:int;
			
			if(i<0) {
				ty = -int(y1);
				i = 0;
				l += vs*ty;
				r += ws*ty;
				oneOverZ += oneOverZStep*ty;
			}
			
			if(vs > ws) {
				if(y2 > 0) {
					if(y2 > y1) {
						while(i<L) {	
							re = Math.ceil(l);
							li = Math.ceil(r);
							
							xps = li - l;
							esz = oneOverZ + xps * dOneOverZdX;
							if(li<0) li=0;
							if(re>screenWidth) re = screenWidth;
							zbi = li+i*screenWidth;
							
							for(px=li; px<re; px++) {
								if(zbuf[zbi] <= esz ) {
									bmpref.setPixel32(px, i, col);
									zbuf[zbi] = esz;
								}
								zbi++;
								esz += dOneOverZdX;
							}
							
							l += vs;
							r += ws;
							oneOverZ += oneOverZStep;
							i++;
						}
					}
					else{
						i = Math.ceil(y2);
					}
				}
				else{
					i = 0;
				}
				
				if(y3 > y2) {
					rh2 = y3 - y2;
					rw2 = x3 - x2;
					yps = i - y2;
					r = ((rw2 * yps)/rh2) + x2;
					ws = rw2/rh2;
					L = Math.ceil(y3);
					if(L > screenHeight) L = screenHeight;
					
					while(i<L) {
						re = Math.ceil(l);
						li = Math.ceil(r);
						
						xps = li - l;
						esz = oneOverZ + xps * dOneOverZdX;
						if(li<0) li=0;
						if(re>screenWidth) re = screenWidth;
						zbi = li+i*screenWidth;
						
						for(px=li; px<re; px++) {
							if(zbuf[zbi] <= esz ) {	
								bmpref.setPixel32(px, i, col);
								zbuf[zbi] = esz;
							}
							zbi++;
							esz += dOneOverZdX;
						}
							
						l += vs;
						r += ws;
						oneOverZ += oneOverZStep;
						i++;
					}
				}
			}
			else{
				if(y2 > 0) {
					if(y2 > y1) {
						while(i<L) {	
							li = Math.ceil(l);
							re = Math.ceil(r);
							
							xps = li - l;
							esz = oneOverZ + xps * dOneOverZdX;
							if(li<0) li=0;
							if(re>screenWidth) re = screenWidth;
							zbi = li+i*screenWidth;
							
							for(px=li; px<re; px++) {
								if(zbuf[zbi] <= esz ) {	
									bmpref.setPixel32(px, i, col);
									zbuf[zbi] = esz;
								}
								zbi++;
								esz += dOneOverZdX;
							}
								
							l += vs;
							r += ws;
							oneOverZ += oneOverZStep;
							i++;
						}
						
					}
					else{
						i = Math.ceil(y2);
					}
				}
				else{
					i = 0;	
				}
				
				if(y3 > y2) {
					rh2 = y3 - y2;
					rw2 = x3 - x2;
					yps = i - y2;
					r = ((rw2 * yps)/rh2) + x2;
					ws = rw2/rh2;
					L = Math.ceil(y3);
					if(L > screenHeight) L = screenHeight;
					
					while(i<L) {
						
						li = Math.ceil(l);
						re = Math.ceil(r);
						
						xps = li - l;
						esz = oneOverZ + xps * dOneOverZdX;
						if(li<0) li=0;
						if(re>screenWidth) re = screenWidth;
						zbi = li+i*screenWidth;
						
						for(px=li; px<re; px++) {
							if(zbuf[zbi] <= esz ) {	
								bmpref.setPixel32(px, i, col);
								zbuf[zbi] = esz;
							}
							zbi++;
							esz += dOneOverZdX;
						}
							
						l += vs;
						r += ws;
						oneOverZ += oneOverZStep;
						i++;
					}
				}
			}
			
			if(f.vLen > 3) {
				
				splitFace.normal.wx = f.normal.wx;
				splitFace.normal.wy = f.normal.wy;
				splitFace.normal.wz = f.normal.wz;
				
				splitFace.ax = f.ax;
				splitFace.ay = f.ay;
				splitFace.az = f.az;
				
				splitFace.so = f.so;
				
				L = f.vLen;
				
				for(i=3; i<L; i++) {
					splitFace.a = f.a;
					splitFace.b = f.vtxs[i];
					splitFace.c = f.vtxs[i-1];
					
					draw(material, session, splitFace);
				}
			}
			
		}
	}
}