package we3d.ui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	
	/**
	* Base Class for a control (Button, Menu...)
	*/
	public class Ctrl extends  Sprite /* BoxModel */
	{
		public function Ctrl() {}
		
		public static var minWidth:Number = 4;
		public static var minHeight:Number = 4;
		
		public var format:String="left";
		public var border:Rectangle = new Rectangle(2,2,2,2);
		
		protected var _enabled:Boolean=true;
		public function set enabled (v:Boolean) :void {
			if(_enabled==v) return;
			
			_enabled = v;
		}
		public function get enabled () :Boolean {
			return _enabled;
		}
		
		public static var textOffsetX:Number = 0;
		public static var textOffsetY:Number = 1;
		
		public var styles:Array=[];
		public var currentStyle:String="";
		
		public function addStyle( style:Object, state:String="normal" ) :void {
			styles[state] = style; 
		}
		
		public function setStyle( style:Object ) :void {}
		
		private var _roundLeft:Boolean=true;
		public function set roundLeft (v:Boolean) :void { _roundLeft=v;  setWidth(getWidth()); }
		public function get roundLeft ():Boolean { return _roundLeft; }
		
		private var _roundRight:Boolean=true;
		public function set roundRight (v:Boolean) :void { _roundRight=v;  setWidth(getWidth()); }
		public function get roundRight ():Boolean { return _roundRight; }
		
		private static var roundness:Number=6;
		
		public static function createTextField () :TextField 
		{
			var tf:TextField = new TextField();
			tf.antiAliasType = flash.text.AntiAliasType.ADVANCED;
			tf.textColor = INPUT_COLOR;
			return tf;
			
		}
		
		public static function drawInputBg ( bg:Sprite, w:Number, h:Number, roundL:Boolean=true, roundR:Boolean=true) :void 
		{
			bg.graphics.lineStyle( 1, INPUT_BORDER_COLOR, 1);
			bg.graphics.beginFill(  INPUT_BACKGROUND_COLOR, 1 );
			bg.graphics.moveTo( roundL ? roundness : 0, 0 );
			
			if(roundR) {
				bg.graphics.lineTo( w - roundness, 0 );
				bg.graphics.curveTo( w, 1, w, h/2);
				bg.graphics.curveTo( w, h-1, w-roundness, h);
			}else{
				bg.graphics.lineTo( w, 0 );
				bg.graphics.lineTo( w, h);
			}
			
			if(roundL) {
				bg.graphics.lineTo( roundness,h);
				bg.graphics.curveTo(0, h-1,0,h/2);
				bg.graphics.curveTo(0, 1,roundness,0);
			}else{
				bg.graphics.lineTo( 0,h);
				bg.graphics.lineTo( 0,0);
			}
			
			bg.graphics.endFill();
		}
		
		public static function drawRoundRect (mc:Sprite, x:Number, y:Number, w:Number, h:Number, roundTL:Number=4, roundTR:Number=4, roundBL:Number=4, roundBR:Number=4) :void {
			if( roundTL > 0 ) {
				mc.graphics.moveTo(x+roundTL, y);
			}else{
				mc.graphics.moveTo(x,y);
			}
			
			if(roundTR > 0 ) {
				mc.graphics.lineTo( w - roundTR, y);
				mc.graphics.curveTo( w, y, w, y+roundTR );
			}else{
				mc.graphics.lineTo( w, y );
			}
			
			if(roundBR > 0 ) {
				mc.graphics.lineTo( w, h-roundBR);
				mc.graphics.curveTo( w, h, w-roundBR, h );
			}else{
				mc.graphics.lineTo( w, h );
			}
			
			if(roundBL > 0 ) {
				mc.graphics.lineTo( x+roundBL, h);
				mc.graphics.curveTo( x, h, x, h-roundBL );
			}else{
				mc.graphics.lineTo( x, h );
			}
			
			if(roundTL) {
				mc.graphics.lineTo( x, y+roundTL);
				mc.graphics.curveTo( x, y, x+roundTL, y );
			}else{
				mc.graphics.lineTo(x,y);
			}
		}
			
		/**
		* Draws Rectangles with light and shadow strokes wich are used for the default appearance
		* @param	mc
		* @param	x
		* @param	y
		* @param	w
		* @param	h
		* @param	state normal, over or press
		*/
		public static function drawRect (mc:Sprite, x:Number, y:Number, w:Number, h:Number, state:String="normal", bgcolor:int=-1, lightColor:int=-1, shadowColor:int=-1) :void {
			
			mc.graphics.clear();
			
			var lw:Number = LIGHT_WIDTH+1;
			var sw:Number = SHADOW_WIDTH+1;
			var bg:int;
			
			switch(state) 
			{
				case "transparent":
					mc.graphics.beginFill(0, 0);
					mc.graphics.drawRect(x, y, w, h);
					mc.graphics.endFill();
					break;
				case "flat":
					bg = bgcolor == -1 ? BACKGROUND_COLOR : bgcolor;
					mc.graphics.beginFill(bg, BACKGROUND_ALPHA);
					mc.graphics.drawRect(x, y, w, h);
					mc.graphics.endFill();
					break;
				case "normal":
					bg = bgcolor == -1 ? BACKGROUND_COLOR : bgcolor;
					mc.graphics.lineStyle(OUTLINE_WIDTH, OUTLINE_COLOR, OUTLINE_ALPHA);
					mc.graphics.beginFill(bg, BACKGROUND_ALPHA);
					mc.graphics.drawRect(x, y, w, h);
					mc.graphics.endFill();
					
					mc.graphics.lineStyle(lw-1, (lightColor == -1 ? LIGHT_COLOR : lightColor), LIGHT_ALPHA);
					mc.graphics.moveTo(x+lw, y+h-lw);
					mc.graphics.lineTo(x+lw, y+lw);
					mc.graphics.lineTo(x+w-lw, y+lw);
					
					mc.graphics.lineStyle(sw-1, (shadowColor == -1 ? SHADOW_COLOR : shadowColor), SHADOW_ALPHA);
					mc.graphics.moveTo(x+w-sw, y+sw);
					mc.graphics.lineTo(x+w-sw, y+h-sw);
					mc.graphics.lineTo(x+sw, y+h-sw);
					break;
				
				case "over":
					bg = bgcolor == -1 ? BACKGROUND_COLOR_OVER : bgcolor;
					mc.graphics.lineStyle(OUTLINE_WIDTH, OUTLINE_COLOR, OUTLINE_ALPHA);
					mc.graphics.beginFill(bg, BACKGROUND_ALPHA_OVER);
					mc.graphics.drawRect(x, y, w, h);
					mc.graphics.endFill();
					
					mc.graphics.lineStyle(lw-1, (lightColor == -1 ? LIGHT_COLOR : lightColor), SHADOW_ALPHA);
					mc.graphics.moveTo(x+lw, y+h-lw);
					mc.graphics.lineTo(x+lw, y+lw);
					mc.graphics.lineTo(x+w-lw, y+lw);
					
					mc.graphics.lineStyle(sw-1, (shadowColor == -1 ? SHADOW_COLOR : shadowColor), LIGHT_ALPHA);
					mc.graphics.moveTo(x+w-sw, y+sw);
					mc.graphics.lineTo(x+w-sw, y+h-sw);
					mc.graphics.lineTo(x+sw, y+h-sw);
					break;
				
				case "press":
					
					bg = bgcolor == -1 ? BACKGROUND_COLOR_PRESS : bgcolor;
					mc.graphics.lineStyle(OUTLINE_WIDTH, OUTLINE_COLOR, OUTLINE_ALPHA);
					mc.graphics.beginFill(bg, BACKGROUND_ALPHA_PRESS);
					mc.graphics.drawRect(x, y, w, h);
					mc.graphics.endFill();
					
					mc.graphics.lineStyle(lw-1, (shadowColor == -1 ? SHADOW_COLOR : shadowColor), SHADOW_ALPHA);
					mc.graphics.moveTo(x+lw, y+h-lw);
					mc.graphics.lineTo(x+lw, y+lw);
					mc.graphics.lineTo(x+w-lw, y+lw);
					
					mc.graphics.lineStyle(sw-1, (lightColor == -1 ? LIGHT_COLOR : lightColor), LIGHT_ALPHA);
					mc.graphics.moveTo(x+w-sw, y+sw);
					mc.graphics.lineTo(x+w-sw, y+h-sw);
					mc.graphics.lineTo(x+sw, y+h-sw);
					
					break;
				
				case "press-light":
					
					bg = bgcolor == -1 ? BACKGROUND_COLOR_PRESS : bgcolor;
					mc.graphics.lineStyle(OUTLINE_WIDTH, OUTLINE_COLOR, OUTLINE_ALPHA);
					mc.graphics.beginFill(bg, BACKGROUND_ALPHA_PRESS);
					mc.graphics.drawRect(x, y, w, h);
					mc.graphics.endFill();
					
					mc.graphics.lineStyle(lw-1, (shadowColor == -1 ? SHADOW_COLOR : shadowColor), LIGHT_ALPHA);
					mc.graphics.moveTo(x+lw, y+h-lw);
					mc.graphics.lineTo(x+lw, y+lw);
					mc.graphics.lineTo(x+w-lw, y+lw);
					
					mc.graphics.lineStyle(sw-1, (shadowColor == -1 ? SHADOW_COLOR : shadowColor), SHADOW_ALPHA);
					mc.graphics.moveTo(x+w-sw, y+sw);
					mc.graphics.lineTo(x+w-sw, y+h-sw);
					mc.graphics.lineTo(x+sw, y+h-sw);
					
					mc.graphics.lineStyle(sw-1, (lightColor == -1 ? LIGHT_COLOR_BRIGHT : lightColor), SHADOW_ALPHA);
					mc.graphics.moveTo(x+w-sw*2, y+sw*2);
					mc.graphics.lineTo(x+w-sw*2, y+h-sw*2);
					mc.graphics.lineTo(x+sw*2, y+h-sw*2);
					break;
			}
		}
			
		
		public function setWidth (w:int) :void { if(w < minWidth) w=minWidth; width = w; }
		public function setHeight (h:int) :void {}
		
		public function getWidth () :int { return width; }
		public function getHeight () :int { return height; }
		
		/*public static var KEY_SEPARATOR:String="#separator";
		public static var KEY_SECTION_SELECTOR:String="#section-selector";
		public static var KEY_TOOL:String="tool";
		public static var KEY_BOOLEAN:String="bool";
		*/
		
		public static var BG_COLOR:int = 0xc0c0c0;
		
		public static var OUTLINE_WIDTH:int = 0;
		public static var OUTLINE_COLOR:int = 0x323232;
		public static var OUTLINE_ALPHA:Number = 1
		public static var BACKGROUND_COLOR:int = 0xc0c0c0;
		public static var BACKGROUND_COLOR_OVER:int = 0xefefef;
		public static var BACKGROUND_COLOR_PRESS:int = 0x000000;
		public static var BACKGROUND_ALPHA:Number = 1;
		public static var BACKGROUND_ALPHA_OVER:Number = 1;
		public static var BACKGROUND_ALPHA_PRESS:Number = 1;
		
		public static var LIGHT_WIDTH:int = 0;
		public static var LIGHT_COLOR:int = 0xcfcfcf;
		public static var LIGHT_COLOR_BRIGHT:int = 0xffffff;
		
		public static var LIGHT_ALPHA:Number = 1;
		
		public static var SHADOW_WIDTH:int = 0;
		public static var SHADOW_COLOR:int = 0x7f7f7f;
		public static var SHADOW_ALPHA:Number = 1;
		
		public static var INPUT_BORDER_COLOR:int = 0x323232;
		public static var INPUT_BACKGROUND_COLOR:int = 0xc0c0c0;
		public static var DISABLED_COLOR:int = 0xefefef;
		public static var INPUT_COLOR:int = 0xdfdfdf;
		public static var INPUT_DISABLED:int = 0x999999;
		public static var INFO_BG_COLOR:int = 0x505050;
		public static var TOOL_COLOR:int = 0x505560;
		public static var SELECTED_TOOL_COLOR:int = 0xf0f0f0;
		public static var ACTION_COLOR:int = 0x605550;
		public static var COMMAND_COLOR:int = 0x706560;
		public static var BOOLEAN_COLOR:int = 0x404040;
		
		public static var defaultInfoTextFmt:TextFormat     = new TextFormat("Verdana", 10, 0x0);
		public static var defaultInfoTextFmtRight:TextFormat     = new TextFormat("Verdana", 10, 0x0, null, null, null, null, null, "right");
		public static var defaultInfoTextFmtCenter:TextFormat     = new TextFormat("Verdana", 10, 0x0, null, null, null, null, null, "center");
		
		public static var defaultInputTextFmt:TextFormat    = new TextFormat("Verdana", 10, 0x0, null, null, null, null, null, "right");
		public static var defaultInputTextFmtLeft:TextFormat    = new TextFormat("Verdana", 10, 0x0, null, null, null, null, null, "left");
		public static var defaultInputTextFmtCenter:TextFormat    = new TextFormat("Verdana", 10, 0x0, null, null, null, null, null, "center");
		public static var disabledInputTextFmt:TextFormat    = new TextFormat("Verdana", 10, 0xc3c3c3, null, null, null, null, null, "right");
		public static var disabledInputTextFmtLeft:TextFormat    = new TextFormat("Verdana", 10, 0xc3c3c3, null, null, null, null, null, "left");
		public static var disabledInputTextFmtCenter:TextFormat    = new TextFormat("Verdana", 10, 0xc3c3c3, null, null, null, null, null, "center");
		public static var defaultLabelTextFmt:TextFormat    = new TextFormat("Verdana", 10, 0x242424);
		public static var disabledLabelTextFmt:TextFormat    = new TextFormat("Verdana", 10, 0xc3c3c3);
		public static var defaultShortcutTextFmt:TextFormat = new TextFormat("Verdana", 10, 0x939393);
	}
}