package org.jbei.components.sequenceClasses
{
	import mx.core.UIComponent;

	public class Caret extends UIComponent
	{
		private const CARET_COLOR:int = 0x000000;
		private const CARET_WIDTH:int = 1;
		
		private var _caretHeight:int = 20;
		
		private var needsRemeasurement:Boolean = false;
		
		// Constructor
		public function Caret()
		{
			super();
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
				
				invalidateDisplayList()
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
			measuredWidth = CARET_WIDTH;
			measuredHeight = _caretHeight;
			
			graphics.clear();
			graphics.lineStyle(1, CARET_COLOR);
			graphics.moveTo(0, 0);
			graphics.lineTo(0, measuredHeight);
		}
	}
}
