package org.jbei.registry.proxies
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.TraceAlignment;
	import org.jbei.registry.utils.StandaloneUtils;

	public class TraceAlignmentServiceProxy extends AbstractServiceProxy
	{
		public static const NAME:String = "TraceAlignmentServiceProxy";
		private static const TRACE_ALIGNMENT_SERVICE_NAME:String = "TraceAlignmentService";
		
		private var _traceAlignment:TraceAlignment;
		
		// Constructor
		public function TraceAlignmentServiceProxy()
		{
			super(NAME, TRACE_ALIGNMENT_SERVICE_NAME);
		}
		
		// Properties
		public function get traceAlignment():TraceAlignment
		{
			return _traceAlignment;
		}
		
		// Public Methods
		public function fetchTraceAlignment(authToken:String, entryId:String):void
		{
			CONFIG::standalone {
				updateTraceAlignment(StandaloneUtils.standaloneTraceAlignment() as TraceAlignment);
				
				return;
			}
			
			//service.getEntry(authToken, recordId);
		}
		
		// Protected Methods
		protected override function onServiceFault(event:FaultEvent):void
		{
			sendNotification(Notifications.APPLICATION_FAILURE, serviceName + " failed!");
		}
		
		protected override function onServiceInvoke(event:InvokeEvent):void
		{
			sendNotification(Notifications.FETCHING_DATA, "Calling " + serviceName + "...");
		}
		
		protected override function registerServiceOperations():void
		{
			service.getTraceAlignment.addEventListener(ResultEvent.RESULT, onTraceAlignmentServiceGetTraceAlignmentResult);
		}
		
		// Private Methods
		private function onTraceAlignmentServiceGetTraceAlignmentResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch trace alignment!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateTraceAlignment(event.result as TraceAlignment);
		}
		
		private function updateTraceAlignment(traceAlignment:TraceAlignment):void
		{
			_traceAlignment = traceAlignment as TraceAlignment;
			
			sendNotification(Notifications.TRACE_ALIGNMENT_FETCHED);
			
			Logger.getInstance().info("Trace alignment fetched successfully");
		}
	}
}
