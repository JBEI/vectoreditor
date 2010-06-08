package org.jbei.lib.mappers
{
	import flash.events.Event;

    /**
     * @author Zinovii Dmytriv
     */
	public class ORFMapperEvent extends Event
	{
		public static const ORF_MAPPER_UPDATED:String = "OrfMapperUpdated";
		
		// Constructor
		public function ORFMapperEvent(type:String)
		{
			super(type, false, false);
		}
	}
}
