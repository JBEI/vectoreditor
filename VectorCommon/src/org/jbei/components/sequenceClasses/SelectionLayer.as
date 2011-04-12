package org.jbei.components.sequenceClasses
{
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Endian;
	
	import mx.core.UIComponent;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class SelectionLayer extends UIComponent
	{
		private const SELECTION_COLOR:int = 0x0099FF;
		private const SELECTION_TRANSPARENCY:Number = 0.3;
		
		private var leftHandle:SelectionHandle;
		private var rightHandle:SelectionHandle;
		private var contentHolder:ContentHolder;
		
		private var _start:int = -1;
		private var _end:int = -1;
		private var _selecting:Boolean = false;
		private var _selected:Boolean = false;
		private var previousStart:int = -1;
		private var previousEnd:int = -1;
		private var selectionHeight:Number = 0;
		
		// Contructor
		public function SelectionLayer(contentHolder:ContentHolder)
		{
			super();
			
			this.contentHolder = contentHolder;
			
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
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
			return _selected && _start > -1 && _end > -1;
		}
		
		// Public Methods
		public function updateMetrics(parentWidth:Number, parentHeight:Number):void
		{
			this.measuredWidth = parentWidth;
			this.measuredHeight = parentHeight;
			
			// Update selection when display settings changes
			if(selected) {
				select(_start, _end);
			}
		}
		
		public function select(fromIndex:int, toIndex:int):void
		{
			// if sequence already selected, no point to redraw 
			if(fromIndex == _start && toIndex == _end && _start != -1 && _end != -1) { return; }
			
			// nothing to select
			if(fromIndex == toIndex) { return; }
			
			_selected = false;
			
			var g:Graphics = graphics;
			
			try {
				g.clear();
				
				if(fromIndex > toIndex) {
					drawSelection(0, toIndex);
					drawSelection(fromIndex, contentHolder.sequenceProvider.sequence.length);
				} else {
					drawSelection(fromIndex, toIndex);
				}
				
				_start = fromIndex;
				_end = toIndex;
				
				_selected = true;
			} catch(error:Error) { 
				_selected = false;
				
				g.clear();
				
				trace("Still crashes on selection!");
			} finally {
			}
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
			hideHandles();
		}
		
		public function startSelecting():void
		{
			_selecting = true;
			
			hideHandles();
		}
		
		public function endSelecting():void
		{
			_selecting = false;
		}
		
		// Protected Methods
		protected override function createChildren():void
		{
			super.createChildren();
			
			createHandles();
		}
		
		// Private Methods
	    private function onRollOver(event:MouseEvent):void
	    {
	    	if(!_selecting && selected) {
	    		showHandles();
	    	}
	    }
	    
	    private function onRollOut(event:MouseEvent):void
	    {
	    	if(!_selecting && selected) {
	    		hideHandles();
	    	}
	    }
	    
	    private function onMouseDown(event:MouseEvent):void
	    {
	    	if(event.target is SelectionHandle) {
	    		dispatchEvent(new SelectionLayerEvent(SelectionLayerEvent.SELECTION_HANDLE_CLICKED, (event.target as SelectionHandle).kind));
	    	}
	    	
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
	    	event.stopPropagation();
	    }
	    
	    private function onMouseUp(event:MouseEvent):void
	    {
	    	dispatchEvent(new SelectionLayerEvent(SelectionLayerEvent.SELECTION_HANDLE_RELEASED, ""));
	    	
	    	stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	    	
	    	showHandles();
	    }
	    
	    private function createHandles():void
	    {
	    	if(leftHandle == null) {
		    	leftHandle = new SelectionHandle(SelectionHandle.START_HANDLE);
		    	leftHandle.hide();
		    	addChild(leftHandle);
	    	}
	    	
	    	if(rightHandle == null) {
		    	rightHandle = new SelectionHandle(SelectionHandle.END_HANDLE);
		    	rightHandle.hide();
		    	addChild(rightHandle);
	    	}
	    }
	    
	    private function showHandles():void
	    {
			var leftBpRectangle:Rectangle = contentHolder.bpMetricsByIndex(_start);
			var startRow:Row = contentHolder.rowByBpIndex(_start);
			
			leftHandle.x = leftBpRectangle.x - leftHandle.actualWidth / 2 + 2;
			leftHandle.y = leftBpRectangle.y + startRow.sequenceMetrics.height / 2 - leftHandle.actualHeight / 2 + 2;
			leftHandle.show();
			
			var rightBpRectangle:Rectangle = contentHolder.bpMetricsByIndex(_end - 1);
			var endRow:Row = contentHolder.rowByBpIndex(_end - 1);
			
			rightHandle.x = rightBpRectangle.x + rightBpRectangle.width - rightHandle.actualWidth / 2 + 2;
			rightHandle.y = rightBpRectangle.y + endRow.sequenceMetrics.height / 2 - rightHandle.actualHeight / 2 + 2;
			rightHandle.show();
	    }
	    
	    private function hideHandles():void
	    {
			leftHandle.hide();
			rightHandle.hide();
	    }
	    
	    private function drawSelection(fromIndex:int, toIndex:int):void
	    {
			var startRow:Row = contentHolder.rowByBpIndex(fromIndex);
			var endRow:Row = contentHolder.rowByBpIndex(toIndex - 1);
			
			if(startRow.index == endRow.index) {  // the same row
				drawRowSelectionRect(fromIndex, toIndex);
			} else if(startRow.index + 1 <= endRow.index) {  // more then one row
				drawRowSelectionRect(fromIndex, startRow.rowData.end);
				
				for(var i:int = startRow.index + 1; i < endRow.index; i++) {
					var rowData:RowData = (contentHolder.rowMapper.rows[i] as Row).rowData;
					
					drawRowSelectionRect(rowData.start, rowData.end);
				}
				
				drawRowSelectionRect(endRow.rowData.start, toIndex - 1);
			}
		}
	    
		private function drawRowSelectionRect(startIndex:int, endIndex:int):void
		{
			var row:Row = contentHolder.rowByBpIndex(startIndex);
			
			var startBpMetrics:Rectangle = contentHolder.bpMetricsByIndex(startIndex);
			var endBpMetrics:Rectangle = contentHolder.bpMetricsByIndex(endIndex);
			
			var g:Graphics = graphics;
			g.beginFill(SELECTION_COLOR, SELECTION_TRANSPARENCY);
			g.drawRect(startBpMetrics.x + 2, startBpMetrics.y + 2, endBpMetrics.x - startBpMetrics.x + endBpMetrics.width, row.sequenceMetrics.height);
			g.endFill();
		}
	}
}
