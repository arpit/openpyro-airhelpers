package org.openPyro.plugins.airHelpers.twitter
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

    /**
    *   Class used to read Twitter generated RSS and filter out
    *   all @ messages. Used communicate messages to end users 
    *   via a Twitter account.
    */   

	public class TwitterReader
	{
		public function TwitterReader()
		{
			
		}
		
		public function read(url:String):void{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(new URLRequest(url));
		}
		
		
		private var selectedTitle:String ;
		
		private function onComplete(event:Event):void{
			var data:XML = XML(event.target.data);
			
			var account:String = trim(String(data.channel.title).split("/")[1])	;
			var items:XMLList = data.channel.item;
			for(var i:int=0; i<items.length(); i++){
				var title:String = String(items[i].title);
				title = trim(title.substr(account.length+1, title.length));
				if(title.charAt(0)=="@"){
					continue;
				}
				else{
					selectedTitle = title;
					break;
				}
				
			}
		}
		
		private function trim(p_string:String):String {
			if (p_string == null) { return ''; }
			return p_string.replace(/^\s+|\s+$/g, '');
		}
		
		private function onIOError(event:Event):void{
			// do nothing
		}
	}
}