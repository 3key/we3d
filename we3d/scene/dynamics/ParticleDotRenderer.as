package we3d.scene.dynamics 
{
	import we3d.we3d;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* The ParticleDotRenderer renders a pixels at every particle point. The pixels are rendered into the bitmapdata of a Layer.
	*/
	public class ParticleDotRenderer extends ParticleRenderer 
	{
		public function ParticleDotRenderer () {}
		
		public override function render (emt:ParticleEmitter, session:RenderSession) :void 
		{
			var L:int = emt.points.length;
			
			var p:Particle;
			var ofc:int = emt.so.frameCounter;
			var c:uint;
			var t:int;
			var t2:int;
			var col2:int;
			var px:int;
			var py:int;
			
			for(var i:int=0; i<L; i++) 
			{
				p = emt.points[i];
				
				if(p.frameCounter2 == ofc) {
					px = int(p.sx);
					py = int(p.sy);
					t = p.alpha * 255;
					c = 0xff000000 | p.color;
					
					if(t >= 0xff) {
						session.bmp.setPixel32( px, py, c );
						
						if(p.size >= 1) {
							session.bmp.setPixel32( px-1, py, c );
							session.bmp.setPixel32( px+1, py, c );
							session.bmp.setPixel32( px, py-1, c );
							session.bmp.setPixel32( px, py+1, c );
							if( p.size >= 2 ) {
								session.bmp.setPixel32( px-1, py+1, c );
								session.bmp.setPixel32( px+1, py-1, c );
								session.bmp.setPixel32( px-1, py-1, c );
								session.bmp.setPixel32( px+1, py+1, c );
							}
						}
					}
					else if(t > 0) 
					{
						t2 = 255-t;
						col2 = session.bmp.getPixel(px,py);
						session.bmp.setPixel32( px, py, (0xff0000 & (((c & 0xff0000) * t + (col2 & 0xff0000) * t2) >> 8)) | (0x00ff00 & (((c & 0x00ff00) * t + (col2 & 0x00ff00) * t2) >> 8)) | (0x0000ff & (((c & 0x0000ff) * t + (col2 & 0x0000ff) * t2) >> 8)) );
						
						if(p.size >= 1) 
						{
							col2 = session.bmp.getPixel(px-1,py);
							session.bmp.setPixel32( px-1, py, (0xff0000 & (((c & 0xff0000) * t + (col2 & 0xff0000) * t2) >> 8)) | (0x00ff00 & (((c & 0x00ff00) * t + (col2 & 0x00ff00) * t2) >> 8)) | (0x0000ff & (((c & 0x0000ff) * t + (col2 & 0x0000ff) * t2) >> 8)) );
							col2 = session.bmp.getPixel(px+1,py);
							session.bmp.setPixel32( px+1, py, (0xff0000 & (((c & 0xff0000) * t + (col2 & 0xff0000) * t2) >> 8)) | (0x00ff00 & (((c & 0x00ff00) * t + (col2 & 0x00ff00) * t2) >> 8)) | (0x0000ff & (((c & 0x0000ff) * t + (col2 & 0x0000ff) * t2) >> 8)) );
							col2 = session.bmp.getPixel(px,py-1);
							session.bmp.setPixel32( px, py-1, (0xff0000 & (((c & 0xff0000) * t + (col2 & 0xff0000) * t2) >> 8)) | (0x00ff00 & (((c & 0x00ff00) * t + (col2 & 0x00ff00) * t2) >> 8)) | (0x0000ff & (((c & 0x0000ff) * t + (col2 & 0x0000ff) * t2) >> 8)) );
							col2 = session.bmp.getPixel(px,py+1);
							session.bmp.setPixel32( px, py+1, (0xff0000 & (((c & 0xff0000) * t + (col2 & 0xff0000) * t2) >> 8)) | (0x00ff00 & (((c & 0x00ff00) * t + (col2 & 0x00ff00) * t2) >> 8)) | (0x0000ff & (((c & 0x0000ff) * t + (col2 & 0x0000ff) * t2) >> 8)) );
							
							if( p.size >= 2 ) 
							{
								col2 = session.bmp.getPixel(px-1,py+1);
								session.bmp.setPixel32( px-1, py+1, (0xff0000 & (((c & 0xff0000) * t + (col2 & 0xff0000) * t2) >> 8)) | (0x00ff00 & (((c & 0x00ff00) * t + (col2 & 0x00ff00) * t2) >> 8)) | (0x0000ff & (((c & 0x0000ff) * t + (col2 & 0x0000ff) * t2) >> 8)) );
								col2 = session.bmp.getPixel(px+1,py-1);
								session.bmp.setPixel32( px+1, py-1, (0xff0000 & (((c & 0xff0000) * t + (col2 & 0xff0000) * t2) >> 8)) | (0x00ff00 & (((c & 0x00ff00) * t + (col2 & 0x00ff00) * t2) >> 8)) | (0x0000ff & (((c & 0x0000ff) * t + (col2 & 0x0000ff) * t2) >> 8)) );
								col2 = session.bmp.getPixel(px-1,py-1);
								session.bmp.setPixel32( px-1, py-1, (0xff0000 & (((c & 0xff0000) * t + (col2 & 0xff0000) * t2) >> 8)) | (0x00ff00 & (((c & 0x00ff00) * t + (col2 & 0x00ff00) * t2) >> 8)) | (0x0000ff & (((c & 0x0000ff) * t + (col2 & 0x0000ff) * t2) >> 8)) );
								col2 = session.bmp.getPixel(px+1,py+1);
								session.bmp.setPixel32( px+1, py+1, (0xff0000 & (((c & 0xff0000) * t + (col2 & 0xff0000) * t2) >> 8)) | (0x00ff00 & (((c & 0x00ff00) * t + (col2 & 0x00ff00) * t2) >> 8)) | (0x0000ff & (((c & 0x0000ff) * t + (col2 & 0x0000ff) * t2) >> 8)) );
							}
						}
					}
					
					
				}
				
				
			}
		}
		
		public override function clone () :ParticleRenderer {
			return new ParticleDotRenderer();
		}
	}
}
