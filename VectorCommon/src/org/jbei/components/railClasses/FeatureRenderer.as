package org.jbei.components.railClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.jbei.bio.sequence.common.StrandType;
	import org.jbei.bio.sequence.dna.Feature;
	import org.jbei.components.common.AnnotationRenderer;

	public class FeatureRenderer extends AnnotationRenderer
	{
		public static const DEFAULT_FEATURE_HEIGHT:int = 10;
		public static const DEFAULT_GAP:int = 5;
		public static const RAIL_GAP:Number = 10;
		
		private const FRAME_COLOR:int = 0x606060;
		
		private var _connectionPoint:Point;
		
		private var alignmentRowIndex:int;
		private var bpWidth:Number;
		private var railMetrics:Rectangle;
		
		// Contructor
		public function FeatureRenderer(contentHolder:ContentHolder, feature:Feature)
		{
			super(contentHolder, feature);
		}
		
		// Properties
		public function get connectionPoint():Point
		{
			return _connectionPoint;
		}
		
		public function get feature():Feature
		{
			return annotation as Feature;
		}
		
		// Public Methods
		public function update(railMetrics:Rectangle, bpWidth:Number, alignmentRowIndex:int):void
		{
			this.alignmentRowIndex = alignmentRowIndex;
			this.railMetrics = railMetrics;
			this.bpWidth = bpWidth;
			
			needsMeasurement = true;
			invalidateDisplayList();
		}
		
		// Protected Methods
		protected override function render():void
		{
			var color:int = colorByType(feature.type.toLowerCase());
			
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, FRAME_COLOR);
			
			var xStartPosition:Number = railMetrics.x + bpWidth * feature.start;
			var xEndPosition:Number = railMetrics.x + bpWidth * feature.end;
			var yPosition:Number = railMetrics.y + RailBox.THICKNESS + RAIL_GAP + alignmentRowIndex * (DEFAULT_FEATURE_HEIGHT + DEFAULT_GAP);
			
			_connectionPoint = new Point(xStartPosition, (yPosition + yPosition + RailBox.THICKNESS) / 2);
			
			if(feature.start <= feature.end) { // non-circular feature
				var featureWidth:Number = bpWidth * (feature.end - feature.start + 1);
				
				g.beginFill(color);
				switch(feature.strand) {
					case StrandType.FORWARD:
						drawFeaturePositiveArrow(g, xStartPosition, yPosition, featureWidth, DEFAULT_FEATURE_HEIGHT);
						
						break;
					case StrandType.BACKWARD:
						drawFeatureNegativeArrow(g, xStartPosition, yPosition, featureWidth, DEFAULT_FEATURE_HEIGHT);
						
						break;
					default:
						drawFeatureRect(g, xStartPosition, yPosition, featureWidth, DEFAULT_FEATURE_HEIGHT);
						
						break;
				}
				g.endFill();
			} else { // circular feature
				var startPosition:Number = railMetrics.x;
				var endPosition:Number = railMetrics.x + contentHolder.featuredSequence.sequence.length * bpWidth;
				
				switch(feature.strand) {
					case StrandType.FORWARD:
						g.beginFill(color);
						drawFeatureRect(g, xStartPosition, yPosition, endPosition - xStartPosition, DEFAULT_FEATURE_HEIGHT);
						g.endFill();
						
						g.beginFill(color);
						drawFeaturePositiveArrow(g, startPosition, yPosition, xEndPosition - railMetrics.x, DEFAULT_FEATURE_HEIGHT);
						g.endFill();
						
						break;
					case StrandType.BACKWARD:
						g.beginFill(color);
						drawFeatureNegativeArrow(g, xStartPosition, yPosition, endPosition - xStartPosition, DEFAULT_FEATURE_HEIGHT);
						g.endFill();
						
						g.beginFill(color);
						drawFeatureRect(g, startPosition, yPosition, xEndPosition - railMetrics.x, DEFAULT_FEATURE_HEIGHT);
						g.endFill();
						
						break;
					default:
						g.beginFill(color);
						drawFeatureRect(g, xStartPosition, yPosition, endPosition - xStartPosition, DEFAULT_FEATURE_HEIGHT);
						g.endFill();
						
						g.beginFill(color);
						drawFeatureRect(g, startPosition, yPosition, xEndPosition - railMetrics.x, DEFAULT_FEATURE_HEIGHT);
						g.endFill();
						
						break;
				}
			}
			
			
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = feature.type + (feature.name == "" ? "" : (" - " + feature.name)) + ": " + (feature.start + 1) + ".." + (feature.end + 1);
		}
		
		// Private Methods
		private function colorByType(featureType:String):int
		{
			var color:int = 0xCCCCCC;
			
			if(featureType == "promoter") {
				color = 0x31B440;
			} else if(featureType == "terminator"){
				color = 0xF51600;
			} else if(featureType == "cds"){
				color = 0xEF6500;
			} else if(featureType == "m_rna"){
				color = 0xFFFF00;
			} else if(featureType == "misc_binding"){
				color = 0x006FEF;
			} else if(featureType == "misc_feature"){
				color = 0x006FEF;
			} else if(featureType == "misc_marker"){
				color = 0x8DCEB1;
			} else if(featureType == "rep_origin"){
				color = 0x878787;
			}
			
			return color;
		}
		
		private function drawFeatureRect(g:Graphics, x:Number, y:Number, width:Number, height:Number):void
		{
			g.drawRect(x, y, width, height);
		}
		
		private function drawFeaturePositiveArrow(g:Graphics, x:Number, y:Number, width:Number, height:Number):void
		{
			if(width > 8) {
				g.moveTo(x, y);
				g.lineTo(x + width - 8, y);
				g.lineTo(x + width, y + height / 2);
				g.lineTo(x + width - 8, y + height);
				g.lineTo(x, y + height);
				g.lineTo(x, y);
			} else {
				g.moveTo(x, y);
				g.lineTo(x + width, y + height / 2);
				g.lineTo(x, y + height);
				g.lineTo(x, y);
			}
		}
		
		private function drawFeatureNegativeArrow(g:Graphics, x:Number, y:Number, width:Number, height:Number):void
		{
			if(width > 8) {
				g.moveTo(x + 8, y);
				g.lineTo(x + width, y);
				g.lineTo(x + width, y + height);
				g.lineTo(x + 8, y + height);
				g.lineTo(x, y + height / 2);
				g.lineTo(x + 8, y);
			} else {
				g.moveTo(x, y + height / 2);
				g.lineTo(x + width, y);
				g.lineTo(x + width, y + height);
				g.lineTo(x, y + height / 2);
			}
		}
	}
}
