 package we3d.mesh 
{
	import we3d.we3d;
	import we3d.core.Object3d;
	import we3d.material.Surface;
	import we3d.math.Plane;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	* Faces are the polygons of a scene object
	*/
	public class Face 
	{
		public function Face () {}
		
		/** 
		* The material of the face 
		*/
		public var surface:Surface;
		/** 
		* Avarage center of the polygon
		*/
		public var ax:Number=0;		public var ay:Number=0;		public var az:Number=0;
		/**
		* The normal of the face
		*/
		public var normal:Vertex=new Vertex();
		/**
		* The sortFar is added to the depth value for polygon sorting with Flash 10 Renderer
		*/
		public var sortFar:Number=0;
		/**
		* @private
		* References to the first 3 Points in the Polygon
		*/
		public var a:Vertex;
		/**
		* @private
		*/
		public var b:Vertex;
		/**
		* @private
		*/
		public var c:Vertex;
		/**
		* @private
		* References to the points
		*/
		public var vtxs:Vector.<Vertex>;
		/**
		* UV Coords
		*/
		public var uvs:Vector.<UVCoord>;
		
		/**
		* @private
		* depth value in camera space
		*/
		public var z:Number=0;
		/**
		* Vertice count, have to be the same length like the vertices
		*/
		public var vLen:int=0;
		
		public var so:Object3d;
		public var u1:Number=0;		public var u2:Number=0;		public var u3:Number=0;
		public var v1:Number=0;		public var v2:Number=0;		public var v3:Number=0;
		public var frameCounter:int=-1;
		private var plane:Plane;
		
		public function getPlane () :Plane {
			if(plane==null) plane = new Plane();
			plane.create(a,b,c);
			return plane;
		}
		
		public function clearPoint ( id:int, updateNormal:Boolean = false ) :Boolean {
			
			if(id >= 0 && id < vtxs.length) 
			{
				vtxs.splice( id, 1 );
				vLen = vtxs.length;
				if( uvs && id < uvs.length ) uvs.splice( id, 1 );

				if( id < 3 ) {
					if(vLen > 0)  a = vtxs[0];	
					if(vLen > 1)  b = vtxs[1];
					if(vLen > 2)  c = vtxs[2];
					if(uvs.length > 0) {
						u1 = uvs[0].u;
						v1 = uvs[0].v;
					}
					if(uvs.length > 1) {
						u2 = uvs[1].u;
						v2 = uvs[1].v;
					}
					if(uvs.length > 2) {
						u3 = uvs[2].u;
						v3 = uvs[2].v;
					}
				}
				
				// update averag center
				ax = ay = az = 0;
				for(var i:int=0; i < vLen; i++) {
					ax += vtxs[i].x;
					ay += vtxs[i].y;
					az += vtxs[i].z;
				}
				ax /= vLen;
				ay /= vLen;
				az /= vLen;
				
				if( updateNormal && vLen > 2 ) 
				{
					var x1:Number = b.x-a.x;	
					var y1:Number = b.y-a.y;	
					var z1:Number = b.z-a.z;
					
					var x2:Number = c.x-a.x;		
					var y2:Number = c.y-a.y;		
					var z2:Number = c.z-a.z;
					
					normal.x = y1 * z2 - z1 * y2;
					normal.y = z1 * x2 - x1 * z2;
					normal.z = x1 * y2 - y1 * x2;
					
					x1 = -Math.sqrt(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z);
					normal.x /= x1;		
					normal.y /= x1;		
					normal.z /= x1;
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		* Initialize the polygon
		* updates the center and the normal of the polygon
		* and pre calculate some properties for rendering
		*/
		public function init (obj:Object3d) :void {
			
			so = obj;
			
			if(vtxs != null) {
				
				var L:int = vtxs.length;
				vLen = L;
				
				if(L > 0) {
					
					a = vtxs[0];
					
					if(L > 1) {
						
						b = vtxs[1];
						ax = ay = az = 0;
						
						var p:Vertex;
						var i:int;
						
						for(i=0; i<L; i++) {
							p = vtxs[i];
							ax += p.x;
							ay += p.y;
							az += p.z;
						}
						
						ax /= L;
						ay /= L;
						az /= L;
						
						if(L > 2) {
							
							c = vtxs[2];
							
							var x1:Number = b.x-a.x;	
							var y1:Number = b.y-a.y;	
							var z1:Number = b.z-a.z;
							
							var x2:Number = c.x-a.x;		
							var y2:Number = c.y-a.y;		
							var z2:Number = c.z-a.z;
							
							normal.x = y1 * z2 - z1 * y2;
							normal.y = z1 * x2 - x1 * z2;
							normal.z = x1 * y2 - y1 * x2;
							
							x1 = -Math.sqrt(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z);
							normal.x /= x1;
							normal.y /= x1;
							normal.z /= x1;
							
						}
					}
				}
			}
			
		}
		
		/**
		* Add a UV Texture Coordinate the the polygon
		* UV values belongs to the vertex with the same index in the vtxs and uvs array
		*/
		public function addUvCoord (u:Number=0, v:Number=0) :int 
		{
			if(uvs == null) uvs = new Vector.<UVCoord>;
			var L:int = uvs.push(new UVCoord(u, v));
			if(L == 1) 
			{
				u1 = u;
				v1 = v;
			}
			else if(L==2) 
			{
				u2 = u;
				v2 = v;
			}
			else if(L==3) 
			{
				u3 = u;
				v3 = v;
			}
			
			return L-1;
		}
		
		/**
		 * Set a UV Texture Coordinate in the polygon
		 */
		public function setUvCoordAt ( id:uint, uv:UVCoord ) :void 
		{
			if(uvs == null) uvs = new Vector.<UVCoord>();
			
			uvs[id] = uv;
			
			if(id == 0) 
			{
				u1 = uv.u;
				v1 = uv.v;
			}
			else if(id == 1) 
			{
				u2 = uv.u;
				v2 = uv.v;
			}
			else if(id == 2) 
			{
				u3 = uv.u;
				v3 = uv.v;
			}
			
		}
		
		/**
		 * Set UV Texture Coordinates
		 */
		public function setUvCoords ( uv:Vector.<UVCoord> ) :void 
		{
			if( uv ) {
				if( uv.length > 0 ) {
					u1 = uv[0].u;
					v1 = uv[0].v;
				}else{
					u1 = v1 = 0;
				}
				
				if( uv.length > 1 ) {
					u2 = uv[1].u;
					v2 = uv[1].v;
				}else{
					u2 = v2 = 0;
				}
				
				if( uv.length > 2 ) {
					u3 = uv[2].u;
					v3 = uv[2].v;
				}else{ 
					u3 = v3 = 0;
				}
			}else{
				u1 = v1 = u2 = v2 = u3 = v3 = 0;
			}
			
			uvs = uv;
		}
		
		public function clone () :Face {
			var i:int;
			var r:Face = new Face();
			r.surface = surface;
			r.sortFar = sortFar;
			r.vLen = vLen;
			if(vtxs) {
				r.vtxs = new Vector.<Vertex>();
				for(i=0; i<vtxs.length; i++) {
					r.vtxs.push( vtxs[i] );
				}
			}
			if(uvs) {
				r.uvs = new Vector.<UVCoord>();
				for(i=0; i<uvs.length; i++) {
					r.uvs.push( uvs[i].clone() );
				}
			}
			return r;
		}
	
	}
}
