package org.jbei.view.components
{
	import flash.events.Event;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.collections.ArrayCollection;
	import mx.core.EdgeMetrics;
	import mx.core.ScrollControlBase;
	import mx.core.UIComponent;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	
	import org.jbei.events.GridCellEvent;

	// holds a grid column row without showing the scroll bars in order
	// change content 
	public class GridColumnHeaderRowHolder extends ScrollControlBase
	{ 
		private var _headerRow:GridColumnHeaderRow;
		private var changed:Boolean = true;
		private var collection:ArrayCollection;
		
		public function GridColumnHeaderRowHolder()
		{
			super();
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			
			//event listeners
			this.addEventListener( GridCellEvent.SCROLL, scrollHandler );
		}
		
		public function get headerRow() : GridColumnHeaderRow
		{
			return this._headerRow;
		}
		
		public function set headerRowCollection( collection:ArrayCollection ) : void
		{
			this.collection = collection;
			this.changed = true;
			this.invalidateProperties();
			this.invalidateSize();
			this.invalidateDisplayList();
		}
				
		// remove children if any and add new one
		override protected function commitProperties() : void
		{
			super.commitProperties();
			if( !changed )
				return;
			
			this.changed = false;
			
			if( this.headerRow )
			{
				this.removeChild( this.headerRow );
				this._headerRow = new GridColumnHeaderRow( this.collection );
				
				this._headerRow.width = 10 * GridCell.DEFAULT_WIDTH;;
				this._headerRow.height = 400; // TODO : DEFAULT VIEW (use cell height for calculation)
				
				this._headerRow.visible = false;
				this._headerRow.mask = this.maskShape;
				
				this.addChild( this._headerRow );
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			
			var edgeMetrics:EdgeMetrics = this.viewMetrics;
			
			var width:Number = edgeMetrics.left + edgeMetrics.right;
			var height:Number = edgeMetrics.top + edgeMetrics.bottom;
			
			// check if grid is available so we get the dimensions
			if( this.headerRow )
			{
				width += ( this.headerRow.width * this.headerRow.scaleX );
				height += ( this.headerRow.height * this.headerRow.scaleY );
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
		
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ) : void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			if( !this.headerRow )
				return;
			
			var edgeMetrics:EdgeMetrics = this.viewMetrics;
			
			this.headerRow.x = edgeMetrics.left + -this.horizontalScrollPosition;
			this.headerRow.y = edgeMetrics.top + -this.verticalScrollPosition;
			
			// make grid visible.
			this.headerRow.visible = true;
			
			this.setScrollBarProperties(
				this.headerRow.width,
				unscaledWidth - edgeMetrics.left - edgeMetrics.right,
				this.headerRow.height,
				unscaledHeight - edgeMetrics.top - edgeMetrics.bottom
			);
		}		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if( this._headerRow )
				return;
			
			this._headerRow = new GridColumnHeaderRow( this.collection );	// TODO : null initially
			
			this._headerRow.width = 10 * GridCell.DEFAULT_WIDTH;
			this._headerRow.height = 400;
			
			this._headerRow.visible = false;
			this._headerRow.mask = this.maskShape;
			
			this.addChild( this._headerRow );
		}
	}
}