package we3d.core.transform 
{
	import we3d.we3d;
	import we3d.animation.IChannel;
	import we3d.animation.PropertyAnimator;

	use namespace we3d;
	
	/**
	* The Animated transform enables keyframe features. Use the addChannel and removeChannel methods to add keyframe channels to the transform
	*/
	public class Animated extends Transform3d 
	{
		public function Animated () {}
		
		/** 
		* Disable/Enable animated properties
		*/
		public var animated:Boolean = true;
		/**
		* @private
		* Array with registered PropertyAnimators
		*/
		protected var pas:Vector.<PropertyAnimator> = new Vector.<PropertyAnimator>();
		
		/**
		* @private
		* Reference Object to ids in the pas Array
		*/
		protected var regPas:Object = {};
		
		public function getPropertyAnimator (uid:String="") :PropertyAnimator {
			return regPas[uid];
		}
		
		/**
		* Create a EnvelopeChannel in the transform. EnvelopeChannels are timelines for numeric properties. <br/>
		* The property to animate don't have to be inside the object3d. <br/>
		* <code><pre>
		*   var ec:EnbelopeChannel = new EnbelopeChannel();
		* 	obj.transform.addChannel( _root, "myVar", "_root_myVar", ec);
		* </pre></code>
		* 
		* @param	tgt	The Target Object where the property is located
		* @param	propName The name of the property to animate
		* @param	uid	Uniqe String ID for the new Envelope Channel, if a channel with the id is available it will be returned instead of creating a second one with the same id
		* @return	the new PropertyAnimator
		*/
		public function addChannel (tgt:Object, propName:String, uid:String, ec:IChannel) :PropertyAnimator {
			if(regPas[uid] != null) {
				return pas[regPas[uid]];
			}else{
				var L:int = pas.length;
				for(var i:int=0; i<L; i++) {                
					if(pas[i].target == tgt && pas[i].prop == propName) {
						return pas[i];
					}
				}
			}
			
			pas.push(new PropertyAnimator(tgt, propName, ec));
			regPas[uid] = pas.length-1;
			
			return pas[pas.length-1];
		}
		
		/**
		 * Remove a channel from the transform.
		 * @param	tgt	The Target Object where the animated property is located
		 * @param	propName The name of the property to animate
		 * @param	uid The unique id of the PropertyAnimator
		 * @return	true if the PropertyAnimator was found and deleted
		 */
		public function removeChannel (tgt:Object, propName:String, uid:String) :Boolean {
			var L:int = pas.length;
			for(var i:int=0; i<L; i++) {
				if(pas[i].target == tgt && pas[i].prop == propName) {
					pas.splice(i, 1);
					delete regPas[uid];
					
					for(var k:String in regPas) {
						if(regPas[k]>i) regPas[k]--;
					}
					return true;
				}
			}
			return false;
		}
		
		/**
		* @private
		*/
		we3d function initTimeline (f:Number) :void {
			var L:int = pas.length;
			
			if(L > 0) {
				var p:PropertyAnimator;
				
				for(var i:int=0; i<L; i++) {
					p = pas[i];
					p.target[p.prop] = p.env.getValue(f);
				}
			}
		}
		
		public override function initFrame (f:Number) :void {
			if(animated) initTimeline(f);
		}
		
		public override function clone ():Transform3d {
			var r:Animated = new Animated();
			r.transform = transform;
			r.pas = pas;
			r.regPas = regPas;
			
			return Transform3d(r);
		}
	}
}