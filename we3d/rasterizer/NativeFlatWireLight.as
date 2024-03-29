package we3d.rasterizer 
{
	import flash.display.Graphics;
	
	import we3d.we3d;
	import we3d.material.FlatWireLightAttributes;
	import we3d.material.Surface;
	import we3d.math.Matrix3d;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.rasterizer.RasterizerLight;
	import we3d.renderer.RenderSession;
	import we3d.scene.LightGlobals;

	use namespace we3d;
	
	/**
	* Solid fill color and outlines with lighting.
	*/
	public class NativeFlatWireLight implements IRasterizer 
	{
		public function NativeFlatWireLight () {}
		
		public function clone () :IRasterizer {
			var r:NativeFlatWireLight = new NativeFlatWireLight();
			return r;
		}
		
		public function draw (material:Surface, session:RenderSession, f:Face) :void 
		{
			var L:int = f.vLen;
			
			var sf:FlatWireLightAttributes = FlatWireLightAttributes(material.attributes);
			var mc:Graphics = session._graphics;
			var a:Vertex = f.a;
			var b:Vertex = f.b;
			
			if(L == 2) {
				mc.lineStyle(sf.lineStyle, sf._lineColor, sf._lineAlpha);
				mc.moveTo(a.sx, a.sy);
				mc.lineTo(b.sx, b.sy);
				return;
			}
			
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
			
			var lv:int = RasterizerLight.getLightValueW(x, y, z, x0, y0, z0, sf.lightGlobals);
			var col:uint = RasterizerLight.scaleColor(sf._lineColor, lv, sf.luminosity, sf.diffuse);
			
			mc.lineStyle(sf.lineStyle, col, sf.lineAlpha);
		
			col = RasterizerLight.scaleColor(sf._color, lv, sf.luminosity, sf.diffuse);
			mc.beginFill(col, sf._alpha);
			
			x0 = a.sx;
			y0 = a.sy;
			
			mc.moveTo(x0, y0);
			mc.lineTo(b.sx, b.sy);
			
			var c:Vertex = f.c;
			
			if(L == 3) {
				mc.lineTo(c.sx, c.sy);
			}
			else if (L == 4) {
				mc.lineTo(c.sx, c.sy);
				b = f.vtxs[3];
				mc.lineTo(b.sx, b.sy);
			}
			else{
				var p:Vector.<Vertex> = f.vtxs;
				mc.lineTo(c.sx, c.sy);
				for(var i:int=3; i<L; i++) {
					b = p[i];
					mc.lineTo(b.sx, b.sy);
				}
			}
			
			mc.endFill();
		}
	}
	
}