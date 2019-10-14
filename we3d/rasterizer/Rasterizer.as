package we3d.rasterizer 
{
	import flash.display.BitmapData;
	import we3d.renderer.RenderSession;
	import we3d.mesh.Face;
	import we3d.material.Surface;
	/**
	 * @private
	 */
	public class Rasterizer implements IRasterizer 
	{
		public function Rasterizer () {}
		
		public function draw (material:Surface, session:RenderSession, f:Face) :void {}
		
		public function drawLine (x:int, y:int, ex:int, ey:int, c:int, bmp:BitmapData) :void {
			var dx:int = ex - x;
			var dy:int = ey - y;
			
			var u:int;
			var v:int;
			
			if(dy < 0) {
				dy = -dy;
				v = -1;
			}else{
				v = 1;
			}
			
			if(dx < 0) {
				dx = -dx;
				u = -1;
			}else{
				u = 1;
			}
			
			bmp.setPixel32(x, y, c);
			
			var i:int;
			var e:int;
			
			if(dx > dy) {
				e = dx/2;
				for(i=1; i<=dx; i++) {
					x += u;
					e += dy;
					if(e > dx) {
						e -= dx;
						y += v;
					}
					bmp.setPixel32(x, y, c);
				}
			}else{
				e = dy/2;
				for(i=1; i<=dy; i++) {
					y += v
					e += dx;
					if(e > dy) {
						e -= dy;
						x += u;
					}   
					bmp.setPixel32(x, y, c);
				}
			}
		}
	
		public function clone () :IRasterizer {
			return new Rasterizer();
		}
	
	}
}