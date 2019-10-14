package we3d.rasterizer 
{
	import flash.display.BitmapData;
	
	import we3d.we3d;
	import we3d.material.BitmapAttributes;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Bitmap textures with software rasterizer. 
	* ScanlineTX provides perspective correct texture mapping with support for uv coords on polygons (triangles, quads and also polygons).
	*/
	public class ScanlineTX extends Rasterizer
	{
		public function ScanlineTX () {
			splitFace.vLen = 3;
		}
		
		public override function clone () :IRasterizer {
			var r:ScanlineTX = new ScanlineTX();
			return r;
		}
		
		private var splitFace:Face = new Face();
		
		public override function draw (material:Surface, session:RenderSession, f:Face) :void {
			
			var sf:BitmapAttributes = BitmapAttributes(material.attributes);
			var bmpref:BitmapData = session.bmp;
			
			if(f.vLen < 3) {
				/*if(f.vLen == 2) {
					drawLine (f.a.sx, f.a.sy, f.b.sx, f.b.sy, sf._color32, bmpref);
				}*/
				return;
			}
			var a:Vertex=f.a;	var b:Vertex=f.b;	var c:Vertex=f.c;
			
			var tc_u1:Number;	var tc_u2:Number;	var tc_u3:Number;
			var tc_v1:Number;	var tc_v2:Number;	var tc_v3:Number;
			
			if(a.sy > b.sy) {
				if(a.sy > c.sy) {
					if(b.sy > c.sy) {
						a = f.c;		c = f.a;
						tc_u1= f.u3*sf._w; 	tc_u2= f.u2*sf._w;	tc_u3= f.u1*sf._w;	
						tc_v1= f.v3*sf._h;	tc_v2= f.v2*sf._h;	tc_v3= f.v1*sf._h;
					}else{
						a = f.b;		b = f.c;		c = f.a;
						tc_u1= f.u2*sf._w; 	tc_u2= f.u3*sf._w;	tc_u3= f.u1*sf._w;	
						tc_v1= f.v2*sf._h;	tc_v2= f.v3*sf._h;	tc_v3= f.v1*sf._h;
					}
				}else{
					a = f.b;		b = f.a;
					tc_u1= f.u2*sf._w; 	tc_u2= f.u1*sf._w;	tc_u3= f.u3*sf._w;	
					tc_v1= f.v2*sf._h;	tc_v2= f.v1*sf._h;	tc_v3= f.v3*sf._h;
				}
			}else{
				if(b.sy > c.sy) {
					if(a.sy > c.sy){
						a = f.c;		b = f.a;		c = f.b;
						tc_u1= f.u3*sf._w; 	tc_u2= f.u1*sf._w;	tc_u3= f.u2*sf._w;	
						tc_v1= f.v3*sf._h;	tc_v2= f.v1*sf._h;	tc_v3= f.v2*sf._h;
					}else {
						b = f.c;		c = f.b;
						tc_u1= f.u1*sf._w; 	tc_u2= f.u3*sf._w;	tc_u3= f.u2*sf._w;	
						tc_v1= f.v1*sf._h;	tc_v2= f.v3*sf._h;	tc_v3= f.v2*sf._h;
					}
				}else{
					tc_u1= f.u1*sf._w; 	tc_u2= f.u2*sf._w;	tc_u3= f.u3*sf._w;	
					tc_v1= f.v1*sf._h;	tc_v2= f.v2*sf._h;	tc_v3= f.v3*sf._h;
				}
			}
			
			var y3:Number = c.sy;
			if(y3 < 0) return;
			
			var y1:Number = a.sy;
			var screenHeight:int = bmpref.height;
			
			if(y1 > screenHeight) return;
			
			var screenWidth:int = bmpref.width;			
			var tex:BitmapData = sf._texture;
			var y2:Number = b.sy;
			
			var aOneOverZ0:Number = 1/a.wz;
			var aUOverZ0:Number = tc_u1 * aOneOverZ0;
			var aVOverZ0:Number = tc_v1 * aOneOverZ0;
			var aOneOverZ1:Number = 1/b.wz;
			var aUOverZ1:Number = tc_u2 * aOneOverZ1;
			var aVOverZ1:Number = tc_v2 * aOneOverZ1;
			var aOneOverZ2:Number = 1/c.wz;
			var aUOverZ2:Number = tc_u3 * aOneOverZ2;
			var aVOverZ2:Number = tc_v3 * aOneOverZ2;
			
			var x1:Number = a.sx;	var x2:Number = b.sx;	var x3:Number = c.sx;
			
			var pu:Number  = x2-x3;
			var pv:Number  = y1-y3;
			var ty:Number  = x1-x3;
			var xps:Number = y2-y3;
			
			var OneOverdX:Number = 1 / (pu * pv - ty * xps);
			var OneOverdY:Number = -OneOverdX;
			
			var dOneOverZdX:Number = OneOverdX * (((aOneOverZ1 - aOneOverZ2) * pv) - ((aOneOverZ0 - aOneOverZ2) * xps));
			var dOneOverZdY:Number = OneOverdY * (((aOneOverZ1 - aOneOverZ2) * ty) - ((aOneOverZ0 - aOneOverZ2) * pu));
			var dUOverZdX:Number   = OneOverdX * (((aUOverZ1 - aUOverZ2)     * pv) - ((aUOverZ0 - aUOverZ2)     * xps));
			var dUOverZdY:Number   = OneOverdY * (((aUOverZ1 - aUOverZ2)     * ty) - ((aUOverZ0 - aUOverZ2)     * pu));
			var dVOverZdX:Number   = OneOverdX * (((aVOverZ1 - aVOverZ2)     * pv) - ((aVOverZ0 - aVOverZ2)     * xps));
			var dVOverZdY:Number   = OneOverdY * (((aVOverZ1 - aVOverZ2)     * ty) - ((aVOverZ0 - aVOverZ2)     * pu));
			
			var rw2:Number = x3-x1;
			var rh2:Number = y3-y1;
			
			var vs:Number = rw2/rh2;
			
			var i:int = Math.ceil(y1);
			var yps:Number = i - y1;
			
			var l:Number = ((rw2 * yps)/rh2) + x1;
			xps = l - x1;
			
			var oneOverZ:Number     = aOneOverZ0 + yps * dOneOverZdY + xps * dOneOverZdX;
			var oneOverZStep:Number = vs * dOneOverZdX + dOneOverZdY;
			var uOverZ:Number       = aUOverZ0 + yps * dUOverZdY + xps * dUOverZdX;
			var uOverZStep:Number   = vs * dUOverZdX + dUOverZdY;
			var vOverZ:Number       = aVOverZ0 + yps * dVOverZdY + xps * dVOverZdX;
			var vOverZStep:Number   = vs * dVOverZdX + dVOverZdY;
			
			rw2 = x2-x1;
			rh2 = y2-y1;
			
			var ws:Number = rw2/rh2;
			
			var r:Number = ((rw2 * yps)/rh2) + x1;
			var L:int = Math.ceil(y2);
			if(L> screenHeight) L = screenHeight;
			
			var esz:Number;
			var iz:Number;
			var re:int;
			var li:int;
			var px:int;
			
			if(i<0) {
				ty = -int(y1);
				i = 0;
				l += vs*ty;
				r += ws*ty;
				uOverZ += uOverZStep*ty;
				vOverZ += vOverZStep*ty;
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
							pu  = uOverZ   + xps * dUOverZdX;
							pv  = vOverZ   + xps * dVOverZdX;
							for(px=li; px<re; px++) {
								iz = 1/esz;
								bmpref.setPixel32(px, i, tex.getPixel32(pu*iz, pv*iz));
								esz += dOneOverZdX;
								pu += dUOverZdX;
								pv += dVOverZdX;
							}
								
							l += vs;
							r += ws;
							uOverZ += uOverZStep;
							vOverZ += vOverZStep;
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
						pu  = uOverZ   + xps * dUOverZdX;
						pv  = vOverZ   + xps * dVOverZdX;
						for(px=li; px<re; px++) {
							iz = 1/esz;
							bmpref.setPixel32(px, i, tex.getPixel32(pu*iz, pv*iz));
							esz += dOneOverZdX;
							pu += dUOverZdX;
							pv += dVOverZdX;
						}
							
						l += vs;
						r += ws;
						uOverZ += uOverZStep;
						vOverZ += vOverZStep;
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
							pu  = uOverZ   + xps * dUOverZdX;
							pv  = vOverZ   + xps * dVOverZdX;
							for(px=li; px<re; px++) {
								iz = 1/esz;
								bmpref.setPixel32(px, i, tex.getPixel32(pu*iz, pv*iz));
								esz += dOneOverZdX;
								pu += dUOverZdX;
								pv += dVOverZdX;
							}
								
							l += vs;
							r += ws;
							uOverZ += uOverZStep;
							vOverZ += vOverZStep;
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
						pu  = uOverZ   + xps * dUOverZdX;
						pv  = vOverZ   + xps * dVOverZdX;
						for(px=li; px<re; px++) {
							iz = 1/esz;
							bmpref.setPixel32(px, i, tex.getPixel32(pu*iz, pv*iz));
							esz += dOneOverZdX;
							pu += dUOverZdX;
							pv += dVOverZdX;
						}
							
						l += vs;
						r += ws;
						uOverZ += uOverZStep;
						vOverZ += vOverZStep;
						oneOverZ += oneOverZStep;
						i++;
					}
				}
			}
			
			if(f.vLen > 3) {
				
				L = f.vLen;
				
				for(i=3; i<L; i++) {
					splitFace.a = f.a;
					splitFace.b = f.vtxs[i];
					splitFace.c = f.vtxs[i-1];
					
					splitFace.u1 = f.uvs[0].u;
					splitFace.v1 = f.uvs[0].v;
					splitFace.u2 = f.uvs[i].u;
					splitFace.v2 = f.uvs[i].v;
					splitFace.u3 = f.uvs[i-1].u;
					splitFace.v3 = f.uvs[i-1].v;
					
					draw(material, session, splitFace);
				}
			}
			
		}
	}
}