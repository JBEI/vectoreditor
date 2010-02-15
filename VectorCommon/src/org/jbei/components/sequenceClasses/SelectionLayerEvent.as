package org.jbei.components.sequenceClasses
{
	import flash.events.Event;
	
	public class SelectionLayerEvent extends Event
	{
		// Static Constants
		public static const OVER:String = "overSelectionEvent";
		public static const OUT:String = "outOfSelectionEvent";
		public static const SELECT:String = "selectEvent";
		public static const DESELECT:String = "deselectEvent";
		public static const SELECTION_CHANGED:String = "selectionLayerSelectionChanged";
		public static const SELECTION_HANDLE_CLICKED:String = "handleClickedEvent";
		public static const SELECTION_HANDLE_RELEASED:String = "handleReleasedEvent";
		
		public var handleKind:String;
		
		// Constructor
		public function SelectionLayerEvent(type:String, handleKind:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.handleKind = handleKind;
		}
	}
}
