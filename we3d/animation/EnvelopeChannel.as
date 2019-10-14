package we3d.animation 
{
	import we3d.animation.modifier.IModifier;
	import we3d.animation.LinearChannel;
	import we3d.animation.KeyFrame;
	
	/**
	* EnvelopeChannel provides numeric animation with keyframes.<br/><br/>
	* Every keyframe can have a unique easing method. Use the storeFrame method of the LinearChannel class to add keyframes to the channel:
	* <code>
	* var ec:EnvelopeChannel = new EnvelopeChannel();
	* ec.storeFrame( 100, 3.1415 );
	* trace( ec.getValue(50) ); 
	* </code>
	*/
	public class EnvelopeChannel extends LinearChannel implements IModifier 
	{
		public function EnvelopeChannel () {
			enableModifiers(false);
			useEasing(false, null);
		}
		
		/** 
		* @private
		* Default easing function for all Keyframes without individual easing 
		*/
		public var easeFunc:Function;
		/** 
		* @private
		* Read Only, true if easing is enabled
		*/
		public var easing:Boolean;
		/**
		* @private
		*/
		protected var _modifiers:Array;
		/**
		* @private
		*/
		protected var modifiersEnabled:Boolean;
		
		/** 
		* Enable or disable easing
		* @param	val				True if easing should be enabled
		* @param	defaultEasing	default ease function
		*/
		public function useEasing (val:Boolean=false, defaultEasing:*=null) :void {
			
			if(typeof(defaultEasing) == "function") {
				easeFunc = defaultEasing;
			}
			
			if(val) {
				easing = true;
				addModifier(this);
				enableModifiers(true);
			}else{
				easing = false;
				removeModifier(this);
			}
		}
		
		/**
		* Returns the value at a frame
		* @param	frame the frame
		* @return
		*/
		public override function getValue (frame:Number) :Number {
			
			if(loop) {
				if(frame > totalframes) {
					var fn:Number = frame/totalframes;
					var f:int = fn;
					frame = fn-f == 0 ? totalframes : frame - (totalframes*f);
				}
			}
			
			var fi:int;
			
			if(frame >= totalframes) {
				fi = keyFrames.length-1;
			}else if(frame < 1) {
				fi = 0;
			}else{
				
				if(typeof keyFrameTable["k"+frame] != "number") {
					var lndx:int = 0;
					for(var i:int=keyFrames.length-1; i>=0; i--) {
						if(keyFrames[i].frame < frame) {
							lndx = i;
							break;
						}	
					}
						
					var lowKey:KeyFrame = keyFrames[lndx];
					var hiKey:KeyFrame = keyFrames[lndx+1];
					
					var rv:Number = (((hiKey.value - lowKey.value) / (hiKey.frame - lowKey.frame))*(frame-lowKey.frame))+lowKey.value;
					
					return modifiersEnabled ? evaluateModifiers(frame, rv, -1, lndx) : rv;
				} 
				else{
					fi = keyFrameTable["k"+frame];
				}
			}
			
			return modifiersEnabled ? evaluateModifiers(frame, keyFrames[fi].value, fi, -1) : keyFrames[fi].value;
		}
		
		/**
		* @private
		*/
		public function evaluate (f:Number, v:Number, keyframe:int, lowkeyframe:int) : Number {
			if(keyframe == -1) {
				var lkf:KeyFrame = keyFrames[lowkeyframe];
				var hkf:KeyFrame = keyFrames[lowkeyframe +1];
				
				var ef:Function;
				
				if(hkf.easeFunc != null) ef = hkf.easeFunc;
				else ef = easeFunc;
				
				return  ef((f-lkf.frame), lkf.value, hkf.value-lkf.value, (hkf.frame-lkf.frame));  // Return the new value
			}
			return v;
		}
		
		/**
		* Sets the easing method of a keyframe
		* @param	keyframe	the keyframe with easing activated
		* @param	ease_func	a function that do the easing
		*/
		public function setKeyEasing (keyframe:Number, ease_func:*=undefined) :void {
			keyFrames[keyFrameTable["k" + keyframe]].easeFunc = ease_func;
		}
		
		/** 
		* Modifiers overrides the value of the Timeline. <br/>
		* Modifiers are objects with an evaluate function <br/>
		* @param 	obj		a object with an evaluate method: evaluate(frame:Number, value:Number, keyframe:Object, lowKeyframe:Object) : Number 
		*/
		public function addModifier (obj:IModifier) :void {
			if(_modifiers == null) {
				_modifiers = [];
			}else{
				var L:int = _modifiers.length;
				for(var i:int=0; i<L; i++) {
					if(_modifiers[i] == obj) {
						return;
					}
				}
			}
			_modifiers.push(obj);
		}
				
		/**
		* Removes a modifier 
		*/
		public function removeModifier (obj:IModifier) :void {
			if(_modifiers != null) {
				var L:int = _modifiers.length;
				for(var i:int=0; i<L; i++) {
					if(_modifiers[i] == obj) {
						_modifiers.splice(i,1);
					}
				}
			}
		}
		
		/** 
		* Enable or disable modifier evaluation 
		*/
		public function enableModifiers (enabledValue:Boolean=false) :void {
			modifiersEnabled = enabledValue;
		}
		
		private function evaluateModifiers (frame:Number, value:Number, kf:int, lkf:int) :Number {
			var mval:Number = value;
			var L:int = _modifiers.length;
			
			for(var i:int=0; i<L; i++){
				mval = _modifiers[i].evaluate(frame, mval, kf, lkf);
			}
			
			return mval;
		}
		
	}
}