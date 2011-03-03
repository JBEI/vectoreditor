package org.jbei.view.components
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.collections.ArrayCollection;
	import mx.core.EdgeMetrics;
	import mx.core.FlexGlobals;
	import mx.core.ScrollControlBase;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.managers.IFocusManagerComponent;
	
	import org.jbei.events.Direction;
	import org.jbei.events.GridCellEvent;
	import org.jbei.events.GridCellMouseEvent;
	import org.jbei.events.GridEvent;
	import org.jbei.events.GridScrollEvent;
	import org.jbei.events.MoveCellEvent;
	import org.jbei.model.GridPaste;
	
	// wrapper for the grid, adding scrollbars
	// does a few other things that does not belong in this class 
	// but that is a TODO for another release
	public class GridHolder extends ScrollControlBase implements IFocusManagerComponent
	{
		private var _grid:Grid;
		private var _gridChanged:Boolean = true;			
		private var _startCell:GridCell;				// start cell in highlighting
		private var _activeCell:GridCell;				// current active cell
		private var _selected:ArrayCollection;			// <GridCell> represents cells that are highlighted
		private var _affected:ArrayCollection;			// <GridCell>
		private var _affectedBelow:GridCell;
		private var _fields:ArrayCollection;			// <EntryTypeField> fields for the row
		private var _mouseUp:Boolean = false;			// use in the mouseUp method to determine whether to highlight
		private var _cornerSelected:Boolean = false;	
		
		public function GridHolder()
		{
			super();
			
			this.horizontalScrollPolicy = ScrollPolicy.AUTO;
			this.verticalScrollPolicy = ScrollPolicy.ON;
			
			this._selected = new ArrayCollection();
			this._affected = new ArrayCollection();
			
			// needs to receive events in the sequence (down, release)
			this.addEventListener( GridCellEvent.MOUSE_DOWN, mouseDown );
			this.addEventListener( GridCellEvent.MOUSE_UP, mouseUp );
			
			this.addEventListener( GridCellMouseEvent.MOUSE_DRAG, mouseDrag );
			this.addEventListener( MoveCellEvent.ARROW_PRESSED, changeCell );		
			this.addEventListener( GridCellMouseEvent.CORNER_CLICK, cornerClick );
			
			// clipboard events
			this.addEventListener( Event.COPY, copyCellsHandler );
			this.addEventListener( Event.SELECT_ALL, selectAllHandler );
			this.addEventListener( Event.CUT, cutHandler );
		}
		
		public function get grid() : Grid
		{
			return this._grid;
		}
		
		public function reset() : void
		{
			if( this.grid )
			{
				this.horizontalScrollPosition = 0;
				this.grid.x = 0;
				this.grid.reset();
			}
		}
		
		public function selectRow( index:Number, additive:Boolean ) : void
		{
			if( ( index < 0 && index >= this.grid.rowSize() ) || !this.grid )
				return;
			
			var cells:ArrayCollection = this.grid.selectRow( index );
			if( !additive )
				this.clearCurrentSelected();
			
			this._selected.addAll(cells);
			
			for each( var selected:GridCell in this._selected )
			{
				selected.fill();
			}
			
			this._activeCell = this._selected.getItemAt( 0 ) as GridCell;
			this._activeCell.highlight( false );
			this._activeCell.setFocus();
		}
		
		private function cornerClick( event:GridCellMouseEvent ) : void
		{
			this._cornerSelected = true;
		}
		
		private function cornerDrag( cell:GridCell ) : void
		{
			if( this._affectedBelow )
				this._affectedBelow.clearTop();
			
			// current cell being dragged over
			this._grid.createNextRowIfNeeded( cell );
			
			// can only drag down
			if( cell.index != this._startCell.index )
				cell = this._grid.cellAt( cell.row, this._startCell.index );
			
			// clear current "dashed"
			for each ( var dashed:GridCell in this._affected )
			{
				dashed.reset();
			}
			this._affected.removeAll();
			this._selected.removeAll();
			this._selected.addItem( this._activeCell );
			var inverse:Boolean = ( cell.row < this._activeCell.row );
			
			// determine where to draw dashes
			var startIndex:int = inverse ? cell.row : this._activeCell.row + 1;
			var endIndex:int = inverse ? this.activeCell.row - 1: cell.row;
			
			while( startIndex < endIndex +1 )
			{
				var currentCell:GridCell = this.grid.cellAt( startIndex, this._startCell.index );
				currentCell.dashBorderLeft();
				if( !this._affected.contains( currentCell ) )
				{
					this._affected.addItem( currentCell );
					if( !this._selected.contains( currentCell ) )
						this._selected.addItem( currentCell );
				}
				
				var rightOf:GridCell = this._grid.cellOnRightOf( currentCell );
				if( rightOf != null && !this._affected.contains( rightOf ) )
				{
					this._affected.addItem( rightOf );
					rightOf.dashBorderLeft();
				}
				startIndex += 1;
			}
			
			// dashed border on top but has to be cell below; 
			var below:GridCell = inverse ? cell : this._grid.cellBelow( cell );
			if( below != null )
			{
				below.dashBorderTop();
				this._affectedBelow =  below ;
			}
			
			dispatchEvent( new GridEvent( GridEvent.CELLS_SELECTED, -1, this._selected ) );
		}
		
		private function selectDrag( cell:GridCell ) : void
		{
			for each( var selected:GridCell in this._selected )
			{
				selected.reset();
			}
			this._selected.removeAll();
			
			var highlighted:Vector.<GridCell> = this._grid.highlightCells( this._startCell, cell, this._cornerSelected );

			for each( var highlight:GridCell in highlighted )
			{
				highlight.fill();
				
				if( this._selected.contains( highlight ) ) 
					continue;
				
				this._selected.addItem( highlight );
			}
			
			dispatchEvent( new GridEvent( GridEvent.CELLS_SELECTED, -1, this._selected ) );
		}
		
		private function mouseDrag( event:GridCellMouseEvent ) : void
		{
			if( this._mouseUp )
				return;
				
			if( event.buttonDown )
			{
				if( this._cornerSelected )
					this.cornerDrag( event.cell );
				else
					this.selectDrag( event.cell );
			}
		}
		
		// determines whether to highlight any of the cells
		private function mouseUp( event:GridCellEvent ) : void
		{
			if( this._mouseUp )
				return;
			
			this._mouseUp = true;
			
			if( this._cornerSelected )
			{
				this._cornerSelected = false;
				for each( var affected:GridCell in this._affected )
				{
					affected.reset();
				}
				this._affected.removeAll();
				
				if( _affectedBelow != null )
				{
					_affectedBelow.reset();
					_affectedBelow = null;
				}
				
				// fill selected (note that the initial selected cell is included)
				for each( var selected:GridCell in this._selected )
				{
					selected.fill();
					selected.text = this._startCell.text;
				}
				
				// initial selected
				this._activeCell.reset();
				this._activeCell.highlight(false);
			}
			
			// get the end cell 
			var endCell:GridCell = event.cell;
			
			if( endCell.equals( _startCell ) ) 
				return;
		}
		
		private function mouseDown( event:GridCellEvent ) : void
		{
			// clear all highlighted cells
			for each( var hCell:GridCell in _selected )
			{
				hCell.reset();
			}
			_selected.removeAll();
			
			if( this._affectedBelow )
			{
				_affectedBelow.reset();
			}
			this._affectedBelow = null; //removeAll();
			
			// highlight currently clicked
			this._startCell = event.cell;
			this._selected.addItem( this._startCell );
			this._startCell.highlight( true );
			
			// current click is always the active
			if( this._activeCell != null && this._activeCell.inEditMode && !this._activeCell.equals(this._startCell ))
			{
				this._activeCell.switchToDisplayMode();
			}
				
			this._activeCell = this._startCell;
			this._mouseUp = false;
			
			dispatchEvent( new GridEvent( GridEvent.CELLS_SELECTED, -1, this._selected ) );
		}
		
		private function selectAndHighlightCell( cell:GridCell ) : void
		{
			this.clearCurrentSelected();
			
			if( this._activeCell.inEditMode )
			{
				this._activeCell.switchToDisplayMode();
			}
			
			// change active cell
			this._activeCell = cell;
			this._activeCell.highlight(true);
			this._activeCell.setFocus();
			this._selected.addItem( this._activeCell );	
			
			var c:ArrayCollection = new ArrayCollection();
			c.addItem( this._activeCell );
			dispatchEvent( new GridEvent( GridEvent.CELLS_SELECTED, -1, c ) );
		}
		
		private function autoScrollHorizontal( dir:Direction ) : void
		{
			var visibleCount:int = ( this.width / GridCell.DEFAULT_WIDTH ) ; 
			var index:int = this._activeCell.index;
			var start:Number = this.horizontalScrollPosition / GridCell.DEFAULT_WIDTH;
			
			// is current index visible (NOTE: this is the key determining factor in auto scrolling)	
			var isIndexVisible:Boolean = index >= start && index < ( start + visibleCount - 1 ); // -1 for the last visible cell. do not want to wait to get there before scrolling
			
			if( isIndexVisible )
				return;
			
			// where to autoscroll to
			switch( dir )
			{
				case Direction.MOVE_LEFT:
					this.horizontalScrollPosition = ( index == 0 ) ? 0 : ( this.horizontalScrollPosition - GridCell.DEFAULT_WIDTH );
					this._grid.x = ( -1 * this.horizontalScrollPosition );
					break;
				
				case Direction.MOVE_RIGHT:
					this.horizontalScrollPosition = ( index == ( this._grid.rowCellCount - 1 ) ) ? this.maxHorizontalScrollPosition : ( this.horizontalScrollPosition + GridCell.DEFAULT_WIDTH );
					this._grid.x = ( -1 * this.horizontalScrollPosition );
					break;
			}
			
			dispatchEvent( new GridScrollEvent( GridScrollEvent.HSCROLL, this._grid.x ) );
		}
		
		private function autoScrollVertical( dir:Direction ) : void
		{
			var visibleCount:int = ( ( this.height - 30 ) / GridCell.DEFAULT_HEIGHT ) ; 
			var row:int = this._activeCell.row;
			var start:Number = this.verticalScrollPosition / GridCell.DEFAULT_HEIGHT;
			
			// is current index visible (NOTE: this is the key determining factor in auto scrolling)	
			var isIndexVisible:Boolean = ( row >= start ) && ( row < (start + visibleCount) );
			
			if( isIndexVisible )
				return;
			
			// where to autoscroll to
			switch( dir )
			{
				case Direction.MOVE_UP:
					this.verticalScrollPosition = ( row == 0 ) ? 0 : ( this.verticalScrollPosition - GridCell.DEFAULT_HEIGHT  );					
					this._grid.y = ( -1 * this.verticalScrollPosition );
					break;
				
				case Direction.MOVE_DOWN:
					this._grid.height = this.grid.rowSize() * GridCell.DEFAULT_HEIGHT + 1;
					this.verticalScrollPosition += GridCell.DEFAULT_HEIGHT;
					this.invalidateDisplayList();	// causes updatedisplayList to be called
					this._grid.y = ( -1 * this.verticalScrollPosition );
					break;
			}
			
			dispatchEvent( new GridScrollEvent( GridScrollEvent.VSCROLL, this._grid.y ) );
		}
		
		/**
		 * Handles GridCell change event which is dispatched 
		 * when the arrow keys are pressed to change the cell.
		 */ 
		private function changeCell( event:MoveCellEvent ) : void
		{
			var cell:GridCell = event.cell;
			
			switch( event.direction )
			{
				case Direction.MOVE_DOWN:	
					
					var lowerCell:GridCell = this._grid.cellBelow( cell );
					if( lowerCell == null )
						return;
					
					this.selectAndHighlightCell( lowerCell );
					this._grid.createNextRowIfNeeded( lowerCell );
					this.autoScrollVertical( Direction.MOVE_DOWN );
				break;
				
				case Direction.MOVE_LEFT:
					
					var leftCell:GridCell = this._grid.cellOnLeftOf( cell );
					if( leftCell == null )
						return;
					
					this.selectAndHighlightCell( leftCell );
					this.autoScrollHorizontal( event.direction );
				break;
					
				case Direction.MOVE_RIGHT:
					var cellOnRight:GridCell = this._grid.cellOnRightOf( cell );
					if( cellOnRight == null )
						return;
					
					this.selectAndHighlightCell( cellOnRight );
					this.autoScrollHorizontal( event.direction );
				break;
				
				case Direction.MOVE_UP:
					var upperCell:GridCell = this._grid.cellAbove( cell );
					if( upperCell == null )
						return;
					
					this.selectAndHighlightCell( upperCell );
					this.autoScrollVertical( Direction.MOVE_UP );
				break;
			}
		}
		
		// clears the currently selected cells, "de"-highlight it in the process 
		// TODO : this should be moved to the grid itself
		private function clearCurrentSelected() : void
		{
			for each( var hCell:GridCell in this._selected )
			{
				hCell.reset();
			}
			this._selected.removeAll();
		}
		
		/**
		 * sets the fields required for this grid and causes
		 * a "re-drawing"
		 */ 
		public function set gridFields( fields:ArrayCollection ) : void
		{
			this._fields = fields;
			this._gridChanged = true;
			this.invalidateProperties(); 	// causes commitProperties() to be called
			this.invalidateSize();			// causes measure() to be called
			this.invalidateDisplayList();	// causes updateDisplayList to be called
		}
		
		public function get gridFields() : ArrayCollection
		{
			return this._fields;
		}
		
		public function pasteIntoCells( gridPaste:GridPaste ) : void
		{
			var createdRows:int = this._grid.pasteIntoCells( gridPaste );
			this._grid.height = this.grid.rowSize() * GridCell.DEFAULT_HEIGHT + 1;
		}
		
		public function get activeCell() : GridCell
		{
			if( this._activeCell != null )
				return this._activeCell;
			
			// set default selected
			var rows:ArrayCollection = _grid.rows;
			if( rows.length > 0 )
			{
				this._activeCell = rows[0].cellAt(0);
				if( this._activeCell != null )
				{
					this._activeCell.highlight( true );
					this._selected.addItem( this._activeCell );
				}
			}
			
			return this._activeCell;
		}
		
		// remove children if any and add new one
		override protected function commitProperties() : void
		{
			super.commitProperties();
			if( !_gridChanged )
				return;
			
			this._gridChanged = false;
			
			if( this._grid )
			{
				this.removeChild( this._grid );
				this._grid = null;
				this.createGrid();
			}
		}
		
		// retrieve size of grid and set width and height to those
		override protected function measure() : void
		{
			super.measure();
			
			var edgeMetrics:EdgeMetrics = this.viewMetrics;
			
			var width:Number = edgeMetrics.left + edgeMetrics.right;
			var height:Number = edgeMetrics.top + edgeMetrics.bottom;
			
			// check if grid is available so we get the dimensions
			if( this._grid )
			{
				width += ( this._grid.width * this._grid.scaleX );
				height += ( this._grid.height * this._grid.scaleY );
			}
			else
			{
				// default of 100 * 100
				width += 100;
				height += 100;
			}
			
			this.measuredWidth = width;
			this.measuredHeight = height;
		}
		
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if( !this._grid )
				return;
			
			// gives size of border in scroll control base along
			// with visible scroll bar sizes
			var edgeMetrics:EdgeMetrics = this.viewMetrics;
			
			this._grid.x = edgeMetrics.left + -this.horizontalScrollPosition;
			this._grid.y = edgeMetrics.top + -this.verticalScrollPosition;
			
			// make grid visible.
			this._grid.visible = true;
			
			this.setScrollBarProperties(
				this._grid.width,
				unscaledWidth - edgeMetrics.left - edgeMetrics.right,
				this._grid.height,
				unscaledHeight - edgeMetrics.top - edgeMetrics.bottom
			);
		}	
		
		override protected function mouseWheelHandler( event:MouseEvent ):void
		{	
			// scroll preventer till I figure out how to handle the mouse wheel scroll
		}
		
		override protected function scrollHandler( event : Event ) : void 
		{	
			// return if there's no grid or event is not a scroll event
			if( !this._grid || !( event is ScrollEvent ) )
				return;
			
			// And finally, if we're not liveScrolling, and we're in the middle of scrolling, return.
			if ( !liveScrolling && ScrollEvent( event ).detail == ScrollEventDetail.THUMB_TRACK )
				return;
			
			super.scrollHandler( event );
			
			this._grid.x = this.viewMetrics.left + -this.horizontalScrollPosition;
			this._grid.y = this.viewMetrics.top + -this.verticalScrollPosition;
			
			// dispatch so that the headers are also scrolled
			dispatchEvent( new GridScrollEvent( GridScrollEvent.HSCROLL, this._grid.x ) );
			dispatchEvent( new GridScrollEvent( GridScrollEvent.VSCROLL, this._grid.y ) );
		}
				
		/**
		 * Creates the grid if it does not exist
		 * and adds it as a child of this UI component
		 */		
		public function createGrid() : void
		{
			if( this._grid )
				return;
			
			var size:int = this._fields.length;
			this._grid = new Grid( this._fields, this );
			
			// TODO : these should be moved within the grid
			this._grid.width = ( size * GridCell.DEFAULT_WIDTH ) + 1;
			this._grid.height = GridCell.DEFAULT_HEIGHT * this.grid.rowSize();
			
			this._grid.visible = false;
			this._grid.mask = this.maskShape;	
			
			this.addChild( this._grid );
		}
		
		private function copyCellsHandler( event:Event ) : void
		{
			var i:int = -1;
			var text:String = "";
			
			for each( var cell:GridCell in this._selected )
			{
				// endline
				if( i != cell.row )
				{
					if( i != -1 )
						text += ( "\n" );
					i = cell.row;
				}
				
				text += ( cell.text + "\t" );
			}
			
			System.setClipboard( text );
		}
		
		private function cutHandler( event:Event ) : void
		{
			var i:int = -1;
			var text:String = "";
			
			for each( var cell:GridCell in this._selected )
			{
				// endline
				if( i != cell.row )
				{
					if( i != -1 )
						text += ( "\n" );
					i = cell.row;
				}
				
				text += ( cell.text + "\t" );
				cell.text = "";
			}
			
			System.setClipboard( text );
		}
		
		private function selectAllHandler( event:Event ) : void
		{
			this._activeCell.reset();
			
			var ret:ArrayCollection = this._grid.selectAll();
			if( ret && ret.length > 0 )
			{
				this._selected.removeAll();
				this._selected.addAll( ret );
			}
		}
	}
}