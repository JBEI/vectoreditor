package org.jbei.lib
{
	import flash.events.Event;

	public class AAMapperEvent extends Event
	{
		public static const AA_MAPPER_UPDATED:String = "AAMapperUpdated";
		
		// Constructor
		public function AAMapperEvent(type:String)
		{
			super(type, false, false);
		}
	}
}
