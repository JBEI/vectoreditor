package org.jbei.registry.model
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.jbei.registry.Notifications;
	import org.jbei.registry.model.vo.Plasmid;
	import org.jbei.registry.utils.StandaloneUtils;
	import org.jbei.utils.Logger;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class EntriesProxy extends Proxy
	{
		public static const NAME:String = "EntriesProxy";
		private static const ENTRIES_SERVICE_NAME:String = "EntriesService";
		
		private var _plasmid:Plasmid;
		private var entriesService:RemoteObject;
		
		// Constructor
		public function EntriesProxy()
		{
			super(NAME);
			
			entriesService = new RemoteObject(ENTRIES_SERVICE_NAME);
			entriesService.addEventListener(FaultEvent.FAULT, onEntriesServiceFault);
			entriesService.addEventListener(InvokeEvent.INVOKE, onEntriesServiceInvoke);
			entriesService.getPlasmid.addEventListener(ResultEvent.RESULT, onEntriesServiceGetPlasmidResult);
		}
		
		// Properties
		public function get plasmid():Plasmid
		{
			return _plasmid;
		}
		
		// Public Methods
		public function fetchPlasmid(recordId:String):void
		{
			CONFIG::standalone {
				fetchStandalonePlasmid();
				return;
			}
			
			entriesService.getPlasmid(recordId);
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
		
		private function onEntriesServiceGetPlasmidResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch entry!");
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updatePlasmid(event.result as Plasmid);
		}
		
		private function fetchStandalonePlasmid():void
		{
			updatePlasmid(StandaloneUtils.standalonePlasmid());
		}
		
		private function updatePlasmid(plasmid:Plasmid):void
		{
			_plasmid = plasmid;
			
			sendNotification(Notifications.ENTRY_FETCHED);
			
			Logger.getInstance().info("Plasmid fetched successfully");
		}
	}
}
