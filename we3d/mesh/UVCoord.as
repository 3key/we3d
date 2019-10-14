package we3d.mesh 
{
	/** 
	* UV Cooords are used to map bitmaps to polygons. <br/>
	* Add UV Coordinates on a face: <br/>
	* <code><pre>
	*   obj.polygons[0].addUvCoord(0,1);
	* </pre></code>
	*/
	public class UVCoord 
	{
		public function UVCoord (_u:Number=0, _v:Number=0) {
			u = _u;
			v = _v;
		}
		
		public var u:Number;
		public var v:Number;
		
		public function clone () :UVCoord {
			return new UVCoord(u,v);
		}
	}
}