﻿package we3d.primitives {	import we3d.renderer.RenderSession;	import we3d.scene.SceneObject;	 	public class BasePrimitive extends SceneObject 	{		public function BasePrimitive () {}				/**		* @private		*/		protected var recreate:Boolean=true;		/**		* @private		*/		public function invalidate () :void {			recreate = true;		}		/**		* @private		*/		public override function initFrame(session:RenderSession) :Boolean {			if(recreate) updateGeometry();			return super.initFrame(session);		}		/**		* @private		*/		public function updateGeometry () :void {}	}}