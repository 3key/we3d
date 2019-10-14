package we3d.loader 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import we3d.ui.Console;
	import we3d.rasterizer.IRasterizer;
	import we3d.rasterizer.ScanlineFlat;
	import we3d.rasterizer.ScanlineTX;
	import we3d.rasterizer.ScanlineFlatLight;
	import we3d.rasterizer.ScanlineTXLight;
	
	/**
	* The Base class for a File Loader 
	*/
	public class Loader3d extends EventDispatcher 
	{
		public function Loader3d () {}
		
		/**
		* If blocking is true, the file is parsed in one function call. If blocking is true, the swf may freeze while parsing
		*/
		public var blocking:Boolean=false;
		/**
		* Interval for a parse step if blocking is false
		*/
		public var loadParseInterval:int = 25;
		/** 
		* Process amount of lines in one parse step only for text files
		*/
		public var linesPerFrame:int = 256;
		/** 
		* Process amount of chunks in one parse step only for binary files
		*/
		public var chunksPerFrame:int = 1;
		/**
		* Apply a scale to all points, default is 1
		*/
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var scaleZ:Number = 1;
		/**
		* If flipped is true, the order of the vertices in the polygons is reversed
		*/
		public var flipped:Boolean = true;
		/** 
		* Percent already parsed or -1 if the file is not loaded yet
		*/
		public var status:int=-1;
		/**
		* Default rasterizer for polygons without textures
		*/
		public var defaultRasterizer:IRasterizer = new ScanlineFlat();
		/**
		* Default rasterizer for polygons with textures
		*/
		public var defaultTextureRasterizer:IRasterizer = new ScanlineTX();
		
		
		/**
		* Default rasterizer for polygons without textures
		*/
		public var defaultLightRasterizer:IRasterizer = new ScanlineFlatLight();
		/**
		* Default rasterizer for polygons with textures
		*/
		public var defaultTextureLightRasterizer:IRasterizer = new ScanlineTXLight();
		
		
		/**
		* Set scaleX, scaleY and scaleZ at once
		* @param	s
		*/
		public function set scale (s:Number) :void {
			scaleX = scaleY = scaleZ = s;
		}
		public function get scale () :Number {
			return (scaleX+scaleY+scaleZ)/3;
		}
		
		private var _isLoading:Boolean = false;
		public function get isLoading () :Boolean {
			return _isLoading;
		}
		
		public var filename:String="";
		public var filepath:String="";
		public var filedir:String="";
		
		public var subdirResources:Boolean=true;
		
		/**
		* Laod a 3d object file from a url
		* 
		* @param url the path to the file 
		* @return true if loading started succesfully
		*/
		public function loadFile (file:String) :Boolean {
			
			if(!_isLoading) 
			{
				status = -1;
				
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, loadFileComplete)
				loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
								
				var request:URLRequest = new URLRequest(file);
				
				try {
					var end:int = file.lastIndexOf("/");
					if( end != -1 ) {
						filedir = file.substring( 0, end+1 );
						filename = file.substring( end+1, file.length );
					}else{
						filedir = "";
						filename = filepath;
					}
					filepath = file;
					
					loader.load(request);
					_isLoading = true;
					return true;
				} catch (error:Error) {
					return false;
				}
			}
			
			return false;
			
		}
		
		private function ioErrorHandler(event:Event):void {
			_isLoading = false;
			Console.log( "Loader3d IO Error: " + event );
			dispatchEvent (event);
		}
		
        private function loadFileComplete(event:Event):void 
		{
			_isLoading = false;
            var loader:URLLoader = URLLoader(event.target);
			dispatchEvent(new Event(Event.INIT));
			Console.log( "File loaded: " + filepath);
			
			parseFile(loader.data);
        }
		
		/**
		* Have to be implemented by a loader
		*/
		public function parseFile (bytes:ByteArray) :void {}
	
	}
}
