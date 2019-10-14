package we3d.layer 
{
	import we3d.we3d;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import we3d.renderer.RenderSession;
	use namespace we3d;
	/** 
	 * The BitmapBackdrop displays a bitmap in the background of a Layer. The bitmap is copied every frame into the bitmapdata of the Layer.
	 */
	public class BitmapBackdrop extends SolidBackdrop
	{
		public function BitmapBackdrop (_image:BitmapData=null, _smooth:Boolean=true, _repeat:Boolean=true ) {
			image = _image;
			smooth = _smooth;
			repeat = _repeat;
		}
		
		public var image:BitmapData;
		public var smooth:Boolean=true;
		public var repeat:Boolean=true;
		public var matrix:Matrix=new Matrix();
		
		public override function drawToBitmap (session:RenderSession, lyr:Layer) :void {
			
			var bmp:BitmapData = lyr.bmp;
			
			bmp.fillRect(bmp.rect, _bgColor32);
					
			if(image) {
				var sp:Sprite = new Sprite();
				sp.graphics.beginBitmapFill(image, matrix, repeat, smooth);
				sp.graphics.drawRect(0, 0, lyr.width, lyr.height);
				sp.graphics.endFill();
				sp.alpha = _bgAlpha;
				bmp.draw(sp);
			}
		}
		
		public override function drawToSprite (session:RenderSession, lyr:Layer) :void {
			
			if(image) {
				lyr._graphics.beginBitmapFill(image, matrix, repeat, smooth);
			}else{
				lyr._graphics.beginFill(_bgColor, _bgAlpha);
			}
			
			lyr._graphics.drawRect(0, 0, lyr.width, lyr.height);
			lyr._graphics.endFill();
		}
		
	}
}