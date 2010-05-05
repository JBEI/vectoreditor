package org.jbei.registry.mediators
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.lib.mappers.TraceMapper;
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.Plasmid;
	import org.jbei.registry.utils.FeaturedDNASequenceUtils;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ApplicationMediator extends Mediator
	{
		private const NAME:String = "ApplicationMediator";
		
		// Constructor
		public function ApplicationMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array
		{
			return [Notifications.APPLICATION_FAILURE
				, Notifications.DATA_FETCHED
				, Notifications.FETCHING_DATA
				, Notifications.ENTRY_FETCHED
				, Notifications.SEQUENCE_FETCHED
				, Notifications.TRACES_FETCHED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.APPLICATION_FAILURE:
					ApplicationFacade.getInstance().application.disableApplication(notification.getBody() as String);
					
					break;
				case Notifications.FETCHING_DATA:
					Logger.getInstance().info(notification.getBody() as String);
					
					ApplicationFacade.getInstance().application.lock();
					
					break;
				case Notifications.DATA_FETCHED:
					ApplicationFacade.getInstance().application.unlock();
					
					break;
				case Notifications.ENTRY_FETCHED:
					var entry:Entry = notification.getBody() as Entry;
					
					if(!entry) {
						sendNotification(Notifications.APPLICATION_FAILURE, "Entry is null");
					}
					
					ApplicationFacade.getInstance().entry = entry;
					
					sendNotification(Notifications.FETCH_SEQUENCE);
					
					break;
				case Notifications.SEQUENCE_FETCHED:
					var sequence:FeaturedDNASequence = notification.getBody() as FeaturedDNASequence;
					
					if(!sequence) {
						sendNotification(Notifications.APPLICATION_FAILURE, "Sequence is null");
					}
					
					ApplicationFacade.getInstance().sequence = sequence;
					
					sequenceFetched();
					
					if(ApplicationFacade.getInstance().featuredSequence.circular) {
						sendNotification(Notifications.SHOW_PIE);
					} else {
						sendNotification(Notifications.SHOW_RAIL);
					}
					
					sendNotification(Notifications.FETCH_TRACES);
					
					break;
				case Notifications.TRACES_FETCHED:
					var traces:ArrayCollection = notification.getBody() as ArrayCollection /* TraceSequence */;
					
					ApplicationFacade.getInstance().traces = traces;
					
					tracesFetched();
					
					sendNotification(Notifications.LOAD_SEQUENCE);
					
					break;
			}
		}
		
		private function sequenceFetched():void
		{
			var featuredSequence:FeaturedSequence = FeaturedDNASequenceUtils.featuredDNASequenceToFeaturedSequence(ApplicationFacade.getInstance().sequence, ApplicationFacade.getInstance().entry.combinedName(), ((ApplicationFacade.getInstance().entry is Plasmid) ? (ApplicationFacade.getInstance().entry as Plasmid).circular : false));
			
			featuredSequence.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_INITIALIZED));
			
			ApplicationFacade.getInstance().featuredSequence = featuredSequence;
		}
		
		public function tracesFetched():void
		{
			var traceMapper:TraceMapper = new TraceMapper(ApplicationFacade.getInstance().featuredSequence, ApplicationFacade.getInstance().traces);
			
			ApplicationFacade.getInstance().traceMapper = traceMapper;
		}
	}
}
