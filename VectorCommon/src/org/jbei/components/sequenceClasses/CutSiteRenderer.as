package org.jbei.components.sequenceClasses
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.jbei.bio.enzymes.RestrictionCutSite;
	import org.jbei.components.common.AnnotationRenderer;
	import org.jbei.components.common.IContentHolder;

    /**
     * @author Zinovii Dmytriv
     */
	public class CutSiteRenderer extends AnnotationRenderer
	{
		private const CURVY_LINE_COLOR:int = 0xFF0000;
		
		private var sequenceContentHolder:ContentHolder;
		
		// Constructor
		public function CutSiteRenderer(contentHolder:IContentHolder, cutSite:RestrictionCutSite)
		{
			super(contentHolder, cutSite);
			
			sequenceContentHolder = contentHolder as ContentHolder;
		}
		
		// Properties
		public function get cutSite():RestrictionCutSite
		{
			return annotation as RestrictionCutSite;
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
			
			var curvyLineBitmapData:BitmapData = new BitmapData(4, 3);
			curvyLineBitmapData.setPixel(0, 0, CURVY_LINE_COLOR);
			curvyLineBitmapData.setPixel(1, 1, CURVY_LINE_COLOR);
			curvyLineBitmapData.setPixel(2, 2, CURVY_LINE_COLOR);
			curvyLineBitmapData.setPixel(3, 1, CURVY_LINE_COLOR);
			
			var g:Graphics = graphics;
			g.clear();
			
			var cutSiteHeight:int = sequenceContentHolder.cutSiteTextRenderer.textHeight - 2 + 3; // -2 to remove extra space from textrenderer, +3 to add curvy line, +4 for ds Marker
			
			var cutSiteRows:Array = sequenceContentHolder.rowMapper.cutSiteToRowMap[cutSite];
			
			if(! cutSiteRows) { return; }
			
			for(var i:int = 0; i < cutSiteRows.length; i++) {
				var row:Row = sequenceContentHolder.rowMapper.rows[cutSiteRows[i]] as Row;
				
				var alignmentRowIndex:int = -1;
				
				for(var r:int = 0; r < row.rowData.cutSitesAlignment.length; r++) {
					var rowCutSites:Array = row.rowData.cutSitesAlignment[r] as Array;
					
					for(var c:int = 0; c < rowCutSites.length; c++) {
						if((rowCutSites[c] as RestrictionCutSite) == cutSite) {
							alignmentRowIndex = row.rowData.cutSitesAlignment.length - r - 1;
							break;
						}
					}
					
					if(alignmentRowIndex != -1) { break; }
				}
		
				var startBP:int = 0;
				var endBP:int = 0;

				if(cutSite.start < cutSite.end) { // non-circular
					if (cutSite.start < row.rowData.start && cutSite.end <= row.rowData.start) {
						continue;
					} else if (cutSite.start > row.rowData.end && cutSite.end > row.rowData.end) {
						continue;
					} else {
						startBP = (cutSite.start < row.rowData.start) ? row.rowData.start : cutSite.start;
						endBP = (cutSite.end - 1 < row.rowData.end) ? cutSite.end - 1 : row.rowData.end;
					}
				} else { // circular
   					/* |--------------------------------------------------------------------------------------|
					*  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                             */
					if(cutSite.end >= row.rowData.start && cutSite.end <= row.rowData.end) {
						endBP = cutSite.end - 1;
					}
					else if(row.rowData.end >= contentHolder.sequenceProvider.sequence.length) {
						endBP = contentHolder.sequenceProvider.sequence.length - 1;
					}
					/* |--------------------------------------------------------------------------------------|
					*  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
					else {
						endBP = row.rowData.end;
					}
					
					/* |--------------------------------------------------------------------------------------|
					*                                    |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
					if(cutSite.start >= row.rowData.start && cutSite.start <= row.rowData.end) {
						startBP = cutSite.start;
					}
					/* |--------------------------------------------------------------------------------------|
					*   FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
					else {
						startBP = row.rowData.start;
					}
				}

				var dsForwardPosition:int;
				var dsReversePosition:int;
				if (cutSite.strand == 1) {
					dsForwardPosition = cutSite.start + cutSite.restrictionEnzyme.dsForward;
					dsReversePosition = cutSite.start + cutSite.restrictionEnzyme.dsReverse;
				} else {
					dsForwardPosition = cutSite.end - cutSite.restrictionEnzyme.dsForward;
					dsReversePosition = cutSite.end - cutSite.restrictionEnzyme.dsReverse;
				}
				
				if (dsForwardPosition >= sequenceContentHolder.sequenceProvider.sequence.length) {
					dsForwardPosition -= sequenceContentHolder.sequenceProvider.sequence.length;
				}
				if (dsReversePosition >= sequenceContentHolder.sequenceProvider.sequence.length) {
					dsReversePosition -= sequenceContentHolder.sequenceProvider.sequence.length;
				}
				
				if (dsForwardPosition < 0) {
					dsForwardPosition += sequenceContentHolder.sequenceProvider.sequence.length;
				}
				if (dsReversePosition < 0) {
					dsReversePosition -= sequenceContentHolder.sequenceProvider.sequence.length;
				}
				
				dsForwardPosition = (dsForwardPosition >= row.rowData.start && dsForwardPosition <= row.rowData.end) ? dsForwardPosition : -1;
				dsReversePosition = (dsReversePosition >= row.rowData.start && dsReversePosition <= row.rowData.end) ? dsReversePosition : -1;
				
				var bpStartMetrics:Rectangle = sequenceContentHolder.bpMetricsByIndex(startBP);
				var bpEndMetrics:Rectangle = sequenceContentHolder.bpMetricsByIndex(endBP);
				
				var cutSiteX:Number = bpStartMetrics.x;
				var cutSiteY:Number = row.metrics.y +  alignmentRowIndex * cutSiteHeight;
				
				var currentWidth:Number = bpEndMetrics.x - bpStartMetrics.x + sequenceContentHolder.sequenceSymbolRenderer.textWidth;
				var currentHeight:Number = cutSiteHeight;
				
				var cutSiteBitMap:BitmapData = (cutSite.numCuts == 1) ? sequenceContentHolder.singleCutterCutSiteTextRenderer.textToBitmap(cutSite.restrictionEnzyme.name) : sequenceContentHolder.cutSiteTextRenderer.textToBitmap(cutSite.restrictionEnzyme.name);
				
				var matrix:Matrix = new Matrix();
				matrix.tx += cutSiteX;
				matrix.ty += cutSiteY;

                if (startBP <= endBP) {
    				g.beginBitmapFill(cutSiteBitMap, matrix);
    				g.drawRect(cutSiteX, cutSiteY, cutSiteBitMap.width, cutSiteBitMap.height);
    				g.endFill();
                    drawBitmap(curvyLineBitmapData, matrix, cutSiteX + 2, cutSiteY + cutSiteBitMap.height, currentWidth - 2); // height -2 to remove extra space from textrenderer, total height +3 to add curvy line
                } else if (endBP >= row.rowData.start){
    				g.beginBitmapFill(cutSiteBitMap, matrix);
    				g.drawRect(cutSiteX, cutSiteY, cutSiteBitMap.width, cutSiteBitMap.height);
    				g.endFill();
                    /* Case when start and end are in the same row
				    * |--------------------------------------------------------------------------------------|
				    *  FFFFFFFFFFFFFFFFFFFFFFFFFFF|                     |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                    var bpStartMetrics1:Rectangle =sequenceContentHolder.bpMetricsByIndex(row.rowData.start);
                    var bpEndMetrics1:Rectangle = sequenceContentHolder.bpMetricsByIndex(Math.min(endBP, contentHolder.sequenceProvider.sequence.length - 1));
                    var bpStartMetrics2:Rectangle = sequenceContentHolder.bpMetricsByIndex(startBP);
                    var bpEndMetrics2:Rectangle = sequenceContentHolder.bpMetricsByIndex(Math.min(row.rowData.end, contentHolder.sequenceProvider.sequence.length - 1));
				    var cutSiteX1:Number = bpStartMetrics1.x;
                    var cutSiteY1:Number = row.metrics.y + alignmentRowIndex * cutSiteHeight;
                    
                    var cutSiteX2:Number = bpStartMetrics2.x;
                    var cutSiteY2:Number = cutSiteY1;
                    
                    var currentWidth1:Number = bpEndMetrics1.x - bpStartMetrics1.x + sequenceContentHolder.sequenceSymbolRenderer.textWidth;
                    var currentWidth2:Number = bpEndMetrics2.x - bpStartMetrics2.x + sequenceContentHolder.sequenceSymbolRenderer.textWidth;
                    
                    drawBitmap(curvyLineBitmapData, matrix, cutSiteX1 + 2, cutSiteY1 + cutSiteBitMap.height, currentWidth1 - 2);
                    drawBitmap(curvyLineBitmapData, matrix, cutSiteX2 + 2, cutSiteY2 + cutSiteBitMap.height, currentWidth2 - 2);
               }
                
				if(dsForwardPosition != -1) {
					var dsForwardMetrics:Rectangle = sequenceContentHolder.bpMetricsByIndex(dsForwardPosition);
					
					var ds1X:Number = dsForwardMetrics.x + 2;
					var ds1Y:Number = cutSiteY + cutSiteBitMap.height;
                    drawDsForwardPosition(ds1X, ds1Y);
				} 
				
				if(dsReversePosition != -1) {
					var dsReverseMetrics:Rectangle = sequenceContentHolder.bpMetricsByIndex(dsReversePosition);
					
					var ds2X:Number = dsReverseMetrics.x + 2;
					var ds2Y:Number = cutSiteY + cutSiteBitMap.height + 3;
                   drawDsReversePosition(ds2X, ds2Y);
				} 
			}
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = cutSite.restrictionEnzyme.name + ": " + (cutSite.start + 1) + ".." + (cutSite.end) + (cutSite.strand == 1 ? "" : ", complement") + ", cuts " + cutSite.numCuts + " times";
		}
        
        private function drawDsForwardPosition(x:int, y:int):void {
			graphics.beginFill(0x625D5D);
			graphics.moveTo(x, y);
			graphics.lineTo(x - 3, y - 4);
			graphics.lineTo(x + 3, y - 4);
			graphics.endFill();
        }
        private function drawDsReversePosition(x:int, y:int):void {
            graphics.beginFill(0x625D5D);
            graphics.moveTo(x, y);
            graphics.lineTo(x - 3, y + 4);
            graphics.lineTo(x + 3, y + 4);
            graphics.endFill();
        }
        
        private function drawBitmap(bitmapData:BitmapData, matrix:Matrix, x:int, y:int, width:int):void {
            graphics.beginBitmapFill(bitmapData, matrix, true);
            graphics.drawRect(x, y, width, 3);
            graphics.endFill();
        }
	}
}
