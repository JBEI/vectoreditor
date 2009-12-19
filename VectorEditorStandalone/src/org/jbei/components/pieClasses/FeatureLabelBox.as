package org.jbei.components.pieClasses
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.IAnnotation;
	import org.jbei.components.common.LabelBox;
	
	public class FeatureLabelBox extends LabelBox
	{
		private var contentHolder:ContentHolder;
		
		private var _feature:Feature;
		
		// Contructor
		public function FeatureLabelBox(contentHolder:ContentHolder, relatedAnnotation:IAnnotation)
		{
			super(contentHolder, relatedAnnotation);
			
			this.contentHolder = contentHolder;
			
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
		
		protected override function render():void
		{
			var g:Graphics = graphics;
			g.clear();
			
			var featureBitMap:BitmapData = contentHolder.featureTextRenderer.textToBitmap(feature.label);
			
			_totalWidth = featureBitMap.width;
			_totalHeight = featureBitMap.height;
			
			g.beginBitmapFill(featureBitMap);
			g.drawRect(0, 0, featureBitMap.width, featureBitMap.height);
			g.endFill();
		}
		
		protected override function label():String
		{
			return _feature.label;
		}
	}
}
