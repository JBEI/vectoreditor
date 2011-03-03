package org.jbei.events
{
	import flash.events.Event;
	
	import org.jbei.view.components.GridCell;
	
	public class MoveCellEvent extends Event
	{
		public static const ARROW_PRESSED:String = "arrowPressed";
		
		private var _cell:GridCell;
		private var _direction:Direction;
		
		public function MoveCellEvent( type:String, direction:Direction, cell:GridCell=null, bubbles:Boolean = true, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
			this._cell = cell;
			this._direction = direction;
		}
		
		public function get direction() : Direction
		{
			return this._direction;
		}
		
		public function get cell() : GridCell
		{
			return this._cell;
		}
	}
}