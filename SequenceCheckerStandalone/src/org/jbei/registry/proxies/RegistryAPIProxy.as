package org.jbei.registry.proxies
{
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.utils.StandaloneUtils;

	public class RegistryAPIProxy extends AbstractServiceProxy
	{
		public static const REMOTE_SERVICE_NAME:String = "RegistryAMFAPI";
		public static const PROXY_NAME:String = "RegistryAPIProxy";
		
		// Constructor
		public function RegistryAPIProxy()
		{
			super(PROXY_NAME, REMOTE_SERVICE_NAME);
		}
		
		// Public Methods
		public function fetchEntry(sessionId:String, entryId:String):void
		{
			CONFIG::standalone {
				updateEntry(StandaloneUtils.standaloneEntry() as Entry);
				
				return;
			}
			
			service.getEntry(sessionId, entryId);
		}
		
		public function fetchSequence(sessionId:String, entryId:String):void
		{
			CONFIG::standalone {
				updateSequence(StandaloneUtils.standaloneSequence() as FeaturedDNASequence);
				
				return;
			}
			
			service.getSequence(sessionId, entryId);
		}
		
		public function fetchTraces(sessionId:String, entryId:String):void
		{
			CONFIG::standalone {
				updateTraces(StandaloneUtils.standaloneTraces() as ArrayCollection);
				
				return;
			}
			
			service.getTraces(sessionId, entryId);
		}
		
		// Protected Methods
		protected override function onServiceFault(event:FaultEvent):void
		{
			sendNotification(Notifications.APPLICATION_FAILURE, "Service call failed!\n" + event.fault.faultString);
		}
		
		protected override function registerServiceOperations():void
		{
			// Entry
			service.getEntry.addEventListener(ResultEvent.RESULT, onGetEntryResult);
			
			// Sequence
			service.getSequence.addEventListener(ResultEvent.RESULT, onGetSequenceResult);
			
			// Traces
			service.getTraces.addEventListener(ResultEvent.RESULT, onGetTracesResult);
		}
		
		// Private Methods: Response handlers
		private function onGetEntryResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch entry! Invalid response result type!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateEntry(event.result as Entry);
		}
		
		private function onGetSequenceResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch sequence! Invalid response result type!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateSequence(event.result as FeaturedDNASequence);
		}
		
		private function onGetTracesResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch traces!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateTraces(event.result as ArrayCollection);
		}
		
		// Private Methods
		private function updateEntry(entry:Entry):void
		{
			sendNotification(Notifications.ENTRY_FETCHED, entry);
			
			Logger.getInstance().info("Entry fetched successfully");
		}
		
		private function updateSequence(featuredDNASequence:FeaturedDNASequence):void
		{
			sendNotification(Notifications.SEQUENCE_FETCHED, featuredDNASequence);
			
			Logger.getInstance().info("Sequence fetched successfully");
		}
		
		private function updateTraces(traces:ArrayCollection):void
		{
			sendNotification(Notifications.TRACES_FETCHED, traces);
			
			Logger.getInstance().info("Traces fetched successfully");
		}
	}
}
