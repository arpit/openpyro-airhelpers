package org.openpyro.plugins.airHelpers.file
{
	import flash.events.Event;

	public class RemoteFileDownloadErrorEvent extends Event
	{
		public static const DOWNLOAD_ERROR:String = "downloadError";
		
		/**
		 * The native event that caused this error
		 */
		public var nativeEvent:Event;
		
		public function RemoteFileDownloadErrorEvent(nativeEvent:Event)
		{
			super(DOWNLOAD_ERROR, false,false);
			this.nativeEvent = nativeEvent;
		}
		
		public var _reason:String = "unknown"
		
		public function get reason():String{
			if(nativeEvent){
				return nativeEvent.type;
			}
			return _reason
		}
		
		
	}
}