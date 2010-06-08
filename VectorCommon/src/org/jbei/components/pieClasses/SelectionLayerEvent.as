package org.jbei.components.pieClasses
{
	import flash.events.Event;
	
    /**
     * @author Zinovii Dmytriv
     */
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
		
		public var leftHandlePressed:Boolean = false;
		public var rightHandlePressed:Boolean = false;
		
		// Constructor
		public function SelectionLayerEvent(type:String, leftHandlePressed:Boolean = false, rightHandlePressed:Boolean = false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.leftHandlePressed = leftHandlePressed;
			this.rightHandlePressed = rightHandlePressed;
			
			super(type, bubbles, cancelable);
		}
		
		// Public Methods
		public override function clone():Event
		{
			return new SelectionLayerEvent(type, leftHandlePressed, rightHandlePressed, bubbles, cancelable);
		}
	}
}
