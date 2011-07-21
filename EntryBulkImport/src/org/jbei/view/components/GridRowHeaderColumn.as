package org.jbei.view.components
{
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;

	public class GridRowHeaderColumn extends UIComponent
	{
		private var _cells:ArrayCollection;			// <GridRowHeader>
		
		public function GridRowHeaderColumn()
		{
			super();
			
			this._cells = new ArrayCollection();	// <GridRowHeader>
			for( var i:int = 0; i<Grid.START_CELL_COUNT; i += 1 )
			{
				addHeader();
			}
		}
		
		public function reset() : void
		{
			for each (var header:GridRowHeader in this._cells )
			{
				this.removeChild( header );
			}
			this._cells.removeAll();
			for( var i:int = 0; i<Grid.START_CELL_COUNT; i += 1 )
			{
				addHeader();
			}
		}
		
		public function highlightHeaders( cells:ArrayCollection ) : void
		{
			for each ( var header:GridRowHeader in this._cells )
			{
				header.reset();
			}
			
			for each( var gridCell:GridCell in cells )
			{
				var highlight:GridRowHeader = this._cells.getItemAt( gridCell.row ) as GridRowHeader;
				highlight.highlight();
			}
		}
		
		public function hightlightHeader( index:Number, clearOthers:Boolean ) : void
		{
			if( clearOthers )
			{
				for each( var header:GridRowHeader in this._cells )
					header.reset();
			}
			
			var rowHeader:GridRowHeader = this._cells.getItemAt( index ) as GridRowHeader;
			rowHeader.highlight();
		}
		
		/**
		 * Adds another header to the column
		 */ 
		public function addHeader() : void
		{
			var index:int = this._cells.length;
			var header:GridRowHeader = new GridRowHeader( index + 1 ); 
			header.x = 0;
			header.y = index * GridRowHeader.DEFAULT_HEIGHT;
			this._cells.addItem( header );
			this.addChild( header );
		}
		
		/**
		 * Number of cells in the column
		 */ 
		public function cellCount() : Number
		{
			return this._cells.length;
		}
	}
}
