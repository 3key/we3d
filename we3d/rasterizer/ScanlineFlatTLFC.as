package we3d.rasterizer 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import we3d.we3d;
	import we3d.material.FlatAttributes;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Solid color with software rasterizer. 
	* The only diffence to ScanlineFlat is that the ScanlineFlatTLFC uses a top left fill convention.
	* You'll notice the difference only when Solid polygons and Textured polygons are connected.
	*/
	public class ScanlineFlatTLFC extends Rasterizer 
	{
		public function ScanlineFlatTLFC () {
			splitFace.vLen = 3;
		}
		
		public override function clone () :IRasterizer {
			var r:ScanlineFlatTLFC = new ScanlineFlatTLFC();
			return r;
		}
		
		private var splitFace:Face = new Face();
		private var scanline:Rectangle = new Rectangle(0,0,0,1);
		
		public override function draw (material:Surface, session:RenderSession, f:Face) :void {
			
			var sf:FlatAttributes = FlatAttributes(material.attributes);
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
			
			var rc:Rectangle = scanline;
			var col:uint = sf._color32;
						
			var rw2:Number = x3-x1;
			var rh2:Number = y3-y1;
			
			var vs:Number = rw2/rh2;
			var i:int = Math.ceil(y1);
			
			var yps:Number = i - y1;
			
			var l:Number = ((rw2 * yps)/rh2) + x1;
			
			rw2 = x2-x1;
			rh2 = y2-y1;
			var r:Number = ((rw2 * yps)/rh2) + x1;
			
			
			var ws:Number = rw2/rh2;
			
			if(i<0) {
				var ty:int = -int(y1);
				i = 0;
				l += vs*ty;
				r += ws*ty;
			}
			
			var screenHeight:int = bmpref.height;
			var h:int = Math.ceil(y2);
			if(h > screenHeight) h = screenHeight;
			
			
			if(vs > ws) {
				if(y2 > 0) {
					if(y2 > y1) {
						while(i<h) {
							rc.x = Math.ceil(r);
							rc.right = Math.ceil(l);
							rc.y = i;
							bmpref.fillRect(rc, col);
							l += vs;
							r += ws;
							i++;
						}
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
					h = Math.ceil(y3);
					if(h > screenHeight) h = screenHeight;
					
					while(i<h) {
						rc.x = Math.ceil(r);
						rc.right = Math.ceil(l);
						rc.y = i;
						bmpref.fillRect(rc, col);
						l += vs;
						r += ws;
						i++;
					}
				}
			}
			else{
				if(y2 > 0) {
					if(y2 > y1) {
						while(i<h) {
							rc.x = Math.ceil(l);
							rc.right = Math.ceil(r);
							rc.y = i;
							bmpref.fillRect(rc, col);
							l += vs;
							r += ws;
							i++;
						}
					}
				}else{
					i = 0;
				}
				
				if(y3 > y2) {
					rh2 = y3 - y2;
					rw2 = x3 - x2;
					yps = i - y2;
					r = ((rw2 * yps)/rh2) + x2;
					ws = rw2/rh2;
					h = Math.ceil(y3);
					if(h > screenHeight) h = screenHeight;
					
					while(i<h) {
						rc.x = Math.ceil(l);
						rc.right = Math.ceil(r);
						rc.y = i;
						bmpref.fillRect(rc, col);
						l += vs;
						r += ws;
						i++;
					}
				}
			}
			
			if(f.vLen > 3) {
				
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