package we3d.ui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import we3d.ui.Ctrl;
	//import we3d.ui.ctrl.icons.ResizeIcon;
	
	dynamic public class WEWindow extends Ctrl 
	{
		public function WEWindow () {}
		
		public static var LIGHT_COLOR:int=0xa0a0a0;
		public static var SHADOW_COLOR:int=0x323232;
		public static var TITLE_BG_COLOR:int=0xafafaf ;
		public static var TITLE_BG_COLOR_2:int=0x7f7f7f;
		public static var TITLE_COLOR:int=0x323232;
		public static var CLOSEBUTTON_COLOR:int=0xcfcfcf;// orig 0xffd0d0
		public static var CLOSEBUTTON_COLOR_2:int=0x999999;// orig 0xff0000
		public static var RESIZE_COLOR:int=0x323232;
		public var minContentWidth:Number = 4;
		public var minContentHeight:Number = 4;
		
		public var title_tf:TextField;
		public var titleBar:Sprite;
		public var closeButton:Sprite;
		public var content:Sprite;
		public var bgmc:Sprite;
		
		public var defaultMenu:Boolean = false;
		
		public var initW:Number=0;
		public var initH:Number=0;
		
		public var stringId:String="";
		
		public var borderLeft:Number = 8;
		public var borderRight:Number = 8;
		public var borderTop:Number = 6;
		public var borderBottom:Number = 8;
		
		public var dragAlpha:Number = 0.5;
		
		public var titleHeight:int=17;
		
		private var _winDragable:Boolean = true;
		private var _dragable:Boolean = true;
		
		private var _resizable:Boolean=false;
		private var resizeButton:Sprite;
		private var resizeStartX:Number=0;
		private var resizeStartW:Number=0;
		private var resizeStartY:Number=0;
		private var resizeStartH:Number=0;
		
		public function get minWidth () :Number {	return minContentWidth + borderLeft*2;	}
		public function get minHeight () :Number {	return minContentHeight + borderTop*2 + titleHeight;	}
		
		public function set contentBorder (b:Number) :void { borderLeft = borderRight = borderTop = borderBottom = b; }
		
		private var _showBg:Boolean = true;
		public function showBg (v:Boolean) :void 
		{
			_showBg = v;
			if(v) {
				if(bgmc != null && !contains(bgmc)) addChild(bgmc);
			}else{
				if(bgmc != null && contains(bgmc)) removeChild(bgmc);
			}
		}
		
		private var _showTitle:Boolean = true;
		public function showTitle (v:Boolean) :void 
		{
			_showTitle = v;
			if(v) {
				if(titleBar != null && !contains(titleBar)) addChild(titleBar);
				if(title_tf != null && !contains(title_tf)) addChild(title_tf);
				if(closeButton != null && !contains(closeButton)) addChild(closeButton);
			}else{
				if(titleBar != null && contains(titleBar)) removeChild(titleBar);
				if(title_tf != null && contains(title_tf)) removeChild(title_tf);
				if(closeButton != null && contains(closeButton)) removeChild(closeButton);
			}
		}
		
		public function set title (v:String) :void {
			if(title_tf != null) {
				title_tf.text = v;
				title_tf.width = title_tf.textWidth+4;
			}
		}
		public function get title ():String {
			if(title_tf != null) {
				return title_tf.text;
			}
			return "";
		}
		
		public function clearContent () :void {
			if(content != null) {
				for(var i:int=content.numChildren-1; i>=0; i--) {
					content.removeChildAt(i);
				}
				if(contains(content))	removeChild(content);
					
				content = null;
				content = new Sprite();
			}
			createMenu(minWidth,minHeight);
		}
		
		public function createMenu (w:Number=200, h:Number=400) :void 
		{
			initW = w;
			initH = h;
			
			if(titleBar == null) titleBar = new Sprite();
			if(title_tf == null) title_tf = createTextField();
			if(closeButton == null) closeButton = new Sprite();
			if(bgmc == null) bgmc = new Sprite();
			
			if(content == null) content = new Sprite();
			//else clearContent();
			
			
			if(_showBg && !contains(bgmc)) addChild(bgmc);
			
			
			if(!contains(content)) addChild(content);
			
			if(_showTitle) {
				if(!contains(titleBar)) addChild(titleBar);
				if(!contains(title_tf)) addChild(title_tf);
				if( _showCloseButton) {
				if(!contains(closeButton)) addChild(closeButton);
				}else{
					if(contains(closeButton)) removeChild(closeButton);
				}
			}
			title_tf.defaultTextFormat = defaultInfoTextFmtCenter;
			title_tf.selectable = false;
			title_tf.mouseEnabled = false;
			title_tf.x = 16 + textOffsetX;
			title_tf.y = textOffsetY;
			title_tf.text = "ABCyg";
			titleHeight = title_tf.textHeight+4;
			title_tf.textColor = TITLE_COLOR;
			title_tf.text = "";
			title_tf.width = 0;
			title_tf.height = titleHeight;
		
			var mtx:Matrix = new Matrix();
			
			mtx.createGradientBox(10,12,Math.PI/2,0,0)
			var ic:Sprite = new Sprite();
			ic.graphics.beginGradientFill( "linear", [0x121212, 0xcfcfcf], [1,1], [0,255], mtx );
			ic.graphics.drawCircle( 5,5,5);
			ic.graphics.endFill();
			
			mtx.createGradientBox(8,8,Math.PI/2,.5,2)
			ic.graphics.beginGradientFill( "radial", [CLOSEBUTTON_COLOR, CLOSEBUTTON_COLOR_2], [1,1], [0,255], mtx );
			ic.graphics.drawCircle( 5,5,4);
			ic.graphics.endFill();
			
			ic.graphics.beginFill( CLOSEBUTTON_COLOR, 1 );
			ic.graphics.drawCircle( 5,2.5,1);
			ic.graphics.endFill();
			/*
			closeButton.label = "";
			closeButton.setWidth( 12 );
			closeButton.showBg( false );
			closeButton.setHeight( titleHeight -2);*/
			closeButton.y = 1;
			closeButton.x = 6;
			closeButton.addChild ( ic );
			closeButton.addEventListener(MouseEvent.CLICK, closeHandler);
			
			if(_dragable) {
				titleBar.addEventListener(MouseEvent.MOUSE_DOWN, startWinDragHandler);
				titleBar.addEventListener(MouseEvent.MOUSE_UP, stopWinDragHandler);
				if(_winDragable) {
					bgmc.addEventListener(MouseEvent.MOUSE_DOWN, startWinDragHandler);
					bgmc.addEventListener(MouseEvent.MOUSE_UP, stopWinDragHandler);
				}
			}
			
			if(_resizable) {
				setChildIndex( resizeButton, numChildren-1 );
			}
			
			resize(w,h);
		}
		
		private var _showCloseButton:Boolean=true;
		public function showCloseButton (v:Boolean) :void {
			_showCloseButton=v;
			if(v) {
				if(closeButton && !contains(closeButton)) addChild(closeButton);
			}else{
				if(closeButton && contains(closeButton)) removeChild(closeButton);
			}
		}
		public function fireEvent ( type:String ) :void {
			dispatchEvent( new Event(type) );
		}
		
		private function startWinDragHandler (e:MouseEvent) :void {
			alpha = dragAlpha;
			startDrag(false);
			fireEvent("startDrag");
		}
		
		private function stopWinDragHandler (e:MouseEvent) :void {
			alpha  = 1;
			stopDrag();
			fireEvent("stopDrag");
		}
		
		public function closeHandler(e:Event) :void {
			fireEvent(Event.CLOSE);
		}
		
		public function get dragable () :Boolean {
			return _dragable;			
		}
		
		public function set dragable (v:Boolean) :void 
		{
			_dragable = v;

			if(v) {
				if(titleBar) {
					titleBar.addEventListener(MouseEvent.MOUSE_DOWN, startWinDragHandler);
					titleBar.addEventListener(MouseEvent.MOUSE_UP, stopWinDragHandler);
				}
				if(bgmc && _winDragable) {
					bgmc.addEventListener(MouseEvent.MOUSE_DOWN, startWinDragHandler);
					bgmc.addEventListener(MouseEvent.MOUSE_UP, stopWinDragHandler);
				}
			}else{
				if(titleBar) {
					titleBar.removeEventListener(MouseEvent.MOUSE_DOWN, startWinDragHandler);
					titleBar.removeEventListener(MouseEvent.MOUSE_UP, stopWinDragHandler);
				}
				if(bgmc) {
					bgmc.removeEventListener(MouseEvent.MOUSE_DOWN, startWinDragHandler);
					bgmc.removeEventListener(MouseEvent.MOUSE_UP, stopWinDragHandler);
				}
			}
		}
		
		public function get resizable () :Boolean {
			return _resizable;
		}
		
		public function set resizable (v:Boolean) :void {
		//	if(v == resizable) return;
			_resizable = v;
			if(v) {
				if(resizeButton == null) {
					resizeButton = new Sprite();
					resizeButton.graphics.clear();
					resizeButton.graphics.beginFill(0,0.05);
					resizeButton.graphics.drawRect( 0, 0, 16, 16 );
					resizeButton.graphics.beginFill(RESIZE_COLOR,1);
					resizeButton.graphics.drawRect( 12, 0, 4, 1 );
					resizeButton.graphics.drawRect( 8, 4, 8, 1 );
					resizeButton.graphics.drawRect( 4, 8, 12, 1 );
					resizeButton.graphics.drawRect( 0, 12, 16, 1 );
					resizeButton.graphics.endFill();
				}
				if(!contains(resizeButton)) addChild(resizeButton);
				resizeButton.mouseEnabled = true;
				resizeButton.addEventListener( MouseEvent.MOUSE_DOWN, resizeDownHandler);
				resize(_w, _h);
			}else{
				if(resizeButton && contains(resizeButton)) removeChild(resizeButton);
				resizeButton = null;
			}
		}
		private function resizeDownHandler (e:Event) :void {
			resizeStartX = stage.mouseX;
			resizeStartY = stage.mouseY;
			resizeStartW = _w;
			resizeStartH = _h;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
		}
		
		private function resizeMoveHandler (e:Event) :void {
			resize( (stage.mouseX-resizeStartX) + resizeStartW, (stage.mouseY-resizeStartY) + resizeStartH);
			
		}
		
		private function resizeUpHandler (e:Event) :void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, resizeMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
			resize( (stage.mouseX-resizeStartX) + resizeStartW, (stage.mouseY-resizeStartY) + resizeStartH);
			dispatchEvent( new Event(Event.RESIZE));
		}
		
		private var _w:Number=160;
		private var _h:Number=120;
		
		public function resize (w:Number, h:Number) :void {
			
			if(w==0) w = _w;
			if(h==0) h = _h;
			
			if(w < minWidth) w = minWidth;
			if(h < minHeight) h = minHeight;
			
			_w = w;
			_h = h;
			
			if(bgmc==null) return;
			
			if(resizeButton != null) {
				resizeButton.x = _w - resizeButton.width;
				resizeButton.y = _h - resizeButton.height;
			}
			
			title_tf.width = w-closeButton.width-4;
			titleBar.graphics.clear();
			
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(w,titleHeight,Math.PI/2);
			titleBar.graphics.beginGradientFill( "linear", [TITLE_BG_COLOR, TITLE_BG_COLOR_2], [1,1], [0,255], mtx);
			
			drawRoundRect( titleBar, 0,0, Math.round(w),titleHeight, 8,8,0,0);
			titleBar.graphics.endFill();
			
			titleBar.graphics.lineStyle(0, LIGHT_COLOR, 1);
			titleBar.graphics.moveTo( 6, 0);
			titleBar.graphics.lineTo( w-5,0);
			
			titleBar.graphics.lineStyle(0, SHADOW_COLOR, 1);
			titleBar.graphics.moveTo( 0, titleHeight-1);
			titleBar.graphics.lineTo( w,titleHeight-1);
			
			bgmc.graphics.clear();
			drawRect( bgmc,0,Math.round(titleHeight),Math.round(w-0.7),Math.round(h-titleHeight),"normal", BG_COLOR, LIGHT_COLOR, SHADOW_COLOR );
			
			if(content != null) {
				content.x = borderLeft;
				content.y = titleHeight + borderTop;
				
				if( borderLeft+borderRight + content.width >= w || borderTop+borderBottom + content.height + titleHeight >= h ) {
					content.scrollRect = new Rectangle(0, 0, w-borderLeft+borderRight, h-(titleHeight+borderTop+borderBottom));
				}else{
					content.scrollRect = null;
				}
			}
		}
		
		public function resizeByContent () :void {
			if(content != null) {
				var w:Number = content.width +2 + borderRight + borderLeft;
				var h:Number = content.height + 2 + borderBottom + borderTop + titleHeight;
				resize( w, h );
			}
		}
		
	}
}
