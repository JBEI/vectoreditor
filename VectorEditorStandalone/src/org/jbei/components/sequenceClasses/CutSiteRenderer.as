package org.jbei.components.sequenceClasses
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.jbei.bio.data.CutSite;

	public class CutSiteRenderer extends AnnotationRenderer
	{
		private const CURVY_LINE_COLOR:int = 0xFF0000;
		
		private var curvyLineBitmapData:BitmapData;
		
		// Constructor
		public function CutSiteRenderer(contentHolder:ContentHolder, cutSite:CutSite)
		{
			super(contentHolder, cutSite);
			
			createCurvyLine();
		}
		
		// Properties
		public function get cutSite():CutSite
		{
			return annotation as CutSite;
		}
		
		// Protected Methods
		protected override function render():void
		{
			super.render();
			
			if(!contentHolder.isValidIndex(cutSite.start) || !contentHolder.isValidIndex(cutSite.end)) {
				throw new Error("CutSite can't be rendered. Invalid positions: [" + String(cutSite.start) + ", " + String(cutSite.end) + "]");
			}
			
			var g:Graphics = graphics;
			g.clear();
			
			var cutSiteHeight:int = contentHolder.cutSiteTextRenderer.textHeight - 2 + 3; // -2 to remove extra space from textrenderer, +3 to add curvy line
			
			var cutSiteRows:Array = contentHolder.rowMapper.cutSiteToRowMap[cutSite];
			
			if(! cutSiteRows) { return; }
			
			for(var i:int = 0; i < cutSiteRows.length; i++) {
				var row:Row = contentHolder.rowMapper.rows[cutSiteRows[i]] as Row;
				
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
				
				if(cutSite.start < row.rowData.start) {
					startBP = row.rowData.start;
				} else {
					startBP = cutSite.start;
				}
				
				if(cutSite.end < row.rowData.end) {
					endBP = cutSite.end;
				} else {
					endBP = row.rowData.end;
				}
				
				var bpStartMetrics:Rectangle = contentHolder.bpMetricsByIndex(startBP);
				var bpEndMetrics:Rectangle = contentHolder.bpMetricsByIndex(endBP);
				
				var cutSiteX:Number = bpStartMetrics.x;
				var cutSiteY:Number = row.metrics.y +  alignmentRowIndex * cutSiteHeight;
				
				var currentWidth:Number = bpEndMetrics.x - bpStartMetrics.x + contentHolder.sequenceSymbolRenderer.textWidth;
				var currentHeight:Number = cutSiteHeight;
				
				var cutSiteBitMap:BitmapData = (cutSite.numCuts == 1) ? contentHolder.singleCutterCutSiteTextRenderer.textToBitmap(cutSite.label) : contentHolder.cutSiteTextRenderer.textToBitmap(cutSite.label);
				
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
		
		// Private Methods
		private function createCurvyLine():void
		{
			curvyLineBitmapData = new BitmapData(4, 3);
			curvyLineBitmapData.setPixel(0, 0, CURVY_LINE_COLOR);
			curvyLineBitmapData.setPixel(1, 1, CURVY_LINE_COLOR);
			curvyLineBitmapData.setPixel(2, 2, CURVY_LINE_COLOR);
			curvyLineBitmapData.setPixel(3, 1, CURVY_LINE_COLOR);
		}
	}
}
