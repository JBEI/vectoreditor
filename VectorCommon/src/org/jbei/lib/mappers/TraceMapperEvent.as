package org.jbei.lib.mappers
{
	import flash.events.Event;

    /**
     * @author Zinovii Dmytriv
     */
	public class TraceMapperEvent extends Event
	{
		public static const TRACE_MAPPER_UPDATED:String = "TraceMapperUpdated";
		
		// Constructor
		public function TraceMapperEvent(type:String)
		{
			super(type, false, false);
		}
	}
}
