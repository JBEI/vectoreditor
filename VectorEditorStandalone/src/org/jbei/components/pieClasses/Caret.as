package org.jbei.components.pieClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import org.jbei.components.common.GraphicUtils;

	public class Caret extends UIComponent
	{
		private const CARET_COLOR:int = 0x000000;
		private const CARET_WIDTH:int = 1;
		
		private var _position:int = -1;
		
		private var radius:Number;
		private var center:Point;
		private var needsRemeasurement:Boolean = false;
		private var contentHolder:ContentHolder;
		
		// Constructor
		public function Caret(contentHolder:ContentHolder)
		{
			super();
			
			this.contentHolder = contentHolder;
		}
		
		// Public Methods
		public function show():void
		{
			visible = true;
		}
		
		public function hide():void
		{
			visible = false;
		}
		
		public function updateMetrics(center:Point, radius:Number):void
		{
			this.center = center;
			this.radius = radius;
			
			needsRemeasurement = true;
			
			invalidateDisplayList();
		}
		
		public function get position():int
		{
			return _position;
		}
		
		public function set position(value:int):void
		{
			if(_position != value) {
				_position = value;
				
				needsRemeasurement = true;
				invalidateDisplayList();
			}
		}
		
		// Protected Methods
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(needsRemeasurement) {
				needsRemeasurement = false;
				
				render();
			}
		}
		
		// Private Methods
		private function render():void
		{
			var g:Graphics = graphics;
			
			g.clear();
			
			if(_position == -1 || contentHolder.featuredSequence.sequence.length == 0) { return; }
			
			var angle:Number = 2 * _position * Math.PI / contentHolder.featuredSequence.sequence.length;
			
			var point:Point = GraphicUtils.pointOnCircle(center, angle, radius);
			
			g.lineStyle(1, CARET_COLOR);
			g.moveTo(center.x, center.y);
			g.lineTo(point.x, point.y);
		}
	}
}
