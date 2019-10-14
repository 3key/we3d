package we3d.layer 
{
	public class LayerType
	{
		
		/**
		 * Layer type for addLayer method, Sorted layers are sorted with other layers by the average depth of all polygons in the layer
		 */
		public static const SORTED:String = "sorted";
		/**
		 * Layer type for addLayer method, Foreground layers are always in front of background and sorted layers, multiple foreground layers appear in the order they have been added to the View
		 */
		public static const FOREGROUND:String = "foreground";
		/**
		 * Layer type for addLayer method, Background layers are always behind all other layers, multiple background layers appear in the order they have been added to the View
		 */
		public static const BACKGROUND:String = "background";
		
	}
}