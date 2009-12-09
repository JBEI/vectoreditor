package org.jbei.components.pieClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	public class RailBox extends UIComponent
	{
		private const FRAME_COLOR:int = 0x000000;
		private const COLOR:int = 0xFFFF00;
		private const TRANSPARENCY:Number = 0.3;
		private const THICKNESS:Number = 5;
		
		private var contentHolder:ContentHolder;
		
		private var needsMeasurement:Boolean = false;
		
		// Contructor
		public function RailBox(contentHolder:ContentHolder)
		{
			super();
			
			this.contentHolder = contentHolder;
		}
		
		// Public Methods
		public function updateMetrics():void
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
				
				drawRail();
			}
		}
		
		// Private Methods
		private function drawRail():void
		{
			var g:Graphics = graphics;
			
			g.clear();
			g.lineStyle(1, FRAME_COLOR, TRANSPARENCY);
			g.beginFill(COLOR, TRANSPARENCY);
			g.drawCircle(contentHolder.center.x, contentHolder.center.y, contentHolder.railRadius);
			g.drawCircle(contentHolder.center.x, contentHolder.center.y, contentHolder.railRadius - THICKNESS);
			g.endFill();
		}
	}
}
