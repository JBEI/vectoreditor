package org.jbei.components.common
{
	import flash.events.Event;

    /**
     * @author Zinovii Dmytriv
     */
	public class SelectionEvent extends Event
	{
		public var start:int;
		public var end:int;
		
		// Static Constants
		public static const SELECTION_CHANGED:String = "selectionChanged";
		
		// Constructor
		public function SelectionEvent(type:String, start:int, end:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.start = start;
			this.end = end;
			
			super(type, true, cancelable);
		}
	}
}
