package we3d.core.transform
{
	import we3d.we3d;
	import we3d.core.Object3d;
	import we3d.core.transform.AnimatedAll;
	import we3d.math.Matrix3d;
	import we3d.math.Vector3d;

	use namespace we3d;
	
	/**
	* The All transform provides all the features from the 3.0 release
	*/
	public class All extends AnimatedAll 
	{
		function All () {}
		
		/**
		* Up Vector, if target is set
		*/
		public var lookAtYAxis:Vector3d;
		/**
		* If true, the up vector for targeting is the current yAxis when the target is set.
		*/
		public var targetWithDirection:Boolean = false;
		/**
		* @private
		*/
		we3d var lookAtTarget:Object3d;
		/**
		* @private
		*/
		we3d var lookAt:Boolean;
		
		/**
		* Enable or disable targeting <br/>
		* If a target object is set, the rotation is controlled by the target. If null is set, targeting is disabled
		*/
		public function set target (obj:Object3d) :void {
			if(obj == null) {
				if(lookAt) {
					updateRotation(tgv);
				}
				lookAt = false;
			}
			else {
				lookAt = true;
				lookAtTarget = obj;
				
				if(lookAtYAxis == null) lookAtYAxis = new Vector3d(0,1,0);
				
				if(targetWithDirection) {
					lookAtYAxis.x = gv.e;
					lookAtYAxis.y = gv.f;
					lookAtYAxis.z = gv.g;
				}
			}
		}
		public function get target () :Object3d {
			return lookAtTarget;
		}

		/**
		* @private
		*/
		we3d function initLookAtAxis (f:Number) :void {
			
			var lgv:Matrix3d = lookAtTarget.transform.gv;
			var zAxisx:Number = lgv.m - gv.m;
			var zAxisy:Number = lgv.n - gv.n;
			var zAxisz:Number = lgv.o - gv.o;
			
			var mag:Number = Math.sqrt(zAxisx*zAxisx + zAxisy*zAxisy + zAxisz*zAxisz);
			if(mag > 0) {
				zAxisx/=mag;
				zAxisy/=mag;
				zAxisz/=mag;
			}else{
				zAxisx = 0;
				zAxisy = 0;
				zAxisz = 1;
			}
			
			var yAxisx:Number = lookAtYAxis.x;
			var yAxisy:Number = lookAtYAxis.y;
			var yAxisz:Number = lookAtYAxis.z;
			
			var fDot:Number = yAxisx*zAxisx + yAxisy*zAxisy + yAxisz*zAxisz;
			yAxisx = yAxisx - (fDot*zAxisx);
			yAxisy = yAxisy - (fDot*zAxisy);
			yAxisz = yAxisz - (fDot*zAxisz);
			
			mag = Math.sqrt(yAxisx*yAxisx + yAxisy*yAxisy + yAxisz*yAxisz);	
			yAxisx/=mag;
			yAxisy/=mag;
			yAxisz/=mag;
			
			var xAxisx:Number = yAxisy*zAxisz-yAxisz*zAxisy;
			var xAxisy:Number = yAxisz*zAxisx-yAxisx*zAxisz;
			var xAxisz:Number = yAxisx*zAxisy-yAxisy*zAxisx;
			
			mag = Math.sqrt(xAxisx*xAxisx + xAxisy*xAxisy + xAxisz*xAxisz);	
			xAxisx/=mag;
			xAxisy/=mag;
			xAxisz/=mag;
			
			if(_parent != null) {
				var g:Matrix3d = _parent.gv;
				
				var rgma:Number = g.a;	var rgme:Number = g.b;	var rgmi:Number = g.c;
				var rgmb:Number = g.e;	var rgmf:Number = g.f;	var rgmj:Number = g.g;
				var rgmc:Number = g.i;	var rgmg:Number = g.j;	var rgmk:Number = g.k;
				
				var px:Number = xAxisx;
				var py:Number = xAxisy;
				var pz:Number = xAxisz;
				
				xAxisx = rgma*px + rgme*py + rgmi*pz;
				xAxisy = rgmb*px + rgmf*py + rgmj*pz;
				xAxisz = rgmc*px + rgmg*py + rgmk*pz;
				
				px = yAxisx;
				py = yAxisy;
				pz = yAxisz;
				
				yAxisx = rgma*px + rgme*py + rgmi*pz;
				yAxisy = rgmb*px + rgmf*py + rgmj*pz;
				yAxisz = rgmc*px + rgmg*py + rgmk*pz;
				
				px = zAxisx;
				py = zAxisy;
				pz = zAxisz;
				
				zAxisx = rgma*px + rgme*py + rgmi*pz;
				zAxisy = rgmb*px + rgmf*py + rgmj*pz;
				zAxisz = rgmc*px + rgmg*py + rgmk*pz;
			}
			
			tgv.a = xAxisx;	tgv.b = xAxisy; tgv.c = xAxisz;
			tgv.e = yAxisx;	tgv.f = yAxisy; tgv.g = yAxisz;
			tgv.i = zAxisx;	tgv.j = zAxisy; tgv.k = zAxisz;
		}

		/** 
		* @private
		*/
		public override function initFrame (f:Number) :void {
			
			var t:Matrix3d = tgv;
			
			if(animated) {
				
				initTimeline(f);
				
				if(lookAt) {
					if(_parent != null) {
						lookAt = false;
						initFrame(f);
						lookAt = true;
					}
					if(lookAtTarget.transform._parent != null && lookAtTarget.frameCounter != FCounter) {
						lookAtTarget.transform.initFrame(f);
					}
					initLookAtAxis(f);
					updateRotation(t);
				}
			}
			
			var scx:Number = scaleX;
			var scy:Number = scaleY;
			var scz:Number = scaleZ;
			var rv:Matrix3d = gv;
			
			if(_parent != null) {
				var ta:Number = t.a*scx;	var tb:Number = t.b*scx;	var tc:Number = t.c*scx;
				var te:Number = t.e*scy;	var tf:Number = t.f*scy;	var tg:Number = t.g*scy;
				var ti:Number = t.i*scz;	var tj:Number = t.j*scz;	var tk:Number = t.k*scz;
				var tm:Number = t.m;		var tn:Number = t.n;		var to:Number = t.o;
				
				var mat:Matrix3d = _parent.gv;
				
				rv.a = ta*mat.a + tb*mat.e + tc*mat.i;
				rv.b = ta*mat.b + tb*mat.f + tc*mat.j;
				rv.c = ta*mat.c + tb*mat.g + tc*mat.k;
					
				rv.e = te*mat.a + tf*mat.e + tg*mat.i;
				rv.f = te*mat.b + tf*mat.f + tg*mat.j;
				rv.g = te*mat.c + tf*mat.g + tg*mat.k;
					
				rv.i = ti*mat.a + tj*mat.e + tk*mat.i;
				rv.j = ti*mat.b + tj*mat.f + tk*mat.j;
				rv.k = ti*mat.c + tj*mat.g + tk*mat.k;
					
				rv.m = tm*mat.a + tn*mat.e + to*mat.i + mat.m;
				rv.n = tm*mat.b + tn*mat.f + to*mat.j + mat.n;
				rv.o = tm*mat.c + tn*mat.g + to*mat.k + mat.o;
			}
			else {
				rv.a = t.a*scx;	rv.b = t.b*scx;	rv.c = t.c*scx;
				rv.e = t.e*scy;	rv.f = t.f*scy;	rv.g = t.g*scy;
				rv.i = t.i*scz;	rv.j = t.j*scz;	rv.k = t.k*scz;
				rv.m = t.m;		rv.n = t.n;		rv.o = t.o;
			}
		}
		
		public override function clone ():Transform3d {
			var r:All = new All();
			r.transform = transform;
			r.target = target;
			r.parent = parent;
			r.regPas = regPas;
			r.pas = pas;
			return Transform3d(r);
		}
	}
}
