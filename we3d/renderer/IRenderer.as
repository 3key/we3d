package we3d.renderer 
{
	import we3d.we3d;
	import we3d.renderer.RenderSession;

	use namespace we3d;
	
	/**
	 * The interface for a WE3D renderer
	 */ 
	public interface IRenderer {
		function draw (session:RenderSession) :void;
	}
}