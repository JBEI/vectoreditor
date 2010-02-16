package org.jbei.lib.mappers
{
	import flash.events.Event;

	public class RestrictionEnzymeMapperEvent extends Event
	{
		public static const RESTRICTION_ENZYME_MAPPER_UPDATED:String = "RestrictionEnzymeMapperUpdated";
		
		// Constructor
		public function RestrictionEnzymeMapperEvent(type:String)
		{
			super(type, false, false);
		}
	}
}
