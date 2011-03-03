package org.jbei.view.components
{
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Label;
	import mx.core.ScrollControlBase;
	import mx.core.UIComponent;
	
	import org.jbei.model.EntryTypeField;

	// row of column header cells
	public class GridColumnHeaderRow extends UIComponent
	{
		private var _columnHeaders:ArrayCollection;		// <GridColumnHeader>;
		
		// takes a collection of entry fields and displays it
		public function GridColumnHeaderRow( collection:ArrayCollection )
		{
			super();
			
			_columnHeaders = new ArrayCollection();		// <GridColumnHeader>();
			
			if( collection != null )
			{
				trace("setting headers " + collection.length );
				for( var i:int = 0; i < collection.length; i += 1 )
				{
					var typeField:EntryTypeField = collection.getItemAt( i ) as EntryTypeField;
					var header:GridColumnHeader = new GridColumnHeader( typeField );
					header.x = GridRowHeader.DEFAULT_WIDTH + 1 + ( i * GridCell.DEFAULT_WIDTH );
					header.y = 0;
					header.height = GridColumnHeader.HEIGHT;			
					_columnHeaders.addItem( header );
					
					this.addChild( header );					
				}
			}
		}
		
		public function reset() : void
		{
			trace( "resetting " + _columnHeaders.length );
			
			for each( var header:GridColumnHeader in this._columnHeaders )
			{
				header.render();	// reset
			}
		}
		
		// indicates that an active selection has been made
		public function activeSelection( cells:ArrayCollection ) /*<GridCell>*/ : void
		{
			for each( var header:GridColumnHeader in this._columnHeaders )
			{
				header.render();
			}
			
			for each( var cell:GridCell in cells )
			{
				var highlight:GridColumnHeader = this._columnHeaders.getItemAt( cell.index ) as GridColumnHeader ;
				highlight.highlight();
			}
		}
		
		public function get headers() : ArrayCollection
		{
			return this._columnHeaders;
		}
		
		override protected function createChildren() : void
		{
			super.createChildren();
			
			if( _columnHeaders.length > 0 )
				return;
			
			var label:Label = new Label();
			label.width = GridRowHeader.DEFAULT_WIDTH + 1;
			label.height = GridCell.DEFAULT_HEIGHT;
			label.x = 0;
			label.y = 0;
			
			label.graphics.clear();
			label.graphics.lineStyle(1, 0x000000);
			label.graphics.beginFill(0xFFFFFF);
			label.graphics.lineTo(label.x, label.y);
			label.graphics.lineTo(label.x, label.x + label.height+1);
			label.graphics.endFill();
			this.addChild(label);
		}
	}
}