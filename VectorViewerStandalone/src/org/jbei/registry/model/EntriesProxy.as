package org.jbei.registry.model
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.jbei.registry.Notifications;
	import org.jbei.registry.model.vo.Entry;
	import org.jbei.registry.utils.StandaloneUtils;
	import org.jbei.lib.utils.Logger;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class EntriesProxy extends Proxy
	{
		public static const NAME:String = "EntriesProxy";
		private static const ENTRIES_SERVICE_NAME:String = "EntriesService";
		
		private var _entry:Entry;
		private var entriesService:RemoteObject;
		
		// Constructor
		public function EntriesProxy()
		{
			super(NAME);
			
			entriesService = new RemoteObject(ENTRIES_SERVICE_NAME);
			entriesService.addEventListener(FaultEvent.FAULT, onEntriesServiceFault);
			entriesService.addEventListener(InvokeEvent.INVOKE, onEntriesServiceInvoke);
			entriesService.getEntry.addEventListener(ResultEvent.RESULT, onEntriesServiceGetEntryResult);
		}
		
		// Properties
		public function get entry():Entry
		{
			return _entry;
		}
		
		// Public Methods
		public function fetchEntry(authToken:String, recordId:String):void
		{
			CONFIG::standalone {
				fetchStandaloneEntry();
				return;
			}
			
			entriesService.getEntry(authToken, recordId);
		}
		
		// Private Methods
		private function onEntriesServiceFault(event:FaultEvent):void
		{
			sendNotification(Notifications.APPLICATION_FAILURE, "EntriesService failed!");
		}
		
		private function onEntriesServiceInvoke(event:InvokeEvent):void
		{
			sendNotification(Notifications.FETCHING_DATA, "Loading Entry...");
		}
		
		private function onEntriesServiceGetEntryResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch entry!");
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateEntry(event.result as Entry);
		}
		
		private function fetchStandaloneEntry():void
		{
			updateEntry(StandaloneUtils.standaloneEntry() as Entry);
		}
		
		private function updateEntry(entry:Entry):void
		{
			_entry = entry as Entry;
			
			sendNotification(Notifications.ENTRY_FETCHED);
			
			Logger.getInstance().info("Entry fetched successfully");
		}
	}
}
