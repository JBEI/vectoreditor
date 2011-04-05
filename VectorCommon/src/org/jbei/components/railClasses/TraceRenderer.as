package org.jbei.components.railClasses
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.sequence.common.Annotation;
	import org.jbei.components.common.AnnotationRenderer;
	import org.jbei.lib.data.TraceAnnotation;

    /**
     * @author Zinovii Dmytriv
     */
	public class TraceRenderer extends AnnotationRenderer
	{
		public static const RAIL_GAP:Number = 10;
		public static const DEFAULT_GAP:int = 7;
		private const MATCH_COLOR:int = 0x31B440;
		private const MISMATCH_COLOR:int = 0xFF0000;
		
		private var alignmentRowIndex:int;
		private var bpWidth:Number;
		private var railMetrics:Rectangle;
		
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
			var g:Graphics = graphics;
			g.clear();
			
			var startPosition:Number = railMetrics.x + bpWidth * traceAnnotation.start;
			var endPosition:Number = railMetrics.x + bpWidth * traceAnnotation.end;
			
			var yPosition:Number = railMetrics.y - RAIL_GAP - alignmentRowIndex * DEFAULT_GAP;
			
			var matches:ArrayCollection = traceAnnotation.matches;
			var mismatches:ArrayCollection = traceAnnotation.mismatches;
			var deletions:ArrayCollection = traceAnnotation.deletions;
			var insertions:ArrayCollection = traceAnnotation.insertions;
			
			if(matches == null && matches.length == 0) {
				return;
			}
			
			// render matches
			g.lineStyle(2, MATCH_COLOR);
			
            var matchStartPosition:Number = railMetrics.x + bpWidth * traceAnnotation.traceSequence.traceSequenceAlignment.queryStart;
            var matchEndPosition:Number = railMetrics.x + bpWidth * traceAnnotation.traceSequence.traceSequenceAlignment.queryEnd;
            
            if(traceAnnotation.start > traceAnnotation.end) { // circular
                g.moveTo(railMetrics.x, yPosition);
                g.lineTo(matchEndPosition, yPosition);
                
                g.moveTo(matchStartPosition, yPosition);
                g.lineTo(railMetrics.x + bpWidth * contentHolder.sequenceProvider.sequence.length, yPosition);
            } else { // linear
                g.moveTo(matchStartPosition, yPosition);
                g.lineTo(matchEndPosition, yPosition);
            }
			
			// render mismatches
			if(mismatches != null && mismatches.length > 0) {
				for(var i2:int = 0; i2 < mismatches.length; i2++) {
					var mismatchAnnotation:Annotation = mismatches[i2] as Annotation;
					
					var mismatchStartPosition:Number = railMetrics.x + bpWidth * mismatchAnnotation.start;
					var mismatchEndPosition:Number = railMetrics.x + bpWidth * mismatchAnnotation.end;
					
					if(mismatchAnnotation.start == mismatchAnnotation.end) {
						g.lineStyle(2, MISMATCH_COLOR);
						
						g.drawCircle(mismatchStartPosition, yPosition, 1);
					} else {
						g.lineStyle(4, MISMATCH_COLOR);
						
						g.moveTo(mismatchStartPosition, yPosition);
						g.lineTo(mismatchEndPosition, yPosition);
					}
				}
			}
			
			// render deletions
			if(deletions != null && deletions.length > 0) {
				for(var i3:int = 0; i3 < deletions.length; i3++) {
					var deletionAnnotation:Annotation = deletions[i3] as Annotation;
					
					var deletionStartPosition:Number = railMetrics.x + bpWidth * deletionAnnotation.start;
					var deletionEndPosition:Number = railMetrics.x + bpWidth * deletionAnnotation.end;
					
					if(deletionAnnotation.start == deletionAnnotation.end) {
						g.lineStyle(2, MISMATCH_COLOR);
						
						g.drawCircle(deletionStartPosition, yPosition, 1);
					} else {
						g.lineStyle(4, MISMATCH_COLOR);
						
						g.moveTo(deletionStartPosition, yPosition);
						g.lineTo(deletionEndPosition, yPosition);
					}
				}
			}
			
			// render insertions
			if(insertions != null && insertions.length > 0) {
				for(var i4:int = 0; i4 < insertions.length; i4++) {
					var insertionAnnotation:Annotation = insertions[i4] as Annotation;
					
					var insertionStartPosition:Number = railMetrics.x + bpWidth * insertionAnnotation.start;
					var insertionEndPosition:Number = railMetrics.x + bpWidth * insertionAnnotation.end;
					
					if(insertionAnnotation.start == insertionAnnotation.end) {
						g.lineStyle(2, MISMATCH_COLOR);
						
						g.drawCircle(insertionStartPosition, yPosition, 1);
					} else {
						g.lineStyle(4, MISMATCH_COLOR);
						
						g.moveTo(insertionStartPosition, yPosition);
						g.lineTo(insertionEndPosition, yPosition);
					}
				}
			}
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = traceAnnotation.traceSequence.filename + ", " + (traceAnnotation.start + 1) + ".." + (traceAnnotation.end);
    	}
	}
}
