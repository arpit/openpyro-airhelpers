package org.openpyro.plugins.airHelpers.storage
{
	import flash.events.EventDispatcher;
	
	public class AbstractFile extends EventDispatcher
	{
		public function AbstractFile()
		{
		}
		
		protected var _data:String;
		public function set data(d:String):void{
			_data = d;
		}
		public function get data():String{
			if(!_data){
				_data = read();
			}
			return _data;
		}
		
		public function read():*{
			// implemented by overriding class
		}
	}
}