package org.jbei.view.components
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	import org.jbei.events.GridCellEvent;
	import org.jbei.events.GridEvent;
	import org.jbei.model.GridPaste;
	
	import spark.components.TextArea;

	public class Grid extends UIComponent
	{
		public static const BACKGROUND_COLOR:uint = 0xFFFFFF;
		public static const START_CELL_COUNT:int = 2;
		
		private var _rows:ArrayCollection;			// <GridRow>
		private var _rowCellCount:Number;			// number of cells per row
		private var _fields:ArrayCollection;		// <EntryTypeField>
		
		// controls
		private var _holder:GridHolder;
		
		public function Grid( fields:ArrayCollection, holder:GridHolder )
		{
			super();
			
			this._rowCellCount = fields.length;
			this._fields = fields;
			
			// create the row
			this._rows = new ArrayCollection();		// <GridRow>
			for( var i:int = 0; i < START_CELL_COUNT; i += 1 )
			{
				var row:GridRow = new GridRow( i, this._rowCellCount, fields );
				row.x = 0;
				row.y = GridCell.DEFAULT_HEIGHT * i; 
				this._rows.addItem( row );
				this.addChild( row );
			}			 
			
			this._holder = holder;
			
			// event listeners
			this.addEventListener( GridCellEvent.POSSIBLE_END, checkCreateNewRow );
		}
		
		public function selectAll() : ArrayCollection // <GridCell>
		{
			var selected:ArrayCollection = new ArrayCollection();
			
			for( var i:int = 0; i<this._rows.length; i += 1 )
			{
				var row:GridRow = this._rows.getItemAt( i ) as GridRow;
				for( var j:int = 0; j < row.cells.length; j += 1 )
				{
					var cell:GridCell = row.cellAt( j ) as GridCell;
					cell.fill();
					selected.addItem( cell );
				}
			}
			
			return selected;
		}
		
		// returns all cells in speficied row
		public function selectRow( index:Number ) : ArrayCollection // <GridCell>
		{
			var row:GridRow = this._rows.getItemAt( index ) as GridRow; 
			return row.cells;
		}
		
		public function reset() : void
		{
			for each( var row:GridRow in this._rows )
			{
				this.removeChild( row );
			}
			
			this._rows.removeAll();
			this.createRow();
			this.createRow();
		}
				
		public function get fields() : ArrayCollection	// <EntryTypeField>
		{
			return this._fields;
		}
		
		public function pasteIntoCells( gridPaste:GridPaste ) : int
		{
			var currentRow:GridRow;
			var currentRowIndex:int = gridPaste.row;
			var createdRows:int = 0;
			
			for each( var array:Array in gridPaste.dist )
			{
				if( currentRowIndex == this._rows.length )
				{
					createRow();
					createdRows += 1;
				}
				
				currentRow = this._rows.getItemAt( currentRowIndex ) as GridRow;
				var j:int = gridPaste.col;
				
				for each( var text:String in array )
				{
					var cell:GridCell = currentRow.cellAt( j ); 
					if( cell != null )
						cell.text = text;
					else
						break;
					j += 1;
				}
				
				currentRowIndex += 1;
			}
			
			return createdRows;
		}
		
		/**
		 * returns the number of cells in each row
		 */ 
		public function get rowCellCount() : Number
		{
			return this._rowCellCount;
		}
		
		public function get rows() : ArrayCollection // of GridRows
		{
			return this._rows;
		}	
		
		public function cellAt( row:int, col:int ) : GridCell
		{
			return this._rows[row].cellAt( col );
		}
		 
		// return cell that is on the right of 
		// cell passed in the parameter. If there is no such cell,
		// then null is returned
		public function cellOnRightOf( cell:GridCell ) : GridCell 
		{
			return this._rows[cell.row].cellAt( cell.index + 1 );			
		}
		
		// returns cell to right of current cell
		// if goDown then the first cell in the next row is selected
		public function nextCell( cell:GridCell, goDown:Boolean ) : GridCell
		{
			var nextCell:GridCell = this.cellOnRightOf( cell );
			if( nextCell != null )
				return nextCell;
			
			return nextCell;
		}
		
		public function cellOnLeftOf( cell:GridCell ) : GridCell
		{
			if( cell.index == 0 )
				return null;
			
			return this._rows[cell.row].cellAt( cell.index - 1 );
		}
		
		public function cellAbove( cell:GridCell ) : GridCell 
		{
			if( cell.row == 0 )
				return null;
				
			var row:GridRow = this._rows[cell.row - 1] as GridRow;
			return row.cellAt( cell.index );
		}
		
		public function cellBelow( cell:GridCell ) : GridCell
		{
			if( cell.row == this._rows.length - 1 )
				return null;
			
			var row:GridRow = this._rows[cell.row + 1] as GridRow;
			return row.cellAt( cell.index );
		}

		// either cannot be null
		public function highlightCells( start:GridCell, end:GridCell, corner:Boolean=false ) : Vector.<GridCell>
		{
			var highlighted:Vector.<GridCell> = new Vector.<GridCell>();
			if( start == null || end == null )
				return highlighted;
			
			// check if mouse is raised on same cell
			if( start.equals( end ) )
			{
				highlighted.push( start );
				return highlighted;
			}
			
			// determine start and end rows
			var startRow:Number; 
			var endRow:Number;
			
			if( start.row < end.row )
			{
				startRow = start.row;
				endRow = end.row;
			}
			else
			{
				endRow = start.row;
				startRow = end.row;
			}
			
			var startIndex:Number = start.index;
			var endIndex:Number = start.index;
			
			if( !corner )
			{
				if( start.index < end.index )
				{
					startIndex = start.index;
					endIndex = end.index;
				}
				else
				{
					endIndex = start.index;
					startIndex = end.index;
				}
			}

			// retrieve rows
			for( var i:int = startRow; i <= endRow; i += 1 )
			{
				var row:GridRow = _rows[i];
				
				// for each row get the cells
				for( var j:int = startIndex; j <= endIndex; j += 1 )
				{
					var cell:GridCell = row.cellAt( j );
					highlighted.push( cell );
				}
			}

			return highlighted;
		}
		
		/**
		 * Number of rows in the grid
		 */
		public function rowSize() : int
		{
			return _rows.length;
		}
		
		private function checkCreateNewRow( event:GridCellEvent ) : void
		{
			var gridCell:GridCell = event.cell as GridCell;
			this.createNextRowIfNeeded( gridCell );
		}
		
		// checks if currentCell user is on, is the last cell and if so adds a new 
		// one
		public function createNextRowIfNeeded( currentCell:GridCell ) : Boolean
		{
			var numRows:int = _rows.length - 1;
			
			if( currentCell.row == numRows )
			{
				this.createRow();
				return true;
			}
			return false;
		}
		
		// adds another row
		private function createRow() : void
		{
			var newRow:GridRow = new GridRow( _rows.length, this._rowCellCount, this._fields );
			newRow.x = 0;
			newRow.y = _rows.length * GridCell.DEFAULT_HEIGHT;
			_rows.addItem( newRow );
			this.addChild( newRow );
			dispatchEvent( new GridEvent( GridEvent.ROW_ADDED, newRow.index ) );
		}
	}
}