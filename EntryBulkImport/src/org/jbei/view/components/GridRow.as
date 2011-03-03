package org.jbei.view.components
{
	import flash.display.Graphics;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	import org.jbei.model.EntryTypeField;
	import org.jbei.model.util.EntryFieldUtils;
	
	import spark.components.TextInput;
	
	public class GridRow extends UIComponent
	{
		private var _cells:ArrayCollection;		// <GridCell>
		private var _cellCount:Number;			// number of cells in the grid row
		private var _index:Number;				// position of the row in the grid
		private var _fields:ArrayCollection;	// <EntryTypeField>
		
		public function GridRow( index:Number, cellCount:Number, fields:ArrayCollection )
		{
			this._cellCount = cellCount;
			this._cells = new ArrayCollection(); // <GridCell>			
			this._index = index;
			this._fields = fields;
		}
		
		public function get index() : Number
		{
			return this._index;
		}
		
		public function cellAt( index:int ) : GridCell
		{
			if( index >= _cells.length || index < 0 )
				return null;
			
			return this._cells[index];
		}
		
		public function get cells() : ArrayCollection 
		{
			return this._cells;
		}
		
		// for layout note that the parent is a single row
		override protected function createChildren() : void
		{
			super.createChildren();
			
			var verticalY:Number = new Number( 0 ); 
			var data:ArrayCollection = null;
			
			if( this._cells.length == 0 )
			{
				for( var i:int = 0; i < this._cellCount; i += 1 )
				{
					var input:GridCell;
					
					if( this._fields != null )
					{
						var field:EntryTypeField = this._fields.getItemAt( i ) as EntryTypeField;
						data = EntryFieldUtils.autoCompleteDataProvider( field ); 		// TODO: use the factory
	
						if( data != null )
						{
							input = new AutoCompleteGridCell( i, this._index );
							AutoCompleteGridCell( input ).dataProvider = data;
						}
						else 
							input = new GridCell( i, this._index );
					}
					else
						input = new GridCell( i, this._index );
					
					input.y = 0;
					input.x = verticalY; // lay it out in a row
					this._cells.addItem( input ); 
					addChild( input );
					verticalY += GridCell.DEFAULT_WIDTH;
				}
			}
		}
	}
}