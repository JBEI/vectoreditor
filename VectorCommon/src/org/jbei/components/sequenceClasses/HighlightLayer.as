package org.jbei.components.sequenceClasses
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import org.jbei.bio.sequence.common.Annotation;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class HighlightLayer extends UIComponent
	{
		private const HIGHLIGHT_COLOR:int = 0x00FF00;
		private const HIGHLIGHT_TRANSPARENCY:Number = 0.3;
		
		private var contentHolder:ContentHolder;
		
		private var needsMeasurement:Boolean = true;
		
		// Constructor
		public function HighlightLayer(contentHolder:ContentHolder)
		{
			super();
			
			this.contentHolder = contentHolder;
		}
		
		// Public Methods
		public function update():void
		{
			needsMeasurement = true;
			invalidateDisplayList();
		}
		
		// Protected Methods
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(needsMeasurement) {
				needsMeasurement = false;
				
				render();
			}
		}
		
		// Private Methods
		private function render():void
		{
			graphics.clear();
			
			if(!contentHolder.highlights || contentHolder.highlights.length == 0) { return;	} 
			
			for(var i:int = 0; i < contentHolder.highlights.length; i++) {
				var annotation:Annotation = contentHolder.highlights[i] as Annotation;
				
				if(!contentHolder.isValidIndex(annotation.start) || !contentHolder.isValidIndex(annotation.end)) { return; }
				
				if(annotation.start > annotation.end) {
					drawSelection(0, annotation.end);
					drawSelection(annotation.start, contentHolder.sequenceProvider.sequence.length);
				} else {
					drawSelection(annotation.start, annotation.end);
				}
			}
		}
		
		private function drawSelection(fromIndex:int, toIndex:int):void
		{
			var startRow:Row = contentHolder.rowByBpIndex(fromIndex);
			var endRow:Row = contentHolder.rowByBpIndex(toIndex - 1);
			
			if(startRow.index == endRow.index) {  // the same row
				drawRowSelectionRect(fromIndex, toIndex);
			} else if(startRow.index + 1 <= endRow.index) {  // more then one row
				drawRowSelectionRect(fromIndex, startRow.rowData.end);
				
				for(var i:int = startRow.index + 1; i < endRow.index; i++) {
					var rowData:RowData = (contentHolder.rowMapper.rows[i] as Row).rowData;
					
					drawRowSelectionRect(rowData.start, rowData.end);
				}
				
				drawRowSelectionRect(endRow.rowData.start, toIndex);
			}
		}
		
		private function drawRowSelectionRect(start:int, end:int):void
		{
			var row:Row = contentHolder.rowByBpIndex(start);
			
			var startBpMetrics:Rectangle = contentHolder.bpMetricsByIndex(start);
			var endBpMetrics:Rectangle = contentHolder.bpMetricsByIndex(end - 1);
			
			var g:Graphics = graphics;
			g.beginFill(HIGHLIGHT_COLOR, HIGHLIGHT_TRANSPARENCY);
			g.drawRect(startBpMetrics.x + 2, startBpMetrics.y + 2, endBpMetrics.x - startBpMetrics.x + endBpMetrics.width, row.sequenceMetrics.height);
			g.endFill();
		}
	}
}
