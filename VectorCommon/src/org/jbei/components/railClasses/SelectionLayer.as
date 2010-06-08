package org.jbei.components.railClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class SelectionLayer extends UIComponent
	{
		private const SELECTION_COLOR:int = 0x0099FF;
		private const SELECTION_TRANSPARENCY:Number = 0.3;
		private const SELECTION_FRAME_COLOR:Number = 0xCCCCCC;
		
		private var contentHolder:ContentHolder;
		
		private var _start:int = -1;
		private var _end:int = -1;
		private var _selecting:Boolean = false;
		private var _selected:Boolean = false;
		private var startPoint:Point = new Point();
		private var endPoint:Point = new Point();
		
		// Contructor
		public function SelectionLayer(contentHolder:ContentHolder)
		{
			super();
			
			this.contentHolder = contentHolder;
		}
		
		// Properties
		public function get start():int
		{
			return _start;
		}
		
		public function get end():int
		{
			return _end;
		}
		
		public function get selecting():Boolean
		{
			return _selecting;
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		// Public Methods
		public function updateMetrics():void
		{
			// Update selection when display settings changes
			if(selected) {
				select(_start, _end);
			}
		}
		
		public function select(fromIndex:int, toIndex:int):void
		{
			drawSelection(fromIndex, toIndex);
			
			_selected = true;
			_start = fromIndex;
			_end = toIndex;
		}
		
		public function deselect():void
		{
			_start = -1;
			_end = -1;
			_selected = false;
			_selecting = false;
			
			graphics.clear();
		}
		
		public function startSelecting():void
		{
			_selecting = true;
		}
		
		public function endSelecting():void
		{
			_selecting = false;
		}
		
		// Private Methods
		private function drawSelection(fromIndex:int, endIndex:int):void
		{
			if(contentHolder.sequenceProvider.sequence.length == 0 || (_start == fromIndex && _end == endIndex) || fromIndex == endIndex) { return; }
			
			var fromPointX:Number = contentHolder.railMetrics.x + contentHolder.bpWidth * fromIndex;
			var toPointX:Number = contentHolder.railMetrics.x + contentHolder.bpWidth * endIndex;
			
			// draw selection with frame
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, SELECTION_FRAME_COLOR, 0.8);
			if(fromIndex <= endIndex) {
				g.beginFill(SELECTION_COLOR, SELECTION_TRANSPARENCY);
				g.drawRect(fromPointX, contentHolder.railMetrics.y - RailBox.THICKNESS, toPointX - fromPointX, 3 * RailBox.THICKNESS);
				g.endFill();
			} else {
				var startPointX:Number = contentHolder.railMetrics.x;
				var endPointX:Number = contentHolder.railMetrics.x + contentHolder.bpWidth * contentHolder.sequenceProvider.sequence.length;
				
				g.beginFill(SELECTION_COLOR, SELECTION_TRANSPARENCY);
				g.drawRect(fromPointX, contentHolder.railMetrics.y - RailBox.THICKNESS, endPointX - fromPointX, 3 * RailBox.THICKNESS);
				g.endFill();
				
				g.beginFill(SELECTION_COLOR, SELECTION_TRANSPARENCY);
				g.drawRect(startPointX, contentHolder.railMetrics.y - RailBox.THICKNESS, toPointX - startPointX, 3 * RailBox.THICKNESS);
				g.endFill();
			}
		}
	}
}
