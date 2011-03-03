package org.jbei.events
{
	import flash.events.Event;
	
	import org.jbei.view.components.GridCell;

	public class GridCellMouseEvent extends Event
	{
		public static const MOUSE_DRAG:String = "mouseDrag";
		public static const CORNER_CLICK:String = "cornerClick";
		
		private var _cell:GridCell;
		private var _buttonDown:Boolean;
		
		public function GridCellMouseEvent( type:String, cell:GridCell, buttonDown:Boolean )
		{
			super( type, true );
			this._cell = cell;
			this._buttonDown = buttonDown;
		}
		
		public function get buttonDown() : Boolean
		{
			return this._buttonDown;
		}
		
		public function get cell() : GridCell
		{
			return this._cell;
		}
	}
}