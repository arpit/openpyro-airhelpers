package org.openpyro.plugins.airHelpers.logging
{
	import com.arpitonline.alphonzo.storage.FileWriter;
	
	import flash.filesystem.File;
	
	import net.comcast.logging.Level;
	import net.comcast.logging.consoles.IConsole;
	
	public class FileLogger implements IConsole
	{
		private var _file:File;
		private var logs:Array;
		
		public function FileLogger(f:File)
		{
			this._file = f;
			logs = [];
		}
		
		public function log(source:*, level:Number, msg:String):void
		{
			logs.push("["+source+"]["+Level.getLevelString(level)+"] "+msg);
		}
		
		public function write():void{
			var writer:FileWriter = new FileWriter();
			writer.data = logs.join("\n");
			writer.file = _file;
			writer.write();
		}
	}
}