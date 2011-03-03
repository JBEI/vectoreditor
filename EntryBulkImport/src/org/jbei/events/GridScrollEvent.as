package org.jbei.events
{
	import flash.events.Event;

	public class GridScrollEvent extends Event
	{
		public static const HSCROLL:String = "horizontalScroll";
		public static const VSCROLL:String = "verticalScroll";
		
		private var _delta:Number;
		
		public function GridScrollEvent( type:String, delta:Number )
		{
			super( type, true );
			this._delta = delta;
		}
		
		public function get delta() : Number
		{
			return this._delta;
		}
	}
}