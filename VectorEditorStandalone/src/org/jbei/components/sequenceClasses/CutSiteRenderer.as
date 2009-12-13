package org.jbei.components.sequenceClasses
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.jbei.bio.data.CutSite;
	import org.jbei.components.common.AnnotationRenderer;
	import org.jbei.components.common.IContentHolder;

	public class CutSiteRenderer extends AnnotationRenderer
	{
		private const CURVY_LINE_COLOR:int = 0xFF0000;
		
		private var sequenceContentHolder:ContentHolder;
		
		// Constructor
		public function CutSiteRenderer(contentHolder:IContentHolder, cutSite:CutSite)
		{
			super(contentHolder, cutSite);
			
			sequenceContentHolder = contentHolder as ContentHolder;
		}
		
		// Properties
		public function get cutSite():CutSite
		{
			return annotation as CutSite;
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
			
			var cutSiteHeight:int = sequenceContentHolder.cutSiteTextRenderer.textHeight - 2 + 3; // -2 to remove extra space from textrenderer, +3 to add curvy line
			
			var cutSiteRows:Array = sequenceContentHolder.rowMapper.cutSiteToRowMap[cutSite];
			
			if(! cutSiteRows) { return; }
			
			for(var i:int = 0; i < cutSiteRows.length; i++) {
				var row:Row = sequenceContentHolder.rowMapper.rows[cutSiteRows[i]] as Row;
				
				var alignmentRowIndex:int = -1;
				
				for(var r:int = 0; r < row.rowData.cutSitesAlignment.length; r++) {
					var rowCutSites:Array = row.rowData.cutSitesAlignment[r] as Array;
					
					for(var c:int = 0; c < rowCutSites.length; c++) {
						if((rowCutSites[c] as CutSite) == cutSite) {
							alignmentRowIndex = row.rowData.cutSitesAlignment.length - r - 1;
							break;
						}
					}
					
					if(alignmentRowIndex != -1) { break; }
				}
				
				var startBP:int = 0;
				var endBP:int = 0;
				
				if(cutSite.start <= cutSite.end) { // non-circular
					startBP = (cutSite.start < row.rowData.start) ? row.rowData.start : cutSite.start;
					endBP = (cutSite.end < row.rowData.end) ? cutSite.end : row.rowData.end;
				} else { // circular
					/* |--------------------------------------------------------------------------------------|
					*  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                             */
					if(cutSite.end >= row.rowData.start && cutSite.end <= row.rowData.end) {
						endBP = cutSite.end;
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
					if(cutSite.start >= row.rowData.start && cutSite.start <= row.rowData.end) {
						startBP = cutSite.start;
					}
					/* |--------------------------------------------------------------------------------------|
					*   FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
					else {
						startBP = row.rowData.start;
					}
				}
				
				var bpStartMetrics:Rectangle = sequenceContentHolder.bpMetricsByIndex(startBP);
				var bpEndMetrics:Rectangle = sequenceContentHolder.bpMetricsByIndex(endBP);
				
				var cutSiteX:Number = bpStartMetrics.x;
				var cutSiteY:Number = row.metrics.y +  alignmentRowIndex * cutSiteHeight;
				
				var currentWidth:Number = bpEndMetrics.x - bpStartMetrics.x + sequenceContentHolder.sequenceSymbolRenderer.textWidth;
				var currentHeight:Number = cutSiteHeight;
				
				var cutSiteBitMap:BitmapData = (cutSite.numCuts == 1) ? sequenceContentHolder.singleCutterCutSiteTextRenderer.textToBitmap(cutSite.label) : sequenceContentHolder.cutSiteTextRenderer.textToBitmap(cutSite.label);
				
				var matrix:Matrix = new Matrix();
				matrix.tx += cutSiteX;
				matrix.ty += cutSiteY;
				
				g.beginBitmapFill(cutSiteBitMap, matrix);
				g.drawRect(cutSiteX, cutSiteY, cutSiteBitMap.width, cutSiteBitMap.height);
				g.endFill();
				
				g.beginBitmapFill(curvyLineBitmapData, matrix, true);
				g.drawRect(cutSiteX + 2, cutSiteY + cutSiteBitMap.height - 2, currentWidth - 2, 3); // height -2 to remove extra space from textrenderer, total height +3 to add curvy line
				g.endFill();
			}
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = cutSite.label + ": " + (cutSite.start + 1) + ".." + (cutSite.end + 1) + (cutSite.forward ? "" : ", complement") + ", cuts " + cutSite.numCuts + " times";
		}
	}
}
