package org.jbei.lib.utils
{
	import flash.events.Event;

    /**
     * @author Zinovii Dmytriv
     */
	public class LoggerEvent extends Event
	{
		public static const LOG:String = "LoggerEvent";
		
		public var message:String;
		
		// Constructor
		public function LoggerEvent(type:String, message:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.message = message;
		}
	}
}
