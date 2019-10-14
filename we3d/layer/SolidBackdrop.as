package we3d.layer 
{
	import we3d.we3d;
	import we3d.renderer.RenderSession;
	import flash.display.BitmapData;
	use namespace we3d;
	
	/**
	* The SolidBackdrop fills the background image of a Layer with one color. 
	*/
	public class SolidBackdrop extends Backdrop 
	{
		public function SolidBackdrop (_color:uint=0, _alpha:Number=1) {
			color = _color;
			alpha = _alpha;
		}
		/**
		* @private
		*/
		protected var _bgColor32:uint=0x00000000;
		/**
		* @private
		*/
		protected var _bgColor:int=0;
		/**
		* @private
		*/
		protected var _bgAlpha:Number=0;
		
		protected var bgrRed:Number=0;
		protected var bgrGreen:Number=0;
		protected var bgrBlue:Number=0;
		
		public function set color (col:uint) :void {
			_bgColor = col;
			bgrRed = (col >> 16 & 255)/255;
			bgrGreen = (col >> 8 & 255)/255;
			bgrBlue = (col & 255)/255;
			
			_bgColor32 = int(_bgAlpha*255) << 24 | col;
		}
		public function get color () :uint {
			return _bgColor;
		}
		
		public function set alpha (value:Number) :void {
			_bgAlpha = value;
			_bgColor32 = int(_bgAlpha*255) << 24 | _bgColor;
		}
		public function get alpha () :Number {
			return _bgAlpha;
		}
		
		public override function drawToGPU (session:RenderSession, lyr:Layer) :void {
			if(session.context3d && session.context3d.driverInfo != "Disposed") 
			{
				session.context3d.clear( bgrRed, bgrGreen, bgrBlue, _bgAlpha );
			}
		}
		
		public override function drawToBitmap (sesssion:RenderSession, lyr:Layer) :void {
			var bmp:BitmapData = lyr.bmp;
			bmp.fillRect(bmp.rect, _bgColor32);
		}
		
		public override function drawToSprite (session:RenderSession, lyr:Layer) :void {
			lyr._graphics.beginFill(_bgColor, _bgAlpha);
			lyr._graphics.drawRect(0, 0, lyr.width==0?session.width:lyr.width, lyr.height==0?session.height:lyr.height);
			lyr._graphics.endFill();
		}
		
	}
	
}