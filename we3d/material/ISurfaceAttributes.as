package we3d.material 
{
	import we3d.mesh.Face;
	import we3d.renderer.RenderSession;

	public interface ISurfaceAttributes
	{
		/** Clone the surface attributes */
		function clone () :ISurfaceAttributes;
	}
}
