package we3d.rasterizer 
{
	import we3d.filter.ZBuffer;
	/**
	 * @private
	 */
	public class RasterizerZBuffer extends Rasterizer 
	{
		public function RasterizerZBuffer () {}
		
		/**
		* Set the ZBuffer filter
		*/
		public function set zBuffer (zb:ZBuffer) :void {
			zbuffer = zb;
		}
		public function get zBuffer () :ZBuffer {
			return zbuffer;
		}
		
		protected var zbuffer:ZBuffer;
	}
}