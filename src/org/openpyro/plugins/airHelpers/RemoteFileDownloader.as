package org.openPyro.plugins.airHelpers
{
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.filesystem.*;
	
	public class RemoteFileDownloader extends EventDispatcher
	{
		
		public static const DOWNLOAD_COMPLETE:String = "downloadComplete"
		public static const DOWNLOAD_ERROR:String = "downloadComplete"
		
		private var fileURLRequest:URLRequest
		private var downloadedFile:File;
		
		private var fileStream:FileStream
		private var urlStream:URLStream
		
		public function RemoteFileDownloader()
		{
		}
		
		public function download(url:String, file:File):void{
			
			fileURLRequest = new URLRequest(url)
			fileURLRequest.useCache = false;
			downloadedFile = file
			urlStream = new URLStream()
			urlStream.addEventListener(Event.OPEN, onURLStreamOpen);
			urlStream.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			urlStream.addEventListener(Event.COMPLETE, onDownloadComplete);
			urlStream.load(fileURLRequest);
			
		}
		
		private function onURLStreamOpen(event:Event):void{
			fileStream = new FileStream();
			try{			
				fileStream.open(downloadedFile, FileMode.WRITE);
			}catch(e:Error){
				return;
			}
		}
		
		private function onDownloadProgress(event:Event):void{
			saveBytes()
		}
		
		private function saveBytes():void	
		{
			if (!fileStream || !urlStream || !urlStream.connected)
				return;
			try
			{
				var bytes:ByteArray = new ByteArray();
				urlStream.readBytes(bytes, 0, urlStream.bytesAvailable);
				fileStream.writeBytes(bytes);
			}catch(error:EOFError) {
				//Logger.fatal(this, "EOF ERROR")
				dispatchEvent(new Event(DOWNLOAD_ERROR))
			}
			catch(err:IOError) {
				//Logger.fatal(this, "IO ERROR")
				dispatchEvent(new Event(DOWNLOAD_ERROR))	
			}			
		}
		
		private function onDownloadComplete(event:Event):void{
			// empty the buffer
			while (urlStream && urlStream.bytesAvailable)
			{
				saveBytes();
			}
			if (urlStream && urlStream.connected)
			{
				urlStream.close();
				urlStream = null;
			}
			fileStream.close();
			fileStream = null;
			dispatchEvent(new Event(DOWNLOAD_COMPLETE));
		}
	}
}