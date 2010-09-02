package org.openpyro.plugins.airHelpers.utils
{
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.NativeMenu;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	
	import org.openPyro.utils.ArrayUtil;
	
	public class AirUtils
	{
		/**
		 * Parses the ApplicationDescriptor XML to return the version of the NativeApplication
		 */ 
		public static function getCurrentAppVerion():String{
			var appDescriptor:XML = (NativeApplication.nativeApplication.applicationDescriptor)
			var ns:Namespace = appDescriptor.namespace()
			return String(appDescriptor.ns::version)
		}
		
		/**
		 * Overrides the Close action of the NativeWindow to hide the window and show it in the System Dock
		 * (System tray for the PC / Dock for the Mac)as an icon. Also creates an EventListener to listen 
		 * to the invoke/mouseclick event on the icon to make the window visible again. 
		 * 
		 * @param
		 * @param 	undockEventListener		Function to be invoked when the undock event happens. If that function
		 * 									returns false, the window is not made visible
		 * @param	menu					NativeMenu to be shown on click of the docked icon
		 *  
		 * @see http://www.adobe.com/devnet/air/flash/quickstart/stopwatch_dock_system_tray.html
		 */  
		 public static function runInBackgroundOnClose(win:NativeWindow,
		 											 dockEventListener:Function = null, 
		 											 undockEventListener:Function=null,
		 											 dockedIconBitmaps:Array=null, 
		 											 menu:NativeMenu=null):void{
		 	
		 	var undockEventHandler:Function = function(event:Event):void{
		 		if(win.visible)return;
		 		if(undockEventListener != null){
		 			var showWindow:Boolean = undockEventListener(event);
		 		
		 			if(!showWindow){
		 				
		 				return;
		 			}
		 		}
		 		win.visible = true;	
		 	};
		 	
		 	var isExiting:Boolean = false;
		 	
		 	var na:NativeApplication = NativeApplication.nativeApplication;
		 	na.autoExit = false;
		 	
		 	
		 	na.addEventListener(Event.EXITING, function(event:Event):void{
		 		isExiting = true;
		 	})
		 	//pass an empty callback for callback function since adding it at event.close seems to
		 	//dispatch the INVOKE event anyway.
		 	win.addEventListener(Event.CLOSING, function(event:Event):void{
		 		if(isExiting){
		 			// do default exit
		 			return;
		 		}
		 		// else: this is a window close action
		 		if(dockEventListener != null){
		 			if(dockEventListener(event) == false){
		 				return;
		 			}
		 		}
		 		event.preventDefault();
		 		win.visible=false;
		 		
		 	});
		 	
		 	var ed:EventDispatcher = showInDockOrSystemTray(win.title,dockedIconBitmaps,  menu);
		 	ed.addEventListener(Event.OPEN, undockEventHandler);
		 }
		 
		 /**
		 * Shows one of the Bitmaps in the dockedIconBitmaps Array in the OS Dock or System Tray
		 * and calls the undockListener an event when the icon in the dock is clicked on on either OS. 
		 */ 
		 public static function showInDockOrSystemTray(tooltip:String="", 
		 												dockedIconBitmaps:Array=null, 
		 												menu:NativeMenu=null, onIconClick:Function=null):EventDispatcher{
		 	
		 	var ed:EventDispatcher = new EventDispatcher();
		 	
		 	var showInDockWithImages:Function = function(dockedIconBitmaps:Array):void{
		 		
		 		if(NativeApplication.supportsDockIcon){
				    var dockIcon:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				    NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, function(evt:InvokeEvent):void{
				    	var openEvent:Event = new Event(Event.OPEN);
				    	ed.dispatchEvent(openEvent);
				    	if(onIconClick != null){
				    		onIconClick();
				    	}
				    	
				    });
				    if(menu){
				    	dockIcon.menu = menu;
				    }
				} else if (NativeApplication.supportsSystemTrayIcon){
					var sysTrayIcon:SystemTrayIcon =
				    NativeApplication.nativeApplication.icon as SystemTrayIcon;
				    sysTrayIcon.tooltip = tooltip;
				    sysTrayIcon.addEventListener(MouseEvent.CLICK,function(evt:MouseEvent):void{
				    	var openEvent:Event = new Event(Event.OPEN);
				    	ed.dispatchEvent(openEvent);
				    	if(onIconClick != null){
				    		onIconClick();
				    	}
				    });
				   	NativeApplication.nativeApplication.icon.bitmaps = dockedIconBitmaps;
				   	if(menu != null){
					 	sysTrayIcon.menu = menu;
					}	
				}	
		 	}
		 	
		 	if(dockedIconBitmaps != null){
		 		showInDockWithImages(dockedIconBitmaps);
		 	}
		 	else{
		 		getIconsFromAppDescriptor(function(arr:Array):void{
		 			var bmps:Array = [];
		 			for(var i:int=0; i < arr.length; i++){
		 				var loader:Loader = Loader(arr[i]);
		 				var bitmap:BitmapData = new BitmapData(loader.content.width, loader.content.height, true, 0x00ff0000);
		 				bitmap.draw(loader.content);
		 				bmps.push(bitmap);
		 			}
		 			showInDockWithImages(bmps);
		 		});
		 	}
		 	
		 	return ed;
		}
		
		/**
		 * Gets all the images from the ApplicationDescriptor in the icon tags
		 * and calls the callback function passing an array of Loaders as the
		 * only argument.
		 */ 
		public static function getIconsFromAppDescriptor(callback:Function):void{
			var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
	 		var ns:Namespace = appDescriptor.namespace();
	 		var icons:XMLList = appDescriptor.ns::icon.("*");
	 		
	 		var total:int = icons.length();
	 		var loaders:Array = [];
	 		for(var i:int=0; i<icons.length(); i++){
	 			var iconPath:String = String(XML(icons[i]).children()[0])
	 			var loader:Loader = new Loader();
	 			loaders.push(loader);
	 			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void{
	 				total-=1;
	 				if(total == 0){
	 					callback(loaders);
	 				}
	 			})
	 			
	 			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
	 				trace("Error loading local image")	
	 			})
	 			loader.load(new URLRequest(File.applicationDirectory.resolvePath(iconPath).url));
	 		}
		}
		
		
		/**
		 * Returns:
		 * 
		 * 1 if v1 > v2;
		 * 0 if v1 = v2;
		 * -1 if v1 < v2;
		 */ 
		public static function isVersionGreater(version1:String, version2:String):int{
			var origArray:Array = version1.split(".");
			var version2Array:Array = version2.split(".");
			ArrayUtil.pad(origArray, Math.max(origArray.length, version2Array.length));
			ArrayUtil.pad(version2Array,Math.max(origArray.length, version2Array.length));
			
			for(var i:int=0; i<origArray.length; i++){
				if(version2Array[i] > origArray[i]){
					return 1;
				}
				if(version2Array[i] < origArray[i]){
					return -1;
				}
			}
			
			return 0;
			
		}
	}
}