package we3d.rasterizer 
{
	import we3d.we3d;
	import we3d.math.Matrix3d;
	import we3d.scene.LightGlobals;
	import we3d.scene.SceneLight;

	use namespace we3d;
	
	/**
	 * @private
	 */ 
	public class RasterizerLight extends Rasterizer
	{
		public function RasterizerLight () {}
		
		public static function getLightValueW (ux:Number, uy:Number, uz:Number, cx:Number, cy:Number, cz:Number, lightGlobals:LightGlobals) :int {
			
			var v:Number;
			var lightList:Vector.<SceneLight> = lightGlobals.lightList;
			var L:int = lightList.length;
			var r:int = lightGlobals._sar;
			var g:int = lightGlobals._sag;
			var b:int = lightGlobals._sab;
			var gv:Matrix3d;
			var ang:Number;
			var lght:SceneLight;
			var r90:Number = Math.PI/2;
			var d:Number=1;
			var m:Number;
			var x:Number;
			var y:Number;
			var z:Number;
			
			for(var i:int=0; i<L; i++) 
			{
				lght = lightList[i];
				gv = lght.transform.gv;
				
				if(lght.directional) 
				{
					ang = -(gv.i*ux + gv.j*uy + gv.k*uz);
					d = lght.intensity;
				}
				else
				{
					x = gv.m - cx;
					y = gv.n - cy;
					z = gv.o - cz;
					
					m = Math.sqrt(x*x + y*y + z*z); 
					
					if(lght.radius > 0) {
						if(m > lght.radius) continue;
						d = (lght.intensity*1000)/(m*m);
					}else{
						d = lght.intensity;
					}
					
					x /= m; y /= m; z /= m;
					
					
					ang = x*ux + y*uy + z*uz;
				}
				
				if(ang >= 0 && ang < r90)
				{
					v = d * ang;
						
					r += lght.r*v;
					g += lght.g*v;
					b += lght.b*v;
				}
			}
			
			if(r>255) r = 255;
			if(g>255) g = 255;
			if(b>255) b = 255;
			return r << 16 | g << 8 | b;
		}
		
		public static function scaleColor (c1:int, c2:int, luminosity:Number, diffuse:Number) :int {
			var rc:int = (c1>>16&255);
			var r:int = (rc * ((c2>>16&255)/255))*diffuse;
			r += rc*luminosity;
			if(r > 255) r = 255; 
			
			var gc:int = (c1>>8&255);
			var g:int = (gc *((c2>>8&255)/255))*diffuse;
			g += gc*luminosity;
			if(g > 255) g = 255; 
			
			var bc:int = (c1&255);
			var b:int = (bc * ((c2&255)/255))*diffuse;
			b += bc*luminosity;
			if(b > 255) b = 255; 
			
			return r << 16 | g << 8 | b;
		}
		
		public static function scaleColor32 (c1:uint, c2:uint, luminosity:Number, diffuse:Number) :uint {
			var a:int = c1 >> 24 & 255;
			
			var rc:int = (c1>>16&255);
			var r:int = (rc * (c2>>16&255)/255)*diffuse;
			r += rc*luminosity;
			if(r > 255) r = 255; 
			
			var gc:int = (c1>>8&255);
			var g:int = (gc * (c2>>8&255)/255)*diffuse;
			g += gc*luminosity;
			if(g > 255) g = 255; 
			
			var bc:int = (c1&255);
			var b:int = (bc * (c2&255)/255)*diffuse;
			b += bc*luminosity;
			if(b > 255) b = 255; 
			
			return a << 24 | r << 16 | g << 8 | b;
		}
				
	}
}