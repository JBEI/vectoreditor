package org.jbei.components.pieClasses
{
	import flash.text.TextFormat;
	
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.IAnnotation;

	public class FeatureLabelBox extends LabelBox
	{
		private const FONT_FACE:String = "Tahoma";
		private const FONT_SIZE:int = 11;
		private const FONT_COLOR:int = 0x000000;
		
		private var feature:Feature;
		
		// Contructor
		public function FeatureLabelBox(contentHolder:ContentHolder, relatedAnnotation:IAnnotation)
		{
			super(contentHolder, relatedAnnotation);
			
			feature = relatedAnnotation as Feature;
		}
		
		// Protected Methods
		protected override function tipText():String
		{
			return feature.type + (feature.label == "" ? "" : (" - " + feature.label)) + ": " + (feature.start + 1) + ".." + (feature.end + 1);
		}
		
		protected override function textFormat():TextFormat
		{
			return new TextFormat(FONT_FACE, FONT_SIZE, FONT_COLOR);
		}
		
		protected override function label():String
		{
			return feature.label;
		}
	}
}
