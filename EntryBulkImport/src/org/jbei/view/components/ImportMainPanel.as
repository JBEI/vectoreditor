package org.jbei.view.components
{ 
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	import org.jbei.events.GridCellEvent;
	import org.jbei.events.GridEvent;
	import org.jbei.events.GridScrollEvent;
	import org.jbei.events.MoveCellEvent;
	import org.jbei.model.GridPaste;
	
	import spark.components.Button;
	
	// not strictly a panel but....
	public class ImportMainPanel extends UIComponent
	{
		private var grid:GridHolder;
		
		public function ImportMainPanel()
		{	
			this.grid = new GridHolder();
		}
		
		public function set gridFields( fields : ArrayCollection ) : void 
		{
			grid.gridFields = fields;					// set the content
		}
		
		public function get activeGridCell() : GridCell
		{
			return this.grid.activeCell;
		}
		
		public function pasteIntoCells( gridPaste:GridPaste ) : void
		{
			this.grid.pasteIntoCells( gridPaste );
		}
		
		public function get gridHolder() : GridHolder
		{
			return this.grid;
		}
		
		public function createGrid() : void
		{
			if( !this.gridHolder )
				return;
			
			this.gridHolder.createGrid();
		}
		
		public function resetGridHolder() : void
		{
			this.grid.x = 30;
			this.grid.reset();
		}
		
		override protected function createChildren() : void 
		{
			grid.x = 30;
			grid.y = 0;
			grid.height = this.height;
			grid.width = this.width;
			
			this.addChild( grid );
		}
	}
}