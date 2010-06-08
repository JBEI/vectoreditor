package org.jbei.components.railClasses
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import org.jbei.bio.orf.ORF;
	import org.jbei.components.common.AnnotationRenderer;

	public class ORFRenderer extends AnnotationRenderer
	{
		public static const RAIL_GAP:Number = 10;
		public static const DEFAULT_GAP:int = 7;
		private const ORF_FRAME_COLOR1:int = 0xFF0000;
		private const ORF_FRAME_COLOR2:int = 0x31B440;
		private const ORF_FRAME_COLOR3:int = 0x3366CC;
		
		private var alignmentRowIndex:int;
		private var bpWidth:Number;
		private var railMetrics:Rectangle;
		
		// Contructor
		public function ORFRenderer(contentHolder:ContentHolder, orf:ORF)
		{
			super(contentHolder, orf);
		}
		
		// Properties
		public function get orf():ORF
		{
			return annotation as ORF;
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
			var color:int = colorByFrame();
			
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(2, color);
			
			var startPosition:Number = railMetrics.x + bpWidth * orf.start;
			var endPosition:Number = railMetrics.x + bpWidth * orf.end;
			
			var yPosition:Number = railMetrics.y - RAIL_GAP - alignmentRowIndex * DEFAULT_GAP;
			
			if(orf.start > orf.end) { // circular
				g.moveTo(railMetrics.x, yPosition);
				g.lineTo(endPosition, yPosition);
				
				g.moveTo(startPosition, yPosition);
				g.lineTo(railMetrics.x + bpWidth * contentHolder.featuredSequence.sequence.length, yPosition);
			} else { // linear
				g.moveTo(startPosition, yPosition);
				g.lineTo(endPosition, yPosition);
			}
			
			// render start codons as bold dots
			for(var i:int = 0; i < orf.startCodons.length; i++) {
				g.drawCircle(railMetrics.x + bpWidth * orf.startCodons[i], yPosition, 2);
			}
			
			// render end codons as arrows
			if(orf.strand == 1) {
				g.beginFill(color);
				g.moveTo(endPosition - 5, yPosition - 2);
				g.lineTo(endPosition, yPosition);
				g.lineTo(endPosition - 5, yPosition + 2);
				g.lineTo(endPosition - 5, yPosition - 2);
				g.endFill();
			} else if(orf.strand) {
				g.beginFill(color);
				g.moveTo(startPosition, yPosition);
				g.lineTo(startPosition + 5, yPosition - 2);
				g.lineTo(startPosition + 5, yPosition + 2);
				g.lineTo(startPosition, yPosition);
				g.endFill();
			}
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = orf.start + ".." + orf.end + ", frame: " + orf.frame + ", length: " + (Math.abs(orf.end - orf.start) + 1) + " BP, " + int((Math.abs(orf.end - orf.start) + 1) / 3) + " AA" + (orf.strand == 1 ? ", complimentary" : "");
			if(orf.startCodons.length > 1) {
				tooltipLabel += "\n";
				for(var i:int = 0; i < orf.startCodons.length; i++) {
					tooltipLabel += orf.startCodons[i];
					
					if(i != orf.startCodons.length - 1) {
						tooltipLabel += ", ";
					}
				}
			}
    	}
		
		// Private Methods
		private function colorByFrame():int
		{
			var color:int = ORF_FRAME_COLOR1;
			
			if(orf.frame == 0) {
				color = ORF_FRAME_COLOR1;
			} else if(orf.frame == 1) {
				color = ORF_FRAME_COLOR2;
			} else if(orf.frame == 2) {
				color = ORF_FRAME_COLOR3;
			}
			
			return color;
		}
	}
}
