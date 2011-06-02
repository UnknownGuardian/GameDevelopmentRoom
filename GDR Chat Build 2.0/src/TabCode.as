//Uses some of this code. Please respect its comments/license:
/*
AS3 Syntax Highlighting Example By Dean North - 23/01/07
Atlas Computer Systems Ltd - www.atlascs.co.uk
This code is free to use, as long as you keep this comment in the header
*/



package {
	
	import flash.net.*;
	import flash.display.*;
	import flash.events.*;
	import flash.system.Security;
	import flash.text.*;
	import fl.controls.TextArea;
	import fl.controls.Label;
	import fl.controls.UIScrollBar
	import fl.controls.Button;
	import flash.utils.getTimer;
	import ugLabs.net.Kong;
	
	import com.greensock.easing.*;
	import com.greensock.*;
	
	import playerio.*
	
	import SWFStats.*;
	
	public class TabCode extends Sprite
	{
			
		public var connection:Connection;
		private var client:Client
		
		//public var myText:TextArea
		public var myText:TextField;
		public var verticalScroll:UIScrollBar;
		public var horizontalScroll:UIScrollBar;
		
		public var myLabel:Label;
		
		public var loadField:TextArea;
		public var loadButton:Button;
		public var postButton:Button;
		public var clearButton:Button;
		public var highlightSyntaxButton:Button;
		
		public var isExpanded:Boolean = false;;
		
		
		
		//for syntax highlighter
		public var AS3KeyWords:String = "addEventListener|align|ArgumentError|arguments|Array|as|AS3|Boolean|break|case|catch|class|Class|const|continue|data|Date|decodeURI|decodeURIComponent|default|DefinitionError|delete|do|dynamic|each|else|encodeURI|encodeURIComponent|Error|escape|EvalError|extends|false|finally|flash_proxy|for|function|get|getLineOffset|height|if|implements|import|in|include|index|Infinity|instanceof|interface|internal|intrinsic|is|isFinite|isNaN|isXMLName|label|load|namespace|NaN|native|new|null|Null|object_proxy|override|package|parseFloat|parseInt|private|protected|public|return|set|static|super|switch|this|throw|trace|true|try|typeof|undefined|unescape|use|var|void|while|with|Accessibility|AccessibilityProperties|ActionScriptVersion|ActivityEvent|AntiAliasType|ApplicationDomain|AsyncErrorEvent|AVM1Movie|BevelFilter|Bitmap|BitmapData|BitmapDataChannel|BitmapFilter|BitmapFilterQuality|BitmapFilterType|BlendMode|BlurFilter|ByteArray|Camera|Capabilities|CapsStyle|ColorMatrixFilter|ColorTransform|ContextMenu|ContextMenuBuiltInItems|ContextMenuEvent|ContextMenuItem|ConvolutionFilter|CSMSettings|DataEvent|Dictionary|DisplacementMapFilter|DisplacementMapFilterMode|DisplayObject|DisplayObjectContainer|DropShadowFilter|Endian|EOFError|ErrorEvent|Event|EventDispatcher|EventPhase|ExternalInterface|FileFilter|FileReference|FileReferenceList|FocusEvent|Font|FontStyle|FontType|FrameLabel|Function|GlowFilter|GradientBevelFilter|GradientGlowFilter|GradientType|Graphics|GridFitType|HTTPStatusEvent|IBitmapDrawable|ID3Info|IDataInput|IDataOutput|IDynamicPropertyOutput|IDynamicPropertyWriter|IEventDispatcher|IExternalizable||IllegalOperationError|IME|IMEConversionMode|IMEEvent|int|InteractiveObject|InterpolationMethod|InvalidSWFError|IOError|IOErrorEvent|JointStyle|Keyboard|KeyboardEvent|KeyLocation|LineScaleMode|Loader|LoaderContext|LoaderInfo|LocalConnection|Math|Matrix|MemoryError|Microphone|MorphShape|Mouse|MouseEvent|MovieClip|Namespace|NetConnection|NetStatusEvent|NetStream|Number|Object|ObjectEncoding|PixelSnapping|Point|PrintJob|PrintJobOptions|PrintJobOrientation|ProgressEvent|Proxy|QName|RangeError|Rectangle|ReferenceError|RegExp|resize|result|Responder|scaleMode|Scene|ScriptTimeoutError|Security|SecurityDomain|SecurityError|SecurityErrorEvent|SecurityPanel|setTextFormat|Shape|SharedObject|SharedObjectFlushStatus|SimpleButton|Socket|Sound|SoundChannel|SoundLoaderContext|SoundMixer|SoundTransform|SpreadMethod|Sprite|StackOverflowError|Stage|stageHeight|stageWidth|StageAlign|StageQuality|StageScaleMode|StaticText|StatusEvent|String|StyleSheet|SWFVersion|SyncEvent|SyntaxError|System|text|TextColorType|TextDisplayMode|TextEvent|TextField|TextFieldAutoSize|TextFieldType|TextFormat|TextFormatAlign|TextLineMetrics|TextRenderer|TextSnapshot|Timer|TimerEvent|Transform|true|TypeError|uint|URIError|URLLoader|URLLoaderDataFormat|URLRequest|URLRequestHeader|URLRequestMethod|URLStream|URLVariables|VerifyError|Video|width|XML|XMLDocument|XMLList|XMLNode|XMLNodeType|XMLSocket";
		public var AS3SystemObjects:String = "not_set_yet";

		public var KeywordFormat:TextFormat = new TextFormat(null,null,0x0000FF);
		public var SystemObjectFormat:TextFormat = new TextFormat(null,null,0xFF0000);
		public var BracketFormat:TextFormat = new TextFormat(null,null,0x000000);
		public var StringFormat:TextFormat = new TextFormat(null,null,0x009900);
		public var CommentFormat:TextFormat = new TextFormat(null,null,0x008000);
		public var DefaultFormat:TextFormat;

		public var SingleQuoteString:RegExp = new RegExp("\'.*\'","g");
		public var DoubleQuoteString:RegExp = new RegExp("\".*\"","g");
		public var StartMultiLineQuote:RegExp = new RegExp("/\\*.*","g")
		public var EndMultiLineQuote:RegExp = new RegExp("\\*/.*","g")
		public var KeyWords:RegExp = new RegExp("(\\b)(" + AS3KeyWords + "){1}(\\.|(\\s)+|;|,|\\(|\\)|\\]|\\[|\\{|\\}){1}","g");
		public var SystemObjects:RegExp = new RegExp("(\\b)(" + AS3SystemObjects + "){1}(\\.|(\\s)+|;|,|\\(|\\)|\\]|\\[|\\{|\\}){1}","g");
		public var Comment:RegExp = new RegExp("//.*","g");
		public var Brackets:RegExp = new RegExp("(\\{|\\[|\\(|\\}|\\]|\\))","g");
		
		
		
		
		
		public function TabCode()
		{
			trace("[TabCode] Created");
			addEventListener(Event.ADDED_TO_STAGE,drawCodeBox);
		}
		
		
		
		
		public function drawCodeBox(e:Event = null):void
		{			
			removeEventListener(Event.ADDED_TO_STAGE,drawCodeBox);
			trace("[TabCode] Drawing code box");
			
			graphics.beginFill(0x000000,0.7);
			graphics.drawRect(0,5,stage.stageWidth-33,stage.stageHeight);
			graphics.endFill();
			
			var cou:Font = new CourierCode();
			
			myText = new TextField();
			myText.defaultTextFormat = new TextFormat(cou.fontName);
			myText.background = true;
			myText.x = 5;
			myText.y = 10;
			myText.width = stage.stageWidth - 57;
			myText.height = stage.stageHeight - 20 - 23 - 15; //23 is for buttons, 15 for scroll bar
			myText.wordWrap = false;
			myText.multiline = true;
			myText.useRichTextClipboard = true;
			myText.type = "input";
			addChild(myText);
			
			verticalScroll = new UIScrollBar();
			verticalScroll.scrollTarget = myText;
			verticalScroll.x = myText.x + myText.width + 1;
			verticalScroll.y = myText.y;
			verticalScroll.height = myText.height;
			addChild(verticalScroll);
			
			horizontalScroll = new UIScrollBar();
			horizontalScroll.direction = "horizontal";
			horizontalScroll.scrollTarget = myText;
			horizontalScroll.x = myText.x;
			horizontalScroll.y = myText.y + myText.height + 1;
			horizontalScroll.width = myText.width;
			addChild(horizontalScroll);
			
			
			
			loadField = new TextArea();
			loadField.x = 5;
			loadField.y = stage.stageHeight - 31;
			loadField.width = 150;
			loadField.height = 23;
			loadField.text = "";
			addChild(loadField);
			
			loadButton = new Button();
			loadButton.label = "Load Code";
			loadButton.x = 160;
			loadButton.y = stage.stageHeight - 31;
			addChild(loadButton);
			
			loadButton.addEventListener(MouseEvent.CLICK,loadCode);
			
			postButton = new Button();
			postButton.label = "Post Code";
			postButton.x = loadButton.x + loadButton.width + 5;
			postButton.y = stage.stageHeight - 31;
			addChild(postButton);
			
			postButton.addEventListener(MouseEvent.CLICK,postCode);
			
			clearButton = new Button();
			clearButton.label = "Clear Code";
			clearButton.x = postButton.x + postButton.width + 5;
			clearButton.y = stage.stageHeight - 31;
			addChild(clearButton);
			
			clearButton.addEventListener(MouseEvent.CLICK,clearCode);
			
			
			highlightSyntaxButton = new Button();
			highlightSyntaxButton.label = "Highlight Code";
			highlightSyntaxButton.x = clearButton.x + clearButton.width + 5;
			highlightSyntaxButton.y = stage.stageHeight - 31;
			addChild(highlightSyntaxButton);
			
			highlightSyntaxButton.addEventListener(MouseEvent.CLICK, HighlightSyntax);
			
			preventTab();
			
			DefaultFormat = new TextFormat(null,null,0x000000);
			var cour:Font = new CourierCode();
			DefaultFormat.font = cour.fontName;
		}
		
		public function preventTab():void
		{
			myText.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, TextKeyFocusChange);
		}
		private function TextKeyFocusChange(e:FocusEvent):void
		{
			
			Log.CustomMetric("Prevented Tab in Code Box", "Other");
			
			//prevents from shifting to other Flash component
			e.preventDefault();
			
			//gets current textfield that you want to add the tab to
			var txt:TextField = TextField(e.currentTarget);
			
			var t:String = txt.text;
			t = t.substr(0, txt.selectionBeginIndex) + "\t" + t.substr(txt.selectionEndIndex);
			txt.text = t;
			txt.setSelection(txt.selectionBeginIndex+1, txt.selectionBeginIndex+1);
		}
		
		
		
		public function handleLabelClick(e:MouseEvent = null):void
		{
			if (isExpanded)
			{
				TweenLite.to(this,1,{x:stage.stageWidth});
			}
			else
			{
				TweenLite.to(this,1,{x:0});
			}
			//change to opposite
			isExpanded = !isExpanded;
		}
		
		public function clearCode(e:MouseEvent):void
		{
			//clear code box
			myText.text = "";
		}
		
		
		
		
		
		
		
		public function postCode(e:MouseEvent):void
		{
			if(myText.text.length < 5)
			{
				return;
			}

			//get the key that you want to store the data with. Uses userName + the time elapsed in milliseconds since app starts. Prevents most overlapping
			var key:String = "codeD" + Kong.userName.substr(0, 7) + getTimer();
			//post to database
			Main.client.bigDB.createObject("CodeBox",key,{data:myText.text},textPostingCallback,textPostingError);
		}	
		public function textPostingError(e:*):void
		{

			//error in trying to add to database
			loadField.text = e.toString();
		}
		public function textPostingCallback(o:DatabaseObject):void
		{
			//post the short url in the loadField
			loadField.text = o.key;
		}
		
		
		
		public function loadCode(e:Event = null):void
		{
			//check if its called from chat
			if(e == null)
			{
				handleLabelClick();
			}
			
			var key:String = loadField.text;
			if(key.length < 6)
			{
				return;
			}
			key = stripSpacesInString(key);
			Main.client.bigDB.load("CodeBox",key,textLoadingCallback,textLoadingError);
		}
		public function textLoadingError(e:*):void
		{
			myText.text = "Could not load data" + e;
		}
		public function textLoadingCallback(o:DatabaseObject):void
		{
			Log.CustomMetric("loading Code Success", "Code Box");
			myText.text = o.data;
			
			verticalScroll.scrollTarget = myText;
			horizontalScroll.scrollTarget = myText;
			horizontalScroll.update();
			verticalScroll.update();
		}
		
		
		
		
		
		
		
		//util class. Soon to be moved into local libraries
		public function stripSpacesInString(originalstring:String):String
		{
			var original:Array=originalstring.split(" ");
			return(original.join(""));
		}
		
		
		
		
		
		
		//Syntax Highlighter
		public function HighlightSyntax(e:MouseEvent = null):void
		{
			
			Log.CustomMetric("Highlighted Code", "Code Box");
			
			var InMultilineComment:Boolean = false;
			for(var i:int=0;i<myText.numLines;i++){
				if(InMultilineComment){
					myText.setTextFormat(CommentFormat,myText.getLineOffset(i),myText.getLineOffset(i)+myText.getLineText(i).length);
					InMultilineComment = !ParseExpression(EndMultiLineQuote,CommentFormat,i,false);
				} else {
					var CommentIndex:Number
					ParseExpression(KeyWords,KeywordFormat,i,true);
					ParseExpression(SystemObjects,SystemObjectFormat,i,true);
					ParseExpression(Brackets,BracketFormat,i,false);
					ParseExpression(SingleQuoteString,StringFormat,i,false);
					ParseExpression(DoubleQuoteString,StringFormat,i,false);
					CommentIndex = Number(ParseExpression(Comment,CommentFormat,i,false,true));
					InMultilineComment = ParseExpression(StartMultiLineQuote,CommentFormat,i,false,true);
					if(InMultilineComment){InMultilineComment = !ParseExpression(EndMultiLineQuote,CommentFormat,i,false,true);}
				}
			}
		}
		
		
		public function ParseExpression(exp:RegExp,format:TextFormat,lineno:Number,Trim:Boolean,DontSearchStrings:Boolean=false):Boolean{
			var result:Object = exp.exec(myText.getLineText(lineno))
			if (result == null) {return false};
			while (result != null) {
				if(DontSearchStrings){
					var IsInString:Boolean = false;
					if(InString(result,DoubleQuoteString,lineno) == true){IsInString = true}
					if(InString(result,SingleQuoteString,lineno) == true){IsInString = true}
					if(IsInString){return false}
				}
				if(Trim){
					myText.setTextFormat(format,myText.getLineOffset(lineno) + result.index,myText.getLineOffset(lineno) + result.index+result[0].length - 1);
				} else {
					myText.setTextFormat(format,myText.getLineOffset(lineno) + result.index,myText.getLineOffset(lineno) + result.index+result[0].length);
				}
				result = exp.exec(myText.getLineText(lineno));
			}
			return true;
		}
		
		public function InString(result:Object,exp:RegExp,lineno:Number):Boolean{
			var stringResult:Object = exp.exec(myText.getLineText(lineno))
			var IsInString:Boolean = false;
			while (stringResult != null) {
				if(result.index > stringResult.index && result.index < stringResult.index + stringResult[0].length){
					IsInString = true;
				}
				stringResult = exp.exec(myText.getLineText(lineno))
			}
			return IsInString
		}
		
		
		
		
		
	}	
}