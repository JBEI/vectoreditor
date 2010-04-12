package org.jbei.components.pieClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.Segment;
	import org.jbei.bio.data.TraceAnnotation;
	import org.jbei.components.common.AnnotationRenderer;
	import org.jbei.components.common.GraphicUtils;

	public class TraceRenderer extends AnnotationRenderer
	{
		public static const DISTANCE_FROM_RAIL:Number = 15;
		public static const DISTANCE_BETWEEN_TRACES:Number = 10;
		private const MATCH_COLOR:int = 0x31B440;
		private const MISMATCH_COLOR:int = 0xFF0000;
		
		private var tracesAlignmentMap:Dictionary;
		private var railRadius:Number;
		private var center:Point;
		
		// Contructor
		public function TraceRenderer(contentHolder:ContentHolder, traceAnnotation:TraceAnnotation)
		{
			super(contentHolder, traceAnnotation);
		}
		
		// Properties
		public function get traceAnnotation():TraceAnnotation
		{
			return annotation as TraceAnnotation;
		}
		
		// Public Methods
		public function update(railRadius:Number, center:Point, traceAnnotationMap:Dictionary):void
		{
			this.tracesAlignmentMap = traceAnnotationMap;
			this.railRadius = railRadius;
			this.center = center;
			
			needsMeasurement = true;
			invalidateDisplayList();
		}
		
		// Protected Methods
		protected override function render():void
		{
			var g:Graphics = graphics;
			g.clear();
			
			// render curve
			var rowIndex:int = tracesAlignmentMap[traceAnnotation];
			
			var traceAnnotationRadius:Number = railRadius + DISTANCE_FROM_RAIL;
			if(rowIndex > 0) {
				traceAnnotationRadius += rowIndex * DISTANCE_BETWEEN_TRACES;
			}
			
			var matches:ArrayCollection = traceAnnotation.matches;
			var mismatches:ArrayCollection = traceAnnotation.mismatches;
			var deletions:ArrayCollection = traceAnnotation.deletions;
			var insertions:ArrayCollection = traceAnnotation.insertions;
			
			if(matches == null && matches.length == 0) {
				return;
			}
			
			// render matches
			g.lineStyle(2, MATCH_COLOR);
			
			var matchAngle1:Number = traceAnnotation.traceSequence.traceSequenceAlignment.queryStart * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			var matchAngle2:Number = (traceAnnotation.traceSequence.traceSequenceAlignment.queryEnd + 1) * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			
			g.moveTo(center.x + traceAnnotationRadius * Math.sin(matchAngle1), center.y - traceAnnotationRadius * Math.cos(matchAngle1));
			GraphicUtils.drawArc(g, center, traceAnnotationRadius, matchAngle1, matchAngle2);
			
			// render mismatches
			if(mismatches != null && mismatches.length > 0) {
				for(var i2:int = 0; i2 < mismatches.length; i2++) {
					var mismatchSegment:Segment = mismatches[i2] as Segment;
					
					var mismatchAngle1:Number = mismatchSegment.start * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
					var mismatchAngle2:Number = (mismatchSegment.end + 1) * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
					
					if(mismatchSegment.start == mismatchSegment.end) {
						g.lineStyle(2, MISMATCH_COLOR);
						
						var mismatchX:Number = center.x + traceAnnotationRadius * Math.sin(mismatchAngle1);
						var mismatchY:Number = center.y - traceAnnotationRadius * Math.cos(mismatchAngle1);
						
						g.drawCircle(mismatchX, mismatchY, 1);
					} else {
						g.lineStyle(4, MISMATCH_COLOR);
						
						g.moveTo(center.x + traceAnnotationRadius * Math.sin(mismatchAngle1), center.y - traceAnnotationRadius * Math.cos(mismatchAngle1));
						GraphicUtils.drawArc(g, center, traceAnnotationRadius, mismatchAngle1, mismatchAngle2);
					}
				}
			}
			
			// render deletions
			if(deletions != null && deletions.length > 0) {
				for(var i3:int = 0; i3 < deletions.length; i3++) {
					var deletionSegment:Segment = deletions[i3] as Segment;
					
					var deletionAngle1:Number = deletionSegment.start * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
					var deletionAngle2:Number = (deletionSegment.end + 1) * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
					
					if(deletionSegment.start == deletionSegment.end) {
						g.lineStyle(2, MISMATCH_COLOR);
						
						var deletionX:Number = center.x + traceAnnotationRadius * Math.sin(deletionAngle1);
						var deletionY:Number = center.y - traceAnnotationRadius * Math.cos(deletionAngle1);
						
						g.drawCircle(deletionX, deletionY, 1);
					} else {
						g.lineStyle(4, MISMATCH_COLOR);
						
						g.moveTo(center.x + traceAnnotationRadius * Math.sin(deletionAngle1), center.y - traceAnnotationRadius * Math.cos(deletionAngle1));
						GraphicUtils.drawArc(g, center, traceAnnotationRadius, deletionAngle1, deletionAngle2);
					}
				}
			}
			
			// render insertions
			if(insertions != null && insertions.length > 0) {
				for(var i4:int = 0; i4 < insertions.length; i4++) {
					var insertionSegment:Segment = insertions[i4] as Segment;
					
					var insertionAngle1:Number = insertionSegment.start * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
					var insertionAngle2:Number = (insertionSegment.end + 1) * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
					
					if(insertionSegment.start == insertionSegment.end) {
						g.lineStyle(2, MISMATCH_COLOR);
						
						var insertionX:Number = center.x + traceAnnotationRadius * Math.sin(insertionAngle1);
						var insertionY:Number = center.y - traceAnnotationRadius * Math.cos(insertionAngle1);
						
						g.drawCircle(insertionX, insertionY, 1);
					} else {
						g.lineStyle(4, MISMATCH_COLOR);
						
						g.moveTo(center.x + traceAnnotationRadius * Math.sin(insertionAngle1), center.y - traceAnnotationRadius * Math.cos(insertionAngle1));
						GraphicUtils.drawArc(g, center, traceAnnotationRadius, insertionAngle1, insertionAngle2);
					}
				}
			}
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = traceAnnotation.traceSequence.filename + ", " + (traceAnnotation.start + 1) + ".." + (traceAnnotation.end + 1);
    	}
	}
}
