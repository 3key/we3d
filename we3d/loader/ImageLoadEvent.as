package we3d.loader 
{
	import flash.events.Event;
	
	/**
	 * @private
	 */ 
	public class ImageLoadEvent extends Event 
	{
		public var bmpid:int;
		public var imgid:int;
		
		public function ImageLoadEvent(type:String, aid:int, bid:int, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			bmpid = aid;
			imgid = bid;
		}
	}
	
}