package org.jbei.events
{
	import flash.events.Event;

	public class RowHeaderEvent extends Event
	{
//		public static const MOUSE_CLICK:String = "rowHeaderMouseClick";
		public static const MOUSE_OVER:String = "rowHeaderMouseOver";
		public static const MOUSE_UP:String = "rowHeaderMouseUp";
		public static const MOUSE_DOWN:String = "rowHeaderMouseDown";
		
		private var _index:Number;
		
		public function RowHeaderEvent( type:String, index:Number, bubbles:Boolean = true )
		{
			super( type, bubbles );
			this._index = index;
		}
		
		public function get index() : Number
		{
			return this._index;
		}
	}
}