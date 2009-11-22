package org.jbei.components.sequenceClasses
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import org.jbei.bio.data.ORF;

	public class ORFRenderer extends AnnotationRenderer
	{
		private static const DEFAULT_ORF_HEIGHT:int = 6;
		
		private static const ORF_FRAME_COLOR1:int = 0xFF0000;
		private static const ORF_FRAME_COLOR2:int = 0x31B440;
		private static const ORF_FRAME_COLOR3:int = 0x3366CC;
		
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
		
		// Protected Methods
		protected override function render():void
		{
			super.render();
			
			if(!contentHolder.isValidIndex(orf.start) || !contentHolder.isValidIndex(orf.end)) {
				throw new Error("Feature can't be rendered. Invalid positions: [" + String(orf.start) + ", " + String(orf.end) + "]");
			}
			
			var g:Graphics = graphics;
			g.clear();
			
			var orfRows:Array = contentHolder.rowMapper.orfToRowMap[orf];
			
			if(! orfRows) { return; }
			
			for(var i:int = 0; i < orfRows.length; i++) {
				var row:Row = contentHolder.rowMapper.rows[orfRows[i]] as Row;
				
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
				
				var startBP:int = (orf.start < row.rowData.start) ? row.rowData.start : orf.start;
				var endBP:int = (orf.end < row.rowData.end) ? orf.end : row.rowData.end;
				
				var bpStartPoint:Rectangle = contentHolder.bpMetricsByIndex(startBP);
				var bpEndPoint:Rectangle = contentHolder.bpMetricsByIndex(endBP);
				
				var upShift:Number = 2 + alignmentRowIndex * 6;
				
				var orfX:Number = bpStartPoint.x + 2;
				var orfY:Number = bpStartPoint.y - upShift;
				
				var currentWidth:Number = bpEndPoint.x - bpStartPoint.x + contentHolder.sequenceSymbolRenderer.textWidth - 2;
				var currentHeight:Number = 6;
				
				var color:int = ORF_FRAME_COLOR1;
				if(orf.frame() == 0) {
					color = ORF_FRAME_COLOR1;
				} else if(orf.frame() == 1) {
					color = ORF_FRAME_COLOR2;
				} else if(orf.frame() == 2) {
					color = ORF_FRAME_COLOR3;
				}
				
				g.lineStyle(2, color);
				g.moveTo(orfX, orfY);
				g.lineTo(orfX + currentWidth, orfY);
				
				for(var z:int = 0; z < orf.startCodons.length; z++) {
					var startCodonIndex:int = orf.startCodons[z];
					
					if((startCodonIndex >= row.rowData.start) && (startCodonIndex <= row.rowData.end)) {
						var codonStartMetrics:Rectangle = contentHolder.bpMetricsByIndex(startCodonIndex);
						
						var codonStartPointX:Number = codonStartMetrics.x;
						var codonStartPointY:Number = codonStartMetrics.y - upShift;
						g.beginFill(color);
						
						if(! orf.isComplement) {
							g.drawCircle(codonStartPointX + 4, codonStartPointY, 2);
						} else {
							g.drawCircle(codonStartPointX + contentHolder.sequenceSymbolRenderer.textWidth - 2, codonStartPointY, 2);
						}
						g.endFill(); 
					}
				}
				
				if(! orf.isComplement && endBP == orf.end) {
					var codonEndPoint1:Rectangle = contentHolder.bpMetricsByIndex(endBP);
					var codonEndPointX1:Number = codonEndPoint1.x + contentHolder.sequenceSymbolRenderer.textWidth;
					var codonEndPointY1:Number = codonEndPoint1.y - upShift;
					
					g.beginFill(color);
					g.moveTo(codonEndPointX1 - 5, codonEndPointY1 - 2);
					g.lineTo(codonEndPointX1, codonEndPointY1);
					g.lineTo(codonEndPointX1 - 5, codonEndPointY1 + 2);
					g.lineTo(codonEndPointX1 - 5, codonEndPointY1 - 2);
					g.endFill();
				} else if(orf.isComplement && startBP == orf.start) {
					var codonEndPoint2:Rectangle = contentHolder.bpMetricsByIndex(startBP);
					var codonEndPointX2:Number = codonEndPoint2.x;
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
			tooltipLabel = orf.start + ".." + orf.end + ", frame: " + orf.frame() + ", length: " + (Math.abs(orf.end - orf.start) + 1 + 1) + " BP, " + (int((Math.abs(orf.end - orf.start) + 1) / 3) + 1) + " AA" + (orf.isComplement ? ", complimentary" : "");
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
