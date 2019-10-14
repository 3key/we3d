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
	* Solid colors with software rasterizer. 
	* The Scanline Rasterizer may be faster than the Native one's, but they get slower with big polygons on the screen.
	* It is highly recommended to use Frustum Clipping with all Scanline Rasterizers.
	* All Scanline Rasterizer don't support antialiasing.
	*/
	public class ScanlineFlat extends Rasterizer 
	{
		public function ScanlineFlat () {
			splitFace.vLen = 3;
		}
		
		public override function clone () :IRasterizer {
			var r:ScanlineFlat = new ScanlineFlat();
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
			
			var rw2:Number = x2-x1;
			var rw3:Number = x3-x1;
			var rh2:Number = y2-y1;
			var rh3:Number = y3-y1;
			
			var i:int = y1;
			if(i < 0) i = 0;
			
			var ps:Number = 1 - (y1 - i);
			var l:Number = ((rw3 * ps)/rh3) + x1;
			var r:Number = ((rw2 * ps)/rh2) + x1;
			var vs:Number = rw3/rh3;
			var ws:Number = rw2/rh2;
			
			var screenHeight:int = bmpref.height;
			var h:int = y2;
			if(h > screenHeight) h = screenHeight;
			
			if(vs > ws) {
				if(y2 > 0) {
					if(y2 > y1) {
						while(i<h) {
							rc.x = r;
							rc.right = l;
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
					ps = 1 - (y2-i);
					rh3 = y3 - y2;
					rw3 = x3 - x2;
					r =  x2 + (rw3 * ps)/rh3;
					ws = rw3/rh3;
					h = y3;
					if(h > screenHeight) h = screenHeight;
					
					while(i<h) {
						rc.x = r;
						rc.right = l;
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
							rc.x = l;
							rc.right = r;
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
					ps = 1 - (y2 -i);
					rh3 = y3 - y2;
					rw3 = x3 - x2;
					r =  x2 + (rw3 * ps)/rh3;
					ws = rw3/rh3;
					h = y3;
					if(h > screenHeight) h = screenHeight;
					
					while(i<h) {
						rc.x = l;
						rc.right = r;
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
				splitFace.a = f.a;
				
				for(i=3; i<h; i++) {
					splitFace.b = f.vtxs[i];
					splitFace.c = f.vtxs[i-1];
					
					draw(material, session, splitFace);
				}
			}
			
		}
		
	}
}