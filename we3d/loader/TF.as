package we3d.loader 
{
	/**
	 * @private
	 */ 
	public class TF 
	{
		public function TF (file:String="") {
			if(file != "") setFile(file);
		}
		
		public var nl:String="";
		public var _path:String="";
		public var _file:Array;
		
		public function setFile (file:String) :void 
		{
			var c:int;
			var L:int = file.length;
			
			for(var i:int=0; i<L; i++) {
				// search for newline characters
				c = file.charCodeAt(i);
				if(c == 13) {
					if(file.charCodeAt(i+1) == 10) {
						nl = String.fromCharCode(13) + String.fromCharCode(10);
						break;
					}else{
						nl = String.fromCharCode(13);
						break;
					}
				}else if(c == 10) {
					nl = "\n";
					break;
				}
			}
			
			_file = file.split(nl);
		}
		
		public function clear () :void {
			_path = "";
			_file = null;
		}

	}
	
}