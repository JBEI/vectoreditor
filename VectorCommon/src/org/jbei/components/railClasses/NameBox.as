package org.jbei.components.railClasses
{
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.core.FlexTextField;
	import mx.core.UIComponent;
	
	public class NameBox extends UIComponent
	{
		private const FONT_FACE:String = "Tahoma";
		private const LABEL_FONT_SIZE:String = "14";
		private const LENGTH_FONT_SIZE:String = "11";
		private const FONT_COLOR:String = "#000000";
		
		private var contentHolder:ContentHolder;
		private var labelTextField:FlexTextField;
		
		private var numberOfBp:int = 0;
		private var label:String = "";
		
		private var needsMeasurement:Boolean = false;
		
		// Constructor
		public function NameBox(contentHolder:ContentHolder)
		{
			super();
			
			this.contentHolder = contentHolder;
		}
		
		// Public Methods
		public function update(label:String, numberOfBp:int):void
		{
			this.label = label;
			this.numberOfBp = numberOfBp;
			
			needsMeasurement = true;
			invalidateDisplayList();
		}
		
		// Protected Methods
		protected override function createChildren():void
		{
			super.createChildren();
			
			if(!labelTextField) {
				labelTextField = new FlexTextField();
				labelTextField.autoSize = TextFieldAutoSize.CENTER;
				labelTextField.selectable = false;
				//labelTextField.defaultTextFormat = new TextFormat(FONT_FACE, FONT_SIZE, FONT_COLOR);
				addChild(labelTextField);
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(needsMeasurement) {
				needsMeasurement = false;
				
				render();
			}
		}
		
		// Private Methods
		private function render():void
		{
			labelTextField.htmlText = '<p align="center"><font face="' + FONT_FACE + '" size="' + LABEL_FONT_SIZE + '" color="' + FONT_COLOR + '" letterspacing="0" kerning="0"><b>' + label + "</b></font>" + '<font face="' + FONT_FACE + '" size="' + LENGTH_FONT_SIZE + '" color="' + FONT_COLOR + '" letterspacing="0" kerning="0"> (' + String(numberOfBp) + " bp)" + "</font></p>";
			labelTextField.x = contentHolder.hCenter - labelTextField.width / 2;
			labelTextField.y = contentHolder.totalHeight - labelTextField.height - 20; // -20 for scrollbar
		}
	}
}
