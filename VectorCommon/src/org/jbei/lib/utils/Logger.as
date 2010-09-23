package org.jbei.lib.utils
{
	import flash.events.EventDispatcher;
	
    /**
     * Logger class. This is singleton class so to get an instance use getInstance() method : Logger.getInstance();
     * 
     * @author Zinovii Dmytriv
     */
	public class Logger extends EventDispatcher
	{
		private static var instance:Logger;
		
		// Constructor
		public function Logger()
		{
			if (instance != null) {
                throw Error("Logger already instantiated!");
            }
		}
		
		// Properties
		public static function getInstance():Logger
		{
			if(instance == null) {
				instance = new Logger();
			}
			
			return instance as Logger;
		}
		
		// Public Methods
		public function error(message:String):void
		{
			log("ERROR:   " + message);
		}
		
		public function warning(message:String):void
		{
			log("WARNING: " + message);
		}
		
		public function info(message:String):void
		{
			log("INFO:    " + message);
		}
		
		// Protected Methods
		protected function log(message:String):void
		{
			dispatchEvent(new LoggerEvent(LoggerEvent.LOG, message));
		}
	}
}
