package org.jbei.components.railClasses
{
	import flash.display.Graphics;
	
	import mx.core.UIComponent;

	public class Caret extends UIComponent
	{
		private const CARET_COLOR:int = 0x000000;
		private const CARET_WIDTH:int = 1;
		
		private var _position:int = -1;
		
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
		
		public function updateMetrics():void
		{
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
			
			if(contentHolder.featuredSequence.sequence.length == 0 || !contentHolder.isValidIndex(_position)) { return; }
			
			var bpWidth:Number = (contentHolder.endRailPoint.x - contentHolder.startRailPoint.x) / contentHolder.featuredSequence.sequence.length;
			
			var xPosition:Number = contentHolder.startRailPoint.x + bpWidth * _position;
			var yPosition:Number = contentHolder.startRailPoint.y - RailBox.THICKNESS;
			
			g.lineStyle(1, CARET_COLOR);
			g.moveTo(xPosition, yPosition);
			g.lineTo(xPosition, yPosition + 3 * RailBox.THICKNESS);
		}
	}
}
