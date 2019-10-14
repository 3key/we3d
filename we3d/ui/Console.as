package we3d.ui
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.*;
	import flash.events.EventDispatcher;
	
	public class Console extends EventDispatcher 
	{
		public function Console() {}
		
		public static var consoleUpdate:Function=null;
		
		private static var logFile:String = "";
		
		public static function log( msg:String ) :void 
		{
			logFile += msg + "\n";
			if(consoleUpdate != null) consoleUpdate();
		}
		
		public static function clear () :void {
			logFile = "";
		}
		
		public static function getLogFile () :String {
			return logFile;
		}
		
	}
}