package org.jbei.components.common
{
	import flash.events.Event;

	public class CommonEvent extends Event
	{
		public var data:Object;
		
		// Contructor
		public function CommonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object = null)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
	}
}
