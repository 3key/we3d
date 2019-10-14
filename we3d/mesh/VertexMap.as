package we3d.mesh 
{
	/**
	 * @private
	 */ 
	public class VertexMap 
	{
		function VertexMap () {
			map = [];
		}
		
		public var map:Array;
		public var dim:int = 2;
		
		public function addUvCoord (id:int, u:Number, v:Number) :void {
			map.push(id, u, v);
		}
		
		public function getStartId (id:int) :int {
			var ofs:int = dim+1;
			for(var i:int=0; i<map.length; i+=ofs) {
				if(map[i] == id) {
					return i;
				}
			}
			return -1;
		}
		
	}
}
