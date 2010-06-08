package org.jbei.components.sequenceClasses
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import org.jbei.bio.orf.ORF;
	import org.jbei.components.common.AnnotationRenderer;
	import org.jbei.components.common.IContentHolder;

	public class ORFRenderer extends AnnotationRenderer
	{
		private static const DEFAULT_ORF_HEIGHT:int = 6;
		
		private static const ORF_FRAME_COLOR1:int = 0xFF0000;
		private static const ORF_FRAME_COLOR2:int = 0x31B440;
		private static const ORF_FRAME_COLOR3:int = 0x3366CC;
		
		private var sequenceContentHolder:ContentHolder;
		
		// Contructor
		public function ORFRenderer(contentHolder:IContentHolder, orf:ORF)
		{
			super(contentHolder, orf);
			
			sequenceContentHolder = contentHolder as ContentHolder;
		}
		
		// Properties
		public function get orf():ORF
		{
			return annotation as ORF;
		}
		
		// Public Methods
		public function update():void
		{
			needsMeasurement = true;
			invalidateDisplayList();
		}
		
		// Protected Methods
		protected override function render():void
		{
			super.render();
			
			var g:Graphics = graphics;
			g.clear();
			
			var orfRows:Array = sequenceContentHolder.rowMapper.orfToRowMap[orf];
			
			if(! orfRows) { return; }
			
			for(var i:int = 0; i < orfRows.length; i++) {
				var row:Row = sequenceContentHolder.rowMapper.rows[orfRows[i]] as Row;
				
				var alignmentRowIndex:int = -1;
				
				for(var r:int = 0; r < row.rowData.orfAlignment.length; r++) {
					var rowOrfs:Array = row.rowData.orfAlignment[r] as Array;
					
					for(var c:int = 0; c < rowOrfs.length; c++) {
						if((rowOrfs[c] as ORF) == orf) {
							alignmentRowIndex = r;
							break;
						}
					}
					
					if(alignmentRowIndex != -1) { break; }
				}
				
				var startBP:int;
				var endBP:int;
				
				if(orf.start > orf.end) { // circular case
					/* |--------------------------------------------------------------------------------------|
					*  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                             */
					if(orf.end >= row.rowData.start && orf.end <= row.rowData.end) {
						endBP = orf.end;
					}
					else if(row.rowData.end >= contentHolder.featuredSequence.sequence.length) {
						endBP = contentHolder.featuredSequence.sequence.length - 1;
					}
					/* |--------------------------------------------------------------------------------------|
					*  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
					else {
						endBP = row.rowData.end;
					} 
					
					/* |--------------------------------------------------------------------------------------|
					*                                    |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
					if(orf.start >= row.rowData.start && orf.start <= row.rowData.end) {
						startBP = orf.start;
					}
					/* |--------------------------------------------------------------------------------------|
					*   FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
					else {
						startBP = row.rowData.start;
					}
				} else {
					startBP = (orf.start < row.rowData.start) ? row.rowData.start : orf.start;
					endBP = (orf.end < row.rowData.end) ? orf.end : row.rowData.end;
				}
				
				var bpStartPoint:Rectangle = sequenceContentHolder.bpMetricsByIndex(startBP);
				var bpEndPoint:Rectangle = sequenceContentHolder.bpMetricsByIndex(endBP);
				
				var upShift:Number = 2 + alignmentRowIndex * 6;
				
				var color:int = ORF_FRAME_COLOR1;
				if(orf.frame == 0) {
					color = ORF_FRAME_COLOR1;
				} else if(orf.frame == 1) {
					color = ORF_FRAME_COLOR2;
				} else if(orf.frame == 2) {
					color = ORF_FRAME_COLOR3;
				}
				
				g.lineStyle(2, color);
				
				var orfY:Number = bpStartPoint.y - upShift;
				var currentHeight:Number = 6;
				
				if(startBP > endBP) { // case when start and end are in the same row
					var rowStartPoint:Rectangle = sequenceContentHolder.bpMetricsByIndex(row.rowData.start);
					var rowEndPoint:Rectangle = sequenceContentHolder.bpMetricsByIndex(row.rowData.end);
					
					g.moveTo(rowStartPoint.x + 2, orfY);
					g.lineTo(bpEndPoint.x + bpEndPoint.width, orfY);
					
					g.moveTo(bpStartPoint.x + 2, orfY);
					g.lineTo(rowEndPoint.x + rowEndPoint.width, orfY);
				} else {
					g.moveTo(bpStartPoint.x + 2, orfY);
					g.lineTo(bpStartPoint.x + bpEndPoint.x - bpStartPoint.x + sequenceContentHolder.sequenceSymbolRenderer.textWidth, orfY);
				}
				
				for(var z:int = 0; z < orf.startCodons.length; z++) {
					var startCodonIndex:int = orf.startCodons[z];
					
					if((startCodonIndex >= row.rowData.start) && (startCodonIndex <= row.rowData.end)) {
						var codonStartMetrics:Rectangle = sequenceContentHolder.bpMetricsByIndex(startCodonIndex);
						
						var codonStartPointX:Number = codonStartMetrics.x;
						var codonStartPointY:Number = codonStartMetrics.y - upShift;
						g.beginFill(color);
						
						if(orf.strand == -1) {
							g.drawCircle(codonStartPointX + 4, codonStartPointY, 2);
						} else {
							g.drawCircle(codonStartPointX + sequenceContentHolder.sequenceSymbolRenderer.textWidth - 2, codonStartPointY, 2);
						}
						g.endFill(); 
					}
				}
				
				if(orf.strand == 1 && endBP == orf.end) {
					var codonEndPoint1:Rectangle = sequenceContentHolder.bpMetricsByIndex(endBP);
					var codonEndPointX1:Number = codonEndPoint1.x + sequenceContentHolder.sequenceSymbolRenderer.textWidth + 3;
					var codonEndPointY1:Number = codonEndPoint1.y - upShift;
					
					g.beginFill(color);
					g.moveTo(codonEndPointX1 - 5, codonEndPointY1 - 2);
					g.lineTo(codonEndPointX1, codonEndPointY1);
					g.lineTo(codonEndPointX1 - 5, codonEndPointY1 + 2);
					g.lineTo(codonEndPointX1 - 5, codonEndPointY1 - 2);
					g.endFill();
				} else if(orf.strand == -1 && startBP == orf.start) {
					var codonEndPoint2:Rectangle = sequenceContentHolder.bpMetricsByIndex(startBP);
					var codonEndPointX2:Number = codonEndPoint2.x + 3;
					var codonEndPointY2:Number = codonEndPoint2.y - upShift;
					
					g.beginFill(color);
					g.moveTo(codonEndPointX2, codonEndPointY2);
					g.lineTo(codonEndPointX2 + 5, codonEndPointY2 - 2);
					g.lineTo(codonEndPointX2 + 5, codonEndPointY2 + 2);
					g.lineTo(codonEndPointX2, codonEndPointY2);
					g.endFill();
				}
			}
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = orf.start + ".." + orf.end + ", frame: " + orf.frame + ", length: " + (Math.abs(orf.end - orf.start) + 1 + 1) + " BP, " + (int((Math.abs(orf.end - orf.start) + 1) / 3) + 1) + " AA" + (orf.strand == -1 ? ", complimentary" : "");
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
	}
}
