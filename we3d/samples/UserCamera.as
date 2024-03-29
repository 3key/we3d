package we3d.samples {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import we3d.we3d;
	import we3d.core.Camera3d;
	import we3d.scene.Scene3d;
	import we3d.view.View3d;

	use namespace we3d;
	
	public class UserCamera {
		
		public var rotateMouse:Boolean = true;
		public var rotateLocal:Boolean = false;
		public var moveLocal:Boolean = true;
		
		public var moveSpeedX:Number = 5;
		public var moveSpeedY:Number = 5;
		public var moveSpeedZ:Number = 5;
		public var rotateSpeedX:Number = .25;
		public var rotateSpeedY:Number = .25;
		
		public var keyForward:uint = 88;
		public var KEY_FORWARD:uint=38;
		public var KEY_BACKWARD:uint=40;
		public var KEY_LEFT:uint=37;
		public var KEY_RIGHT:uint=39;
		public var KEY_UP:uint=33;
		public var KEY_DOWN:uint=34;
		
		public var info:Function;
		public var camera:Camera3d;
		
		private var toggleTime:uint = 350;
		
		private var pressTime:uint = 0;
		
		private var view:View3d;
		private var mdown:Boolean=false;
		private var kdown:Boolean=false;
		private var tx:Number=0;
		private var ty:Number=0;
		private var keys:Array=[];
		private var rkeys:Array=[38,40,37,39,33,34];
		public var useMouse:Boolean;
		public var useKeyboard:Boolean;
		
		public function UserCamera (_view:View3d, gridScale:Number=1, _useMouse:Boolean=true, _useKeyboard:Boolean=true) {
			
			info = _info;
			
			view = _view;
			
			view.viewport.addEventListener(Event.ADDED_TO_STAGE, stageAdded);
			view.viewport.addEventListener(Event.REMOVED_FROM_STAGE, stageRemoved);
			
			moveSpeedX = gridScale;
			moveSpeedY = gridScale;
			moveSpeedZ = gridScale;
			
			useMouse = _useMouse;
			useKeyboard = _useKeyboard;
			
			if(view.viewport is Sprite) stageAdded(null);
		}
		
		private function stageAdded (e:Event) :void {
			if(view.viewport.stage != null) {
				
				if(e==null || e.target == view.viewport) {
					view.viewport.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
					
					if(useMouse) {
						view.viewport.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
						view.viewport.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
					}
					
					if(useKeyboard) {
						view.viewport.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
						view.viewport.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
					}
				}
			}
		}
		
		private function stageRemoved (e:Event) :void {
			if(view.viewport.stage != null) {
				if(e==null || e.target == view.viewport) {
					view.viewport.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
					
					if(useMouse) {
						mdown = false;
						view.viewport.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
						view.viewport.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
					}
					
					if(useKeyboard) {
						kdown = false;
						view.viewport.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
						view.viewport.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
					}
				}
			}
		}
		
		public function _info (str:String) :void {
			 trace(str);
		}
		
		public function enterFrameHandler (e:Event) :void {
			if(view.scene != null) {
				var scene:Scene3d = view.scene;
				var cam:Camera3d  = view.camera == null ? scene.cam : view.camera;
				
				if(mdown) {
					if(rotateMouse) {
						if(rotateLocal) {
							cam.transform.rotateOnAxis(cam.transform.yAxis, -(tx-view.viewport.mouseX)/100*rotateSpeedY);
							cam.transform.rotateOnAxis(cam.transform.xAxis, -(ty-view.viewport.mouseY)/100*rotateSpeedX);
						}else{
							cam.transform.rotationX -= (ty-view.viewport.mouseY)/100*rotateSpeedX;
							cam.transform.rotationY -= (tx-view.viewport.mouseX)/100*rotateSpeedY;
						}
						tx = view.viewport.mouseX;
						ty = view.viewport.mouseY;
						view.invalidate();
					}
				}
				if(kdown) {
					var L:uint = rkeys.length;
					for(var i:uint=0; i<L; i++) {
						var c:Boolean = keys[rkeys[i]];
						if(c) {
							var kc:uint = rkeys[i];
							switch(kc) {
								case KEY_FORWARD:
									if(moveLocal) {
										cam.transform.moveOnAxis(cam.transform.zAxis, moveSpeedZ);
									}else{
										cam.transform.z += moveSpeedZ;
									}
									view.invalidate();
									break;
								case KEY_BACKWARD:
									if(moveLocal) {
										cam.transform.moveOnAxis(cam.transform.zAxis, -moveSpeedZ);
									}else{
										cam.transform.z -= moveSpeedZ;
									}
									view.invalidate();
									break;
								case KEY_LEFT:
									if(moveLocal) {
										cam.transform.moveOnAxis(cam.transform.xAxis, -moveSpeedX);
									}else{
										cam.transform.x -= moveSpeedX;
									}
									view.invalidate();
									break;
								case KEY_RIGHT:
									if(moveLocal) {
										cam.transform.moveOnAxis(cam.transform.xAxis, moveSpeedX);
									}else{
										cam.transform.x += moveSpeedX;	
									}
									view.invalidate();
									break;
								case KEY_UP:
									if(moveLocal) {
										cam.transform.moveOnAxis(cam.transform.yAxis, moveSpeedY);
									}else{
										cam.transform.y += moveSpeedY;
									}
									view.invalidate();
									break;
								case KEY_DOWN:
									if(moveLocal) {
										cam.transform.moveOnAxis(cam.transform.yAxis, -moveSpeedY);
									}else{
										cam.transform.y -= moveSpeedY;
									}
									view.invalidate();
									break;
									
								default:
									break;
							}
						}
					}
					
				}
			}
			
		}
		
		public function destroy () :void {
			stageRemoved(null);
		}
		
		private function mouseDownHandler (e:Event) :void {
			tx = view.viewport.mouseX;
			ty = view.viewport.mouseY;
			mdown = true;
		}
		
		private function mouseUpHandler (e:Event) :void {
			mdown = false;
		}
		
		private function keyDownHandler (e:KeyboardEvent) :void {
			kdown = true;
			var kc:uint = e.keyCode;
			var L:uint = keys.length;
			keys[kc] = true;
		}
		
		private function keyUpHandler (e:KeyboardEvent) :void {
			var kc:uint = e.keyCode;
			keys[kc] = false;
		}
		
	}
}