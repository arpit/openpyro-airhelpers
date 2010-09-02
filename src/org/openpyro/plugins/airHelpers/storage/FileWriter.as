package org.openpyro.plugins.airHelpers.storage
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class FileWriter extends AbstractFile implements IFile
	{
		public function FileWriter()
		{
		}
		
		public static function writeFile(f:File, d:String):void{
			var fw:FileWriter = new FileWriter();
			fw.file = f;
			fw.data = d;
			fw.write();
		}
		
		private var _file:File;
		public function set file(f:File):void{
			_file = f;
		}
		
		public function write():void
		{
			var fileStream:FileStream = new FileStream();
			try{
				fileStream.open(_file, FileMode.WRITE);
			}catch(e:Error){
				var err:StorageEvent = new StorageEvent(StorageEvent.STORAGE_ERROR);
				err.error = e;
				dispatchEvent(err); 
				return;
			}
			fileStream.writeUTFBytes(_data);
			fileStream.close()
		}
		
		override public function read():*
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(_file, FileMode.READ);
			_data = fileStream.readUTFBytes(fileStream.bytesAvailable)
			fileStream.close();
			return _data;
		}
	}
}