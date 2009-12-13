package org.jbei.components.railClasses
{
	import flash.text.TextFormat;
	
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.IAnnotation;
	import org.jbei.components.common.LabelBox;

	public class FeatureLabelBox extends LabelBox
	{
		private const FONT_FACE:String = "Tahoma";
		private const FONT_SIZE:int = 11;
		private const FONT_COLOR:int = 0x000000;
		
		private var _feature:Feature;
		
		// Contructor
		public function FeatureLabelBox(contentHolder:ContentHolder, relatedAnnotation:IAnnotation)
		{
			super(contentHolder, relatedAnnotation);
			
			_feature = relatedAnnotation as Feature;
		}
		
		// Properties
		public function get feature():Feature
		{
			return _feature;
		}
		
		// Protected Methods
		protected override function tipText():String
		{
			return _feature.type + (_feature.label == "" ? "" : (" - " + _feature.label)) + ": " + (_feature.start + 1) + ".." + (_feature.end + 1);
		}
		
		protected override function textFormat():TextFormat
		{
			return new TextFormat(FONT_FACE, FONT_SIZE, FONT_COLOR);
		}
		
		protected override function label():String
		{
			return _feature.label;
		}
	}
}
