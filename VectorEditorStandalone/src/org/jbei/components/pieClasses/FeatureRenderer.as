package org.jbei.components.pieClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.jbei.bio.data.Feature;
	import org.jbei.components.common.GraphicUtils;
	import org.jbei.components.pieClasses.AnnotationRenderer;

	public class FeatureRenderer extends AnnotationRenderer
	{
		private const DEFAULT_FEATURE_HEIGHT:int = 10;
		private const DEFAULT_FEATURES_GAP:int = 5;
		private const FRAME_COLOR:int = 0x606060;
		
		private var _middlePoint:Point;
		
		private var center:Point;
		private var railRadius:Number;
		private var angle1:Number;
		private var angle2:Number;
		private var featureRadius:Number;
		private var featureAlignmentMap:Dictionary;
		
		// Contructor
		public function FeatureRenderer(contentHolder:ContentHolder, feature:Feature)
		{
			super(contentHolder, feature);
		}
		
		// Properties
		public function get middlePoint():Point
		{
			return _middlePoint;
		}
		
		public function get feature():Feature
		{
			return annotation as Feature;
		}
		
		// Public Methods
		public function update(center:Point, railRadius:Number, featureAlignmentMap:Dictionary):void
		{
			this.center = center;
			this.railRadius = railRadius;
			this.featureAlignmentMap = featureAlignmentMap;
			
			var rowIndex:int = featureAlignmentMap[feature];
			
			featureRadius = railRadius - DEFAULT_FEATURES_GAP - 2*DEFAULT_FEATURES_GAP;
			if(rowIndex > 0) {
				featureRadius -= rowIndex * (DEFAULT_FEATURE_HEIGHT + DEFAULT_FEATURES_GAP);
			}
			
			angle1 = feature.start * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			angle2 = (feature.end + 1) * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			
			var centralAngle:Number;
			
			if(angle1 > angle2) {
				var virtualCenter:Number = angle2 - (((2 * Math.PI - angle1) + angle2) / 2);
				
				centralAngle = (virtualCenter > 0) ? virtualCenter : (2 * Math.PI + virtualCenter);
			} else {
				centralAngle = (angle1 + angle2) / 2;
			}
			
			_middlePoint = GraphicUtils.pointOnCircle(center, centralAngle, featureRadius);
			
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
			g.beginFill(color);
			
			var direction:uint = 0;
			if(feature.strand == Feature.POSITIVE) {
				direction = 1;
			} else if(feature.strand == Feature.NEGATIVE) {
				direction = 2;
			} else {
				direction = 0;
			}
			
			GraphicUtils.drawDirectedPiePiece(g, center, featureRadius, DEFAULT_FEATURE_HEIGHT, angle1, angle2, direction);
			
			g.endFill();
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = feature.type + (feature.label == "" ? "" : (" - " + feature.label)) + ": " + (feature.start + 1) + ".." + (feature.end + 1);
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
	}
}
