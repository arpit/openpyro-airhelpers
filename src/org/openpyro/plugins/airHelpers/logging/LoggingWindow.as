package org.openpyro.plugins.airHelpers.logging
{
	import __AS3__.vec.Vector;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import net.comcast.logging.Level;
	import net.comcast.logging.consoles.IConsole;

	public class LoggingWindow implements IConsole
	{
		public function LoggingWindow()
		{
			logs = new Vector.<String>;
		}
		
		private var _nativeWindow:NativeWindow;
		private var ui:LoggingWindowUI 
				
				
		public function open():void{
			if(!ui){
				ui = new LoggingWindowUI();
				ui.logs = logs;
			}
			
			if(!_nativeWindow){
				
				var options:NativeWindowInitOptions = new NativeWindowInitOptions();
				//options.type = NativeWindowType.UTILITY;
				_nativeWindow = new NativeWindow(options);
				_nativeWindow.stage.scaleMode = "noScale";
				_nativeWindow.stage.align = "TL";
				_nativeWindow.title = "Activity Window";
				
				_nativeWindow.stage.addChild(ui);
				ui.width = _nativeWindow.stage.stageWidth;
				ui.height = _nativeWindow.stage.stageHeight;
				
				var resizeResponder:Function = function(event:Event):void{
					ui.width = _nativeWindow.stage.stageWidth;
					ui.height = _nativeWindow.stage.stageHeight;
					ui.validateSize()
					ui.validateDisplayList();
				}
				
				
				_nativeWindow.addEventListener(Event.RESIZE,resizeResponder );
				_nativeWindow.addEventListener(Event.CLOSE, function(event:Event):void{
					_nativeWindow.removeEventListener(Event.CLOSE, arguments.callee);
					_nativeWindow.removeEventListener(Event.RESIZE, resizeResponder);
					_nativeWindow = null;
					ui = null;
				});	
			}
			_nativeWindow.activate();
		}
		
		private var logs:Vector.<String>;

		public function log(source:*, level:Number, msg:String):void
		{
			if(!(source is String)){
				var a:Array =  getQualifiedClassName(source).split("::");
				source = a[a.length-1]
			}
			var s:String = "<font color='"+getColorForLevel(level)+"'>[ "+source+" ] [ "+ Level.getLevelString(level) +" ] "+msg+"</font>";
			
			logs.push(s);
			if(ui){
				ui.addLog(s)
			}
		}
		
		private function getColorForLevel(level:Number):String{
			if(level >=  Level.WARN){
				return "#ff0000";
			}
			else{
				return "#989898";
			}
		}
		
	}
}

import org.openPyro.core.UIContainer;
import org.openPyro.controls.Text;
import flash.text.TextFormat;
import __AS3__.vec.Vector;
import flash.text.TextField;
import org.openPyro.core.UIControl;
import org.openPyro.painters.FillPainter;
import org.openPyro.controls.TextInput;
import org.openPyro.layout.VLayout;
import org.openPyro.core.Padding;
import org.openPyro.events.PyroEvent;
import flash.events.Event;

class LoggingWindowUI extends UIContainer{
	private var text:TextField;
	private var _logs:Vector.<String>;
	private var txt:Text;
	
	private var searchField:TextInput;
	
	override protected function createChildren():void{
		//text = new TextField;
		
		
		this.layout = new VLayout();
		
		var header:UIControl = new UIControl();
		header.size("100%", 30);
		
		header.backgroundPainter = new FillPainter(0xdfdfdf);
		addChild(header)
		
		searchField = new TextInput();
		searchField.width = 120;
		searchField.height = 20;
		searchField.backgroundPainter = new FillPainter(0xfffffff,1,null,20);
		searchField.x = 10;
		searchField.y = 2;
		searchField.addEventListener(PyroEvent.ENTER, doFilter);
		header.addChild(searchField);
		
		
		var fmt:TextFormat = new TextFormat("Arial", 12);
		fmt.leading = 4;
		
		text = new TextField();
		text.defaultTextFormat = fmt; 
		text.autoSize = "left";
		text.wordWrap = true;
		text.multiline = true;
		addChild(text);
		
		//txt = new Text();
		//txt.size("100%","100%");
		//txt.textFormat = fmt;
		//addChild(txt);
		
		if(_logs){
			text.htmlText = _logs.join("\n");
		}
	}
	
	private function doFilter(event:Event):void{
		var s:Vector.<String> = new Vector.<String>;
		for(var i:int=0; i<_logs.length; i++){
			if(_logs[i].toLowerCase().indexOf(searchField.text.toLowerCase()) != -1){
				s.push(_logs[i])
			}
		}
		text.htmlText = s.join("\n");
	}
	
	override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		searchField.y = 5;
		text.width = unscaledWidth;
		text.height = unscaledHeight-35;
		text.y = 32;
	}
	
	public function set logs(l:Vector.<String>):void{
		_logs = l;
		if(text){// && txt.textField){
			text.text = _logs.join("\n");
		}
	}
	
	public function addLog(s:String):void{
		if(!text) return;
		if(searchField && searchField.text != ""){
			if(s.toLowerCase().indexOf(searchField.text.toLowerCase()) == -1){
				return;
			}
		}
		text.htmlText+=(s+"\n");
	}
}