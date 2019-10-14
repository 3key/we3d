package we3d.rasterizer 
{
	import we3d.we3d;
	import we3d.filter.ZBuffer;

	use namespace we3d;
	
	/**
	 * @private
	 */
	public class RasterizerZBufferLight extends RasterizerLight 
	{
		public function RasterizerZBufferLight () {}
		
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