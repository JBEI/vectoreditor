package org.jbei.lib.mappers
{
	import flash.events.Event;

    /**
     * @author Zinovii Dmytriv
     */
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
