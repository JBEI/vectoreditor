package org.jbei.components.common
{
	import flash.events.Event;
    
    /**
     * Caret Event for Pie, Rail and SequenceAnnotator components
     * 
     * @author Zinovii Dmytriv
     */
	public class CaretEvent extends Event
	{
		public var position:int = -1;
		
		// Static Constants
        public static const CARET_POSITION_CHANGED:String = "caretPositionChanged";
		
		// Constructor
        /**
        * Contructor
        */
		public function CaretEvent(type:String, position:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.position = position;
			
			super(type, true, cancelable);
		}
	}
}