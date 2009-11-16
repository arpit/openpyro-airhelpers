package org.openpyro.plugins.airHelpers.config
{
	import flash.events.EventDispatcher;

	public class Properties extends EventDispatcher{
		
		protected var _properties:XML;
		
		
		public function Properties()
		{
		}
		
		/**
		 * Returns the property value set in the local store
		 */ 
		public function getProperty(propertyName:String):String{
			return _properties.child(propertyName).toString();
		}
		
		public function setProperty(propertyName:String, value:String):void{
			if(String(_properties.child(propertyName))==""){
				_properties.appendChild(XML("<"+propertyName+">"+value+"</"+propertyName+">"));
			}
			else{
				_properties.child(propertyName).setChildren(value);
			}
		}
	}
}