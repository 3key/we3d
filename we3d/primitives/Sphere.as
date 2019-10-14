package we3d.primitives {
	
	import we3d.we3d;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	import we3d.mesh.UVCoord;
	import we3d.mesh.Vertex;

	use namespace we3d;
	
	/**
	 * A Sphere primitive
	 */ 
	public class Sphere extends BasePrimitive
	{
		public var surface:Surface;
		/** Number of segments horizontally. Defaults to 8 */
		public var segmentsW:Number;
		/** Number of segments vertically. Defaults to 6 */
		public var segmentsH:Number;
		 
		/** Minimum value of segmentsW */
		static public var MIN_SEGMENTSW :Number = 3;
		/** Minimum value of segmentsH */
		static public var MIN_SEGMENTSH :Number = 2;
	
		
		public function Sphere( material:Surface=null, radius:Number=100, segmentsW:int=8, segmentsH:int=6 )
		{
			surface = material || new Surface();
			
			buildSphere( radius, segmentsW, segmentsH );
		}
	
		public function buildSphere ( fRadius:Number=100, segmentsW:int=8, segmentsH:int=6 ):void
		{
			this.segmentsW = segmentsW; // Defaults to 8
			this.segmentsH = segmentsH; // Defaults to 6
			
			this.points = new Vector.<Vertex>;
			this.polygons = Vector.<Face>;
			
			objectCuller.reset();
			
			var i:Number, j:Number, k:Number;
			
			var iHor:Number = Math.max(3,this.segmentsW);
			var iVer:Number = Math.max(2,this.segmentsH);
			
			var aVertice:Vector.<Vertex> = this.points;
			var aFace:Vector.<Face> = this.polygons;
			var aVtc:Array = new Array();
			
			for (j=0;j<(iVer+1);j++) 
			{ // vertical
			
				var fRad1:Number = Number(j/iVer);
				var fZ:Number = -fRadius*Math.cos(fRad1*Math.PI);
				var fRds:Number = fRadius*Math.sin(fRad1*Math.PI);
				var aRow:Array = new Array();
				var oVtx:Vertex;
				
				for (i=0;i<iHor;i++) { // horizontal
					var fRad2:Number = Number(2*i/iHor);
					var fX:Number = fRds*Math.sin(fRad2*Math.PI);
					var fY:Number = fRds*Math.cos(fRad2*Math.PI);
					if (!((j==0||j==iVer)&&i>0)) { // top||bottom = 1 vertex
						oVtx = new Vertex(fY,fZ,fX);
						aVertice.push(oVtx);
						objectCuller.testPoint( fY,fZ,fX );
					}
					aRow.push(oVtx);
				}
				aVtc.push(aRow);
			}
			
			var fc:Face;
			var iVerNum:int = aVtc.length;
			
			for (j=0;j<iVerNum;j++) {
				var iHorNum:int = aVtc[j].length;
				if (j>0) {
					for (i=0;i<iHorNum;i++) {
						// select vertices
						var bEnd:Boolean = i==(iHorNum-0);
						var aP1:Vertex = aVtc[j][bEnd?0:i];
						var aP2:Vertex = aVtc[j][(i==0?iHorNum:i)-1];
						var aP3:Vertex = aVtc[j-1][(i==0?iHorNum:i)-1];
						var aP4:Vertex = aVtc[j-1][bEnd?0:i];
						
						var fJ0:Number = j		/ (iVerNum-1);
						var fJ1:Number = (j-1)	/ (iVerNum-1);
						var fI0:Number = (i+1)	/ iHorNum;
						var fI1:Number = i		/ iHorNum;
						var aP4uv:UVCoord = new UVCoord(fI0,fJ1);
						var aP1uv:UVCoord = new UVCoord(fI0,fJ0);
						var aP2uv:UVCoord = new UVCoord(fI1,fJ0);
						var aP3uv:UVCoord = new UVCoord(fI1,fJ1);
						
						// 2 faces
						if (j<(aVtc.length-1))	{
							fc = new Face()
							fc.surface = surface
							fc.vtxs = new Vector.<Vertex>([aP1,aP2,aP3]);
							fc.uvs = new Vector.<UVCoord>([aP1uv,aP2uv,aP3uv]);
							fc.init(this);
							aFace.push( fc );
						}
						if (j>1) {
							fc = new Face()
							fc.surface = surface;
							fc.vtxs = new Vector.<Vertex>([aP1,aP3,aP4]);
							fc.uvs = new Vector.<Vertex>([aP1uv,aP3uv,aP4uv]);
							fc.init(this);
							aFace.push( fc );
						}
					}
				}
			}
			
			
		}
	}
}