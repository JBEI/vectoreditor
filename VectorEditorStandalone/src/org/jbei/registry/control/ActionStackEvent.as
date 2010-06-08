package org.jbei.registry.control
{
	import flash.events.Event;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class ActionStackEvent extends Event
	{
		public static const ACTION_STACK_CHANGED:String = "ActionStackEventChanged";
		
		// Constructor
		public function ActionStackEvent(type:String)
		{
			super(type);
		}
	}
}
