package org.openpyro.plugins.airHelpers.config{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	
	[Event(name="remotePropertiesLoaded", type="flash.events.Event")]
	[Event(name="remotePropertiesFailed", type="flash.events.Event")]
		
	public class RemoteProperties extends Properties{
		
		public static const PROPERTIES_LOADED:String = "remotePropertiesLoaded";
		public static const PROPERTIES_FAILED:String = "remotePropertiesFailed";
		
		private var _url:String;
		
		public function load(url:String):void{
			_url = url;
			var loader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(req);
		}
		
		public function get remoteURL():String{
			return _url;
		}
		
		private function onIOError(event:Event):void{
			dispatchEvent(new Event(PROPERTIES_FAILED));			
		}
		
		private function onLoadComplete(event:Event):void{
			try{
				_properties = XML(event.target.data);
			}catch(e:Error){
				dispatchEvent(new Event(PROPERTIES_FAILED));
				return;
			}
			dispatchEvent(new Event(PROPERTIES_LOADED));
		}
	}
}