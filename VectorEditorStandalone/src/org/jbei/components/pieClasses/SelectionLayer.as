package org.jbei.components.pieClasses
{
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import org.jbei.components.common.GraphicUtils;
	
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
		private var previousStart:int = -1;
		private var previousEnd:int = -1;
		private var startPoint:Point = new Point();
		private var endPoint:Point = new Point();
		
		private var radius:Number = 0;
		private var center:Point = new Point(0, 0);
		
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
		public function updateMetrics(radius:Number, center:Point):void
		{
			this.radius = radius;
			this.center = center;
			
			// Update selection when display settings changes
			if(selected) {
				select(_start, _end);
			}
		}
		
		public function select(fromIndex:int, toIndex:int):void
		{
			drawSelectionPie(fromIndex, toIndex);
			
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
			previousStart = -1;
			previousEnd = -1;
			
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
		private function drawSelectionPie(fromIndex:int, endIndex:int):void
		{
			if(contentHolder.featuredSequence.sequence.length == 0 || (_start == fromIndex && _end == endIndex) || fromIndex == endIndex) { return; }
			
			var angle1:Number = fromIndex * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			var angle2:Number = endIndex * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			
			var startPoint:Point = new Point(center.x + radius*Math.sin(angle1), center.y - radius*Math.cos(angle1));
			var endPoint:Point = new Point(center.x + radius*Math.sin(angle2), center.y - radius*Math.cos(angle2));
			
			// draw selection with frame
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, SELECTION_FRAME_COLOR, 0.8);
			g.beginFill(SELECTION_COLOR, SELECTION_TRANSPARENCY);
			g.moveTo(center.x, center.y);
			g.lineTo(startPoint.x, startPoint.y);
			GraphicUtils.drawArc(g, center, radius - 1, angle1, angle2);
			g.lineTo(center.x, center.y);
			g.endFill();
		}
	}
}
