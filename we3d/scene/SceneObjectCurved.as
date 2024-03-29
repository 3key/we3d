package we3d.scene 
{
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.math.Matrix3d;
	import we3d.mesh.Vertex;
	import we3d.mesh.VertexCurved;
	import we3d.renderer.RenderSession;
	import we3d.scene.SceneObject;

	use namespace we3d;
	
	/** 
	* The SceneObjectCurved object allows curved points in polygons.
	*/
	public class SceneObjectCurved extends SceneObject 
	{
		public function SceneObjectCurved () {}
		
		/** 
		* Add a curved point
		* @param	x
		* @param	y
		* @param	z
		* @param	cx 		curve control location
		* @param	cy 		curve control location
		* @param	cz 		curve control location
		* @param	testPoints	if true test if the point is already available
		* @return	The id of the point in the points list
		*/
		public function addCurvedPoint (x:Number, y:Number, z:Number, cx:Number, cy:Number, cz:Number, testPoints:Boolean=false) :int {
			if(testPoints) {
				var p:VertexCurved;
				var L:int = points.length
				for(var i:int = 0; i<L; i++) {
					if(points[i] is VertexCurved) {
						p = VertexCurved( points[i] );
						if(p.x == x && p.y == y && p.z == z && p.bx == cx && p.by == cy && p.bz == cz) {
							return i;
						}
					}
				}
			}
			
			objectCuller.testPoint(x, y, z);
			
			return points.push(new VertexCurved(x,y,z,cx,cy,cz)) - 1;
		}
		
		/**
		* @private
		*/
		public override function initMesh (session:RenderSession) :Boolean {
			
			var cgv:Matrix3d = camMatrix;
			
			super.initMesh(session);
			
			var cam:Camera3d = session.scene.cam;
			var _p:Vector.<Vertex> = points;
			var L:int = _p.length;
			var p:Vertex;
			var pc:VertexCurved;
			var w:Number;
			var ma:Number = cgv.a;	var mb:Number = cgv.b;	var mc:Number = cgv.c;
			var me:Number = cgv.e;	var mf:Number = cgv.f;	var mg:Number = cgv.g;
			var mi:Number = cgv.i;	var mj:Number = cgv.j;	var mk:Number = cgv.k;
			var mm:Number = cgv.m;	var mn:Number = cgv.n;	var mo:Number = cgv.o + cam._nearClipping;
			var cx:Number;	var cy:Number;	var cz:Number;
			var x:Number;	var y:Number;	var z:Number;
			var ct:Number = cam.t;
			var cs:Number = cam.s;
			
			
			for(var i:int=0; i<L; i++) {
				
				p = _p[i];
				x = p.x;	y = p.y;	z = p.z;
				
				p.wy = mb*x + mf*y + mj*z + mn;
				p.wx = ma*x + me*y + mi*z + mm;
				w = mc*x + mg*y + mk*z + mo;
				p.wz = w;
				
				if(w>0) {
					p.sy = cs - p.wy/w * cs;
					p.sx = ct + p.wx/w * ct;
				}else{
					p.sy = cs - p.wy * cs;
					p.sx = ct + p.wx * ct;
				}
				
				p.frameCounter1 = p.frameCounter2 = frameCounter;
				
				if(p is VertexCurved) {
					
					pc = VertexCurved( points[i] );
					x = pc.bx;	y = pc.by;	z = pc.bz;
					w = mc*x + mg*y + mk*z + mo;
					
					if(w!=0) {
						pc.bsx = ct + (ma*x + me*y + mi*z + mm)/w*ct;
						pc.bsy = cs - (mb*x + mf*y + mj*z + mn)/w*cs;
					}else{
						pc.bsx = ct + (ma*x + me*y + mi*z + mm)*ct;
						pc.bsy = cs - (mb*x + mf*y + mj*z + mn)*cs;
					}
				}
			}
			return false;
		}
	}
}