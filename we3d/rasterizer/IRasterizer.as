package we3d.rasterizer 
{
	import we3d.renderer.RenderSession;
	import we3d.material.Surface;
	import we3d.mesh.Face;
	/**
	 * The interface for a WE3D rasterizer
	 */ 
	public interface IRasterizer {
		function draw (material:Surface, session:RenderSession, f:Face) :void;
		function clone () :IRasterizer;
	}
}