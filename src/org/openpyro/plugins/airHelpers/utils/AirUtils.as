package org.openPyro.plugins.airHelpers.utils
{
	import flash.desktop.NativeApplication;
	
	public class AirUtils
	{
		public function AirUtils()
		{
		}
		
		public static function getCurrentAppVerion():String{
			var appDescriptor:XML = (NativeApplication.nativeApplication.applicationDescriptor)
			var ns:Namespace = appDescriptor.namespace()
			return String(appDescriptor.ns::version)
		}

	}
}