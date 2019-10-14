﻿package we3d.filter {	import we3d.renderer.RenderSession;	import we3d.layer.Layer;		/**	* Filters can be added to a View3d. Most filters operates on the Layers of a View like the Blur Filter, 	* but they can be used to modify the scene or provide internal data like the ZBuffer filter. <br/><br/>	* 	* Filters are initialized by a View before and after every render with the initFrame and endFrame methods of a filter. <br/><br/>	* 	* Use the view.addFilter method to add a filter to a View. 	* The view processes the Filters in the order they have been registered. <br/><br/>	* 	* The BackgroundFilter class is the abstact Base Class for all filters. 	*/	public class BackgroundFilter 	{		public function BackgroundFilter () {}				/**		* If enabled is false, the filter is ignored by all Views it is registered to		*/		public var enabled:Boolean=true;		/**		* If null, the filter is applied to all layers in the view, otherwise to all layers in the layers array		*/		public var layers:Vector.<Layer>;		/**		* Called when a filter is added to a View		* @param	we	the View		*/		public function initialize (session:RenderSession) :void {}		/**		* Called when a filter is removed from a View		* @param	we	the View		*/		public function remove (session:RenderSession) :void {}		/**		* Called before rendering a frame		* @param	we	the View		*/		public function initFrame (session:RenderSession) :void {}		/**		* Called after rendering a frame.		* @param	we	the View		*/		public function endFrame (session:RenderSession) :void {}	}}