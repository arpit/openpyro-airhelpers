package org.openpyro.plugins.airHelpers.storage
{
	import flash.events.Event;

	public class StorageEvent extends Event
	{
		public static const STORAGE_ERROR:String = "storageError";
		
		public var error:Error;
		
		public function StorageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		
	}
}