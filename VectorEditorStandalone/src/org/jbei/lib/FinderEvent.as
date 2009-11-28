package org.jbei.lib
{
	import flash.events.Event;
	
	public class FinderEvent extends Event
	{
		public static const FINDER_UPDATED:String = "FinderUpdated";
		
		// Constructor
		public function FinderEvent(type:String)
		{
			super(type, false, false);
		}
	}
}
