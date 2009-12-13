package org.jbei.components.railClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import org.jbei.bio.data.Segment;
	import org.jbei.components.common.GraphicUtils;
	
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
				var segment:Segment = contentHolder.highlights[i] as Segment;
				
				if(!contentHolder.isValidIndex(segment.start) || !contentHolder.isValidIndex(segment.end)) { return; }
				
				drawSelection(segment.start, segment.end);
			}
		}
		
		private function drawSelection(fromIndex:int, endIndex:int):void
		{
			var fromPointX:Number = contentHolder.railMetrics.x + contentHolder.bpWidth * fromIndex;
			var toPointX:Number = contentHolder.railMetrics.x + contentHolder.bpWidth * endIndex;
			
			// draw selection with frame
			var g:Graphics = graphics;
			g.clear();
			if(fromIndex <= endIndex) {
				g.beginFill(HIGHLIGHT_COLOR, HIGHLIGHT_TRANSPARENCY);
				g.drawRect(fromPointX, contentHolder.railMetrics.y - RailBox.THICKNESS, toPointX - fromPointX, 3 * RailBox.THICKNESS);
				g.endFill();
			} else {
				var startPointX:Number = contentHolder.railMetrics.x;
				var endPointX:Number = contentHolder.railMetrics.x + contentHolder.bpWidth * contentHolder.featuredSequence.sequence.length;
				
				g.beginFill(HIGHLIGHT_COLOR, HIGHLIGHT_TRANSPARENCY);
				g.drawRect(fromPointX, contentHolder.railMetrics.y - RailBox.THICKNESS, endPointX - fromPointX, 3 * RailBox.THICKNESS);
				g.endFill();
				
				g.beginFill(HIGHLIGHT_COLOR, HIGHLIGHT_TRANSPARENCY);
				g.drawRect(startPointX, contentHolder.railMetrics.y - RailBox.THICKNESS, toPointX - startPointX, 3 * RailBox.THICKNESS);
				g.endFill();
			}
		}
	}
}
