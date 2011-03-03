package org.jbei.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	public class GridEvent extends Event
	{
		public static const ROW_ADDED:String = "rowAdded";
		public static const AUTO_FILL:String = "autoContentFill";
		public static const CELLS_SELECTED:String = "cellsSelected";
		
		private var _rowIndex:Number;
		private var _cells:ArrayCollection;
		
		public function GridEvent( type:String, rowIndex:Number=-1, cells:ArrayCollection=null )
		{
			super( type, true );
			this._rowIndex = rowIndex;
			this._cells = cells;
		}
		
		public function get rowIndex() : Number
		{
			return this._rowIndex;
		}
		
		public function get cells() : ArrayCollection
		{
			return this._cells;
		}
	}
}