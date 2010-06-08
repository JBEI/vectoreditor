package org.jbei.components.pieClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import org.jbei.bio.sequence.common.Annotation;
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
				var segment:Annotation = contentHolder.highlights[i] as Annotation;
				
				if(!contentHolder.isValidIndex(segment.start) || !contentHolder.isValidIndex(segment.end)) { return; }
				
				drawSelectionPie(segment.start, segment.end);
			}
		}
		
		private function drawSelectionPie(fromIndex:int, endIndex:int):void
		{
			var angle1:Number = fromIndex * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			var angle2:Number = endIndex * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			
			var radius:Number = contentHolder.railRadius + 10;
			
			var startPoint:Point = new Point(contentHolder.center.x + radius*Math.sin(angle1), contentHolder.center.y - radius*Math.cos(angle1));
			var endPoint:Point = new Point(contentHolder.center.x + radius*Math.sin(angle2), contentHolder.center.y - radius*Math.cos(angle2));
			
			// draw selection with frame
			var g:Graphics = graphics;
			g.beginFill(HIGHLIGHT_COLOR, HIGHLIGHT_TRANSPARENCY);
			g.moveTo(contentHolder.center.x, contentHolder.center.y);
			g.lineTo(startPoint.x, startPoint.y);
			GraphicUtils.drawArc(g, contentHolder.center, radius - 1, angle1, angle2);
			g.lineTo(contentHolder.center.x, contentHolder.center.y);
			g.endFill();
		}
	}
}
