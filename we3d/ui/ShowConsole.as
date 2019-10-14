package we3d.ui
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	
	import we3d.we3d;
	import we3d.ui.WEWindow;
	import we3d.view.View3d;
	use namespace we3d;
	
	public class ShowConsole
	{
		public function ShowConsole () {}
		
		private static var _logTarget:Sprite;
		private static var logOpen:Boolean=false;
		private static var win:WEWindow;
		private static var tf:TextField;
		internal var opened:Boolean;
		
		public static function printLogFile (target:Sprite) :void 
		{
			if(logOpen) {
				//closeLog(null);
				tf.text = Console.getLogFile();
				win.resizeByContent();
			}else{
			
				_logTarget = target;
				logOpen = true;
				
				var c1:TextField = new TextField(); 
				c1.text = Console.getLogFile();
				c1.autoSize = "left";
				
				tf = c1;
				
				win = new WEWindow();
				
				win.addEventListener( Event.CLOSE, closeLog );
				win.resizable = true;
				win.createMenu( 400, 400 );
				win.content.addChild(c1);
				win.resizeByContent();
				target.addChild(win);
				Console.consoleUpdate = updateLog;
			}
			
		}
		private static function updateLog () :void {
			if(tf != null) {
				tf.text = Console.getLogFile();
				if(win != null) {
					win.resizeByContent();
				}
			}
		}
		public static function showRenderInfo (target:Sprite, view:View3d) :void 
		{
			if(logOpen) {
				closeLog(null);
			}
			
			_logTarget = target;
			logOpen = true;
			
			var c1:TextField = new TextField();
			var st:String = "";
			
			if( view.gpuEnabled ) {
				if( view.firstLayer.context3d )
					st = "<p><b>Renderer:</b> " + "Stage3D: " + view.firstLayer.context3d.driverInfo  + " </p>\n ";
				else 
					st = "<p><b>Renderer:</b> " + "AS3 Software </p>\n";
			}else{
				st = "<p><b>Renderer:</b> " + "AS3 Software </p>\n ";
			}
			
			st += "<p><b>Objects:</b> " + view.scene.objectList.length + "</p>\n";
			st += "<p><b>Layers:</b> " + view.allLayers.length + "</p>\n";
			st += "<p><b>Rendered Polygons (AS3 Software):</b> " + view.firstLayer.polys.length + "</p>\n";
			
			c1.htmlText = st;
			
			
			c1.autoSize = "left";
			
		 	win = new WEWindow();
			
			win.addEventListener( Event.CLOSE, closeLog );
			win.resizable = true;
			win.createMenu( 400, 400 );
			win.content.addChild(c1);
			win.resizeByContent();
			
			target.addChild(win);
			
			
			
		}
		
		private static function closeLog (e:Event) :void {
			
			_logTarget.removeChild( win );
			logOpen = false;
			Console.consoleUpdate = null;
		}
		
		
	}
}