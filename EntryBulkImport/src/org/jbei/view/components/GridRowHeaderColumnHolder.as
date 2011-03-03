package org.jbei.view.components
{
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.collections.ArrayCollection;
	import mx.core.EdgeMetrics;
	import mx.core.ScrollControlBase;
	
	import spark.components.TextInput;

	public class GridRowHeaderColumnHolder extends ScrollControlBase
	{
		private var _rowHeaderColumn:GridRowHeaderColumn;
		
		public function GridRowHeaderColumnHolder()
		{
			super();
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.verticalScrollPolicy = ScrollPolicy.OFF;
		}
		
		public function get rowHeader() : GridRowHeaderColumn
		{
			return this._rowHeaderColumn;
		}
		
		public function get headerCount() : Number
		{
			return this._rowHeaderColumn.cellCount();
		}
		
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ) : void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if( !this._rowHeaderColumn )
				return;
			
			var edgeMetrics:EdgeMetrics = this.viewMetrics;
			
			this._rowHeaderColumn.x = edgeMetrics.left + -this.horizontalScrollPosition;
			this._rowHeaderColumn.y = edgeMetrics.top + -this.verticalScrollPosition;
			
			this._rowHeaderColumn.visible = true;
			
			this.setScrollBarProperties(
				this._rowHeaderColumn.width,
				unscaledWidth - edgeMetrics.left - edgeMetrics.right,
				this._rowHeaderColumn.height,
				unscaledHeight - edgeMetrics.top - edgeMetrics.bottom
			);
		}	
		
		public function highlightHeaders( cells:ArrayCollection ) /*<GridCell>*/ : void
		{
			this._rowHeaderColumn.highlightHeaders( cells );
		}
		
		public function addHeader() : void
		{
			this._rowHeaderColumn.addHeader();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if( this._rowHeaderColumn )
				return;
			
			this._rowHeaderColumn = new GridRowHeaderColumn();	
			
			this._rowHeaderColumn.width = this.width;
			this._rowHeaderColumn.height = this.height;
			
			this._rowHeaderColumn.visible = false;
			this._rowHeaderColumn.mask = this.maskShape;
			
			this.addChild( this._rowHeaderColumn );
		}
	}
}