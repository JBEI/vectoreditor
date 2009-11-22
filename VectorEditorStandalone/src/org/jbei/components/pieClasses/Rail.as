package org.jbei.components.pieClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	public class Rail extends UIComponent
	{
		private const FRAME_COLOR:int = 0x000000;
		private const COLOR:int = 0xFFFF00;
		private const TRANSPARENCY:Number = 0.3;
		
		private var contentHolder:ContentHolder;
		
		private var needsMeasurement:Boolean = false;
		private var radius:Number;
		private var center:Point;
		private var thickness:Number;
		
		// Contructor
		public function Rail(contentHolder:ContentHolder)
		{
			super();
			
			this.contentHolder = contentHolder;
		}
		
		// Public Methods
		public function updateMetrics(radius:Number, center:Point, thickness:Number):void
		{
			this.radius = radius;
			this.center = center;
			this.thickness = thickness;
			
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
			g.drawCircle(center.x, center.y, radius);
			g.drawCircle(center.x, center.y, radius - thickness);
			g.endFill();
		}
	}
}
