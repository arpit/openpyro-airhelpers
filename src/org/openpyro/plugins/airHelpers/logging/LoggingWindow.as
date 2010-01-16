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
			var s:String = "<font face='Arial' color='"+getColorForLevel(level)+"'>[ "+source+" ] [ "+ Level.getLevelString(level) +" ] "+msg+"</font>";
			
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
import org.openPyro.controls.ScrollBar;
import org.openPyro.core.Direction;
import org.openPyro.aurora.AuroraScrollBarSkin;
import org.openPyro.controls.events.ScrollEvent;
import org.openPyro.controls.Label;
import flash.events.MouseEvent;
import flash.system.System;
import org.openPyro.aurora.AuroraContainerSkin;
import flash.text.TextFieldType;

class LoggingWindowUI extends UIContainer{
	
	private var _logs:Vector.<String>;
	
	private var searchField:TextInput;
	//private var scrollbar:ScrollBar;
	private var copyLabel:Label;
	private var textBox:TextArea;
	
	override protected function createChildren():void{
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
		
		
		textBox = new TextArea();
		textBox.size("100%","100%");
		addChild(textBox);
		
		copyLabel = new Label();
		copyLabel.size(130,25);
		copyLabel.text = "Copy to clipboard";
		var tf:TextFormat = new TextFormat("Arial",12, 0x444444);
		tf.align = "right";
		copyLabel.textFormat = tf
		copyLabel.buttonMode = true;
		copyLabel.useHandCursor = true;
		
		copyLabel.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{
			System.setClipboard(textBox.htmlText);
			copyLabel.text = "Copied..."
		});
		addChild(copyLabel);
		
		if(_logs){
			textBox.htmlText = _logs.join("\n");
		}
	}
	
	private function doFilter(event:Event):void{
		var s:Vector.<String> = new Vector.<String>;
		for(var i:int=0; i<_logs.length; i++){
			if(_logs[i].toLowerCase().indexOf(searchField.text.toLowerCase()) != -1){
				s.push(_logs[i])
			}
		}
		textBox.htmlText = s.join("\n");
	}
	
	override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		//scrollbar.x = unscaledWidth-scrollbar.width -10;
		searchField.y = 5;
		textBox.y = 35;
		copyLabel.y = 5;
		copyLabel.x = unscaledWidth - copyLabel.width-5;
	}
	
	public function set logs(l:Vector.<String>):void{
		if(copyLabel){
			copyLabel.text = "Copy to clipboard";
		}
		_logs = l;
		if(textBox){// && txt.textField){
			textBox.htmlText = _logs.join("\n");
		}
	}
	
	public function addLog(s:String):void{
		if(copyLabel){
			copyLabel.text = "Copy to clipboard";
		}
		if(searchField && searchField.text != ""){
			if(s.toLowerCase().indexOf(searchField.text.toLowerCase()) == -1){
				return;
			}
		}
		textBox.htmlText+=(s+"\n");	
	}
}

class TextArea extends UIContainer{
	private var _textField:TextField;
	
	override protected function createChildren():void{
		super.createChildren();
		
		this.backgroundPainter = new FillPainter(0xffffff);
		this.addEventListener(MouseEvent.CLICK, onClick);
		
		
		_textField = new TextField();
		_textField.width = 0;
		_textField.type = TextFieldType.DYNAMIC;
		//_textField.border = true;
		_textField.multiline = true;
		_textField.wordWrap = true;
		_textField.autoSize = "left";
		_textField.defaultTextFormat = new TextFormat("Arial",15)
		_textField.addEventListener(Event.CHANGE, onTxtChange)
		
		addChild(_textField);
		this.skin = new AuroraContainerSkin();
	}
	
	
	private function onClick(event:Event):void{
		stage.focus = _textField;
	}
	
	public function set text(t:String):void{
		if(_textField){
			_textField.text = t;
		}
	}
	
	public function set htmlText(t:String):void{
		
		if(_textField){
			dispatchEvent(new PyroEvent(PyroEvent.SIZE_INVALIDATED))
			_textField.htmlText = t;
		}
	}
	
	public function get htmlText():String{
		if(_textField){
			return _textField.htmlText;
		}
		return "";
	}
	
	
	private function onTxtChange(event:Event):void{
		dispatchEvent(new PyroEvent(PyroEvent.SIZE_INVALIDATED))
	}
	
	override public function calculateContentDimensions():void{
		super.calculateContentDimensions();
		_contentHeight = this._textField.height;
	}
	
	override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		if(_textField.width == 0){
			_textField.width = unscaledWidth-25;
		}
		
	}
	
}