package org.jbei.components.pieClasses
{
	import flash.text.TextFormat;
	
	import org.jbei.bio.data.CutSite;
	import org.jbei.bio.data.IAnnotation;

	public class CutSiteLabelBox extends LabelBox
	{
		private const FONT_FACE:String = "Tahoma";
		private const FONT_SIZE:int = 10;
		private const FONT_COLOR:int = 0x888888;
		private const SINGLE_CUTTER_FONT_COLOR:int = 0xE57676;
		
		private var cutSite:CutSite;
		
		// Constructor
		public function CutSiteLabelBox(contentHolder:ContentHolder, relatedAnnotation:IAnnotation)
		{
			super(contentHolder, relatedAnnotation);
			
			cutSite = relatedAnnotation as CutSite;
		}
		
		// Protected Methods
		protected override function tipText():String
		{
			return cutSite.label + ": " + (cutSite.start + 1) + ".." + (cutSite.end + 1) + (cutSite.forward ? "" : ", complement") + ", cuts " + cutSite.numCuts + " times";
		}
		
		protected override function textFormat():TextFormat
		{
			var fontColor:int = FONT_COLOR;
			
			if(cutSite.numCuts == 1) {
				fontColor = SINGLE_CUTTER_FONT_COLOR;
			}
			
			return new TextFormat(FONT_FACE, FONT_SIZE, fontColor);
		}
		
		protected override function label():String
		{
			return cutSite.label;
		}
	}
}
