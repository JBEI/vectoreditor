package org.jbei.registry.proxies
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.Sequence;
	import org.jbei.registry.utils.StandaloneUtils;

	public class EntriesServiceProxy extends AbstractServiceProxy
	{
		public static const NAME:String = "EntriesServiceProxy";
		private static const ENTRIES_SERVICE_NAME:String = "EntriesService";
		
		private var _entry:Entry;
		private var _sequence:Sequence;
		
		// Constructor
		public function EntriesServiceProxy()
		{
			super(NAME, ENTRIES_SERVICE_NAME);
		}
		
		// Properties
		public function get entry():Entry
		{
			return _entry;
		}
		
		public function get sequence():Sequence
		{
			return _sequence;
		}
		
		// Public Methods
		public function fetchEntry(authToken:String, recordId:String):void
		{
			CONFIG::standalone {
				updateEntry(StandaloneUtils.standaloneEntry() as Entry);
				
				return;
			}
			
			service.getEntry(authToken, recordId);
		}
		
		public function fetchSequence(authToken:String, recordId:String):void
		{
			CONFIG::standalone {
				updateSequence(StandaloneUtils.standaloneSequence() as Sequence);
				
				return;
			}
			
			service.getSequence(authToken, recordId);
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
			service.getEntry.addEventListener(ResultEvent.RESULT, onEntriesServiceGetEntryResult);
			service.getSequence.addEventListener(ResultEvent.RESULT, onEntriesServiceGetSequenceResult);
		}
		
		// Private Methods
		private function onEntriesServiceGetEntryResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch entry!");
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateEntry(event.result as Entry);
		}
		
		private function onEntriesServiceGetSequenceResult(event:ResultEvent):void
		{
			sendNotification(Notifications.DATA_FETCHED);
			
			updateSequence(event.result == null ? null : event.result as Sequence);
		}
		
		private function updateEntry(entry:Entry):void
		{
			_entry = entry as Entry;
			
			sendNotification(Notifications.ENTRY_FETCHED);
			
			Logger.getInstance().info("Entry fetched successfully");
		}
		
		private function updateSequence(sequence:Sequence):void
		{
			_sequence = sequence as Sequence;
			
			sendNotification(Notifications.SEQUENCE_FETCHED);
			
			Logger.getInstance().info("Sequence fetched successfully");
		}
	}
}
