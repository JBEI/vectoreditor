package org.jbei.components.sequenceClasses
{
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	public class Caret extends UIComponent
	{
		private const CARET_COLOR:int = 0x000000;
		private const CARET_WIDTH:int = 1;
		
		private var contentHolder:ContentHolder;
		
		private var _caretHeight:int = 20;
		private var _position:int;
		
		private var needsRemeasurement:Boolean = false;
		
		// Constructor
		public function Caret(contentHolder:ContentHolder)
		{
			super();
			
			this.contentHolder = contentHolder;
		}
		
		// Properties
		public function get position():int
		{
			return _position;
		}
		
		public function set position(value:int):void
		{
			_position = value;
			
			needsRemeasurement = true;
			
			invalidateDisplayList();
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
		
		public function get caretHeight():int
		{
			return _caretHeight;
		}
		
		public function set caretHeight(value:int):void
		{
			if(_caretHeight != value) {
				_caretHeight = value;
				
				needsRemeasurement = true;
				
				invalidateDisplayList();
			}
		}
		
		// Protected Methods
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(! contentHolder.featuredSequence) { return; }
			
			if(needsRemeasurement) {
				needsRemeasurement = false;
				
				render();
			}
		}
		
		// Private Methods
		private function render():void
		{
			var caretMetrics:Rectangle = contentHolder.bpMetricsByIndex(_position);
			
			this.x = caretMetrics.x;
			this.y = caretMetrics.y + 2; // +2 to look pretty
			
			measuredWidth = CARET_WIDTH;
			measuredHeight = _caretHeight;
			
			graphics.clear();
			graphics.lineStyle(1, CARET_COLOR);
			graphics.moveTo(0, 0);
			graphics.lineTo(0, measuredHeight);
		}
	}
}
