package org.jbei.components.common
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class TextRenderer extends UIComponent
	{
		protected var _textFormat:TextFormat;
		protected var textField:TextField = new TextField();
		
		private var textMap:Dictionary = new Dictionary();
		
		private var _textWidth:int = -1;
		private var _textHeight:int = -1;
		private var widthGap:int = 0;
		private var heightGap:int = 0;
		
		// Constructor
		public function TextRenderer(textFormat:TextFormat, widthGap:int = 0, heightGap:int = 0)
		{
			super();
			
			_textFormat = textFormat;
			this.widthGap = widthGap;
			this.heightGap = heightGap;
		}
		
		// Properties
		public function get textFormat():TextFormat
		{
			return _textFormat;
		}
		
		public function set textFormat(value:TextFormat):void
		{
			if(_textFormat != value) {
				_textFormat = value;
				textField.defaultTextFormat = _textFormat;
				
				clearCache();
			}
		}
		
		public function get textWidth():int
		{
			return _textWidth;
		}
		
		public function get textHeight():int
		{
			return _textHeight;
		}
		
		// Public Methods
		public function textToBitmap(text:String):BitmapData
		{
			var cachedText:BitmapData = textMap[text];
			
			if(cachedText == null) {
				cachedText = renderText(text, widthGap, heightGap);
				textMap[text] = cachedText;
				
				_textWidth = cachedText.width;
				_textHeight = cachedText.height;
			}
			
			return cachedText;
		}
		
		public function clearCache():void
		{
			textMap = new Dictionary();
		}
		
		// Protected Methods
		protected override function createChildren():void
		{
			super.createChildren();
			
			textField.selectable = false;
			textField.defaultTextFormat = _textFormat;
			textField.autoSize = TextFieldAutoSize.LEFT;
			
			addChild(textField);
		}
		
		protected function renderText(text:String, widthGap:int = 0, heightGap:int = 0):BitmapData
		{
			textField.text = text;
			
			validateNow();
			
			var bitmapData:BitmapData = new BitmapData(textField.width - widthGap, textField.height - heightGap);
			bitmapData.draw(textField, null, null, null, new Rectangle(widthGap, heightGap, textField.width - widthGap, textField.height - heightGap));
			
			return bitmapData;
		}
	}
}
