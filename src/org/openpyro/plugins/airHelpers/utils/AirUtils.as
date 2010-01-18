package org.openpyro.plugins.airHelpers.utils
{
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.NativeMenu;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	
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
		 * @param 	undockEventListener		Function to be invoked when the undock event happens. If that function
		 * 									returns false, the window is not made visible
		 * @param	menuGenerator			Function that returns a NativeMenu object that will be attached to 
		 * 									the icon. This happens at the instant of the event so it can be dynamic
		 * 									at different times.
		 *  
		 * @see http://www.adobe.com/devnet/air/flash/quickstart/stopwatch_dock_system_tray.html
		 */  
		 public static function makeMinimizableOnClose(win:NativeWindow, dockedIconBitmaps:Array, undockEventListener:Function=null,  menu:NativeMenu=null):void{
		 	
		 	var undockELWrapper:Function = function(event:Event):void{
		 		if(undockEventListener != null){
		 			var showWindow:Boolean = undockEventListener(event);
		 			if(!showWindow){
		 				return;
		 			}
		 		}
		 		NativeApplication.nativeApplication.icon.bitmaps = [];
		 		win.visible = true;	
		 	};
		 	
		 	var isExiting:Boolean = false;
		 	
		 	var na:NativeApplication = NativeApplication.nativeApplication;
		 	na.autoExit = false;
		 	na.addEventListener(InvokeEvent.INVOKE, undockELWrapper);
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
		 		event.preventDefault();
		 		win.visible=false;
		 		showInDockOrSystemTray(dockedIconBitmaps, function(event:Event):void{}, win.title, menu);
		 	});
		 }
		 
		 /**
		 * Shows one of the Bitmaps in the dockedIconBitmaps Array in the OS Dock or System Tray
		 * and calls the undockListener an event when the icon in the dock is clicked on on either OS. 
		 */ 
		 public static function showInDockOrSystemTray(dockedIconBitmaps:Array, undockEventListener:Function, tooltip:String, menu:NativeMenu=null):void{
		 	if(NativeApplication.supportsDockIcon){
			    var dockIcon:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
			    NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, undockEventListener);
			    if(menu){
			    	dockIcon.menu = menu;
			    }
			} else if (NativeApplication.supportsSystemTrayIcon){
				
			    var sysTrayIcon:SystemTrayIcon =
			    NativeApplication.nativeApplication.icon as SystemTrayIcon;
			    sysTrayIcon.tooltip = tooltip;
			    sysTrayIcon.addEventListener(MouseEvent.CLICK,undockEventListener);
			   	NativeApplication.nativeApplication.icon.bitmaps = dockedIconBitmaps;
			   	if(menu != null){
				 	sysTrayIcon.menu = menu;
				}	
			}	
		}
	}
}