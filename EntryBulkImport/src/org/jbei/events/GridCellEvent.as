package org.jbei.events
{
	import flash.events.Event;
	
	import org.jbei.view.components.GridCell;
	
	public class GridCellEvent extends Event
	{
		public static const MOUSE_UP:String = "mUp";
		public static const MOUSE_DOWN:String = "mDown";
		public static const POSSIBLE_END:String = "pEnd";
		public static const SCROLL:String = "scroll";
		public static const SELECTED:String = "selected";
		public static const TEXT_CHANGE:String = "textChange";
		public static const DELETE:String = "delete";
		public static const PASTE:String = "cellPaste";
		public static const CTRL_BTN_DOWN:String = "controlButtonDown";
		public static const CTRL_BTN_UP:String = "controlButtonUp";
		
		private var _cell:GridCell;
		private var _text:String;
		
		public function GridCellEvent( type:String, cell:GridCell=null, text:String=null, 
									   bubbles:Boolean = true, cancelable:Boolean = false )
		{
			super(type, bubbles, cancelable);
			this._cell = cell;
			this._text = text;
		}
		
		public function get cell() : GridCell
		{
			return this._cell;
		}
		
		public function get text() : String
		{
			return this._text;
		}
	}
}