package org.jbei.registry.lib
{
	import flash.events.Event;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class ActionStackEvent extends Event
	{
		public static const ACTION_STACK_CHANGED:String = "actionStackEventChanged";
		
		// Constructor
		public function ActionStackEvent(type:String)
		{
			super(type);
		}
	}
}