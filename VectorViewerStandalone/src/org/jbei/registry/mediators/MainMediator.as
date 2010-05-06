package org.jbei.registry.mediators
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.RestrictionEnzyme;
	import org.jbei.bio.data.RestrictionEnzymeGroup;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.lib.mappers.ORFMapper;
	import org.jbei.lib.mappers.RestrictionEnzymeMapper;
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.Plasmid;
	import org.jbei.registry.utils.FeaturedDNASequenceUtils;
	import org.jbei.registry.utils.RestrictionEnzymesUtils;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class MainMediator extends Mediator
	{
		private const NAME:String = "MainMediator";
		
		// Constructor
		public function MainMediator(viewComponent:Object=null)
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
					
					sendNotification(Notifications.LOAD_SEQUENCE);
					
					if(ApplicationFacade.getInstance().featuredSequence.circular) {
						sendNotification(Notifications.SHOW_PIE);
					} else {
						sendNotification(Notifications.SHOW_RAIL);
					}
					
					ApplicationFacade.getInstance().sequenceInitialized = true;
					
					break;
			}
		}
		
		// Private Methods
		private function sequenceFetched():void
		{
			var featuredSequence:FeaturedSequence = FeaturedDNASequenceUtils.featuredDNASequenceToFeaturedSequence(ApplicationFacade.getInstance().sequence, ApplicationFacade.getInstance().entry.combinedName(), ((ApplicationFacade.getInstance().entry is Plasmid) ? (ApplicationFacade.getInstance().entry as Plasmid).circular : false));
			
			var orfMapper:ORFMapper = new ORFMapper(featuredSequence);
			
			var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
			
			var commonRestrictionEnzymes:ArrayCollection = RestrictionEnzymesUtils.commonRestrictionEnzymes();
			for(var i:int = 0; i < commonRestrictionEnzymes.length; i++) {
				restrictionEnzymeGroup.addRestrictionEnzyme(commonRestrictionEnzymes.getItemAt(i) as RestrictionEnzyme);
			}
			
			var reMapper:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(featuredSequence, restrictionEnzymeGroup);
			
			featuredSequence.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_INITIALIZED));
			
			ApplicationFacade.getInstance().featuredSequence = featuredSequence;
			ApplicationFacade.getInstance().orfMapper = orfMapper;
			ApplicationFacade.getInstance().restrictionEnzymeMapper = reMapper;
		}
	}		
}
