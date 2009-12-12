package org.openpyro.plugins.airHelpers.storage
{
	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;
	
	public class EncryptedLocalStoreWriter extends AbstractFile implements IFile
	{
		
		private var _fileName:String;
		public function EncryptedLocalStoreWriter(fileName:String){
			_fileName = fileName;
		}
		
		public function write():void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(_data);
			EncryptedLocalStore.setItem(_fileName, bytes);
		}
		
		override public function read():*{
			var storedValue:ByteArray = EncryptedLocalStore.getItem(_fileName);
			_data = storedValue.readUTFBytes(storedValue.length);
			return _data;
		}
	}
}