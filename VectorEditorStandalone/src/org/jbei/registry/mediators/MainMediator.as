package org.jbei.registry.mediators
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.lib.SequenceProvider;
	import org.jbei.lib.SequenceProviderEvent;
	import org.jbei.lib.data.RestrictionEnzymeGroup;
	import org.jbei.lib.mappers.AAMapper;
	import org.jbei.lib.mappers.ORFMapper;
	import org.jbei.lib.mappers.RestrictionEnzymeMapper;
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.Plasmid;
	import org.jbei.registry.models.UserPreferences;
	import org.jbei.registry.models.UserRestrictionEnzymes;
	import org.jbei.registry.utils.FeaturedDNASequenceUtils;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class MainMediator extends Mediator
	{
		private const NAME:String = "MainMediator";
		
		// Constructor
		public function MainMediator()
		{
			super(NAME);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array
		{
			return [
				Notifications.RESTRICTION_ENZYMES_FETCHED
				, Notifications.USER_PREFERENCES_FETCHED
				, Notifications.USER_RESTRICTION_ENZYMES_FETCHED
				, Notifications.APPLICATION_FAILURE
				, Notifications.ENTRY_FETCHED
				, Notifications.SEQUENCE_FETCHED
				, Notifications.SEQUENCE_PROVIDER_CHANGED
				, Notifications.ENTRY_PERMISSIONS_FETCHED
				, Notifications.SEQUENCE_SAVED
				
				, Notifications.DATA_FETCHED
				, Notifications.FETCHING_DATA
				
				, Notifications.UNDO
				, Notifications.REDO
                
                , Notifications.REVERSE_COMPLEMENT_SEQUENCE
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.APPLICATION_FAILURE:
					ApplicationFacade.getInstance().application.disableApplication(notification.getBody() as String);
					
					break;
				case Notifications.RESTRICTION_ENZYMES_FETCHED:
					ApplicationFacade.getInstance().loadRestrictionEnzymes(notification.getBody() as ArrayCollection /* of RestrictionEnzyme */);
					
					sendNotification(Notifications.FETCH_USER_PREFERENCES);
					
					break;
				case Notifications.USER_PREFERENCES_FETCHED:
					ApplicationFacade.getInstance().userPreferences = notification.getBody() as UserPreferences;
					
					sendNotification(Notifications.FETCH_USER_RESTRICTION_ENZYMES);
					
					break;
				case Notifications.USER_RESTRICTION_ENZYMES_FETCHED:
					ApplicationFacade.getInstance().loadUserRestrictionEnzymes(notification.getBody() as UserRestrictionEnzymes);
					
					sendNotification(Notifications.FETCH_ENTRY);
					
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
					var sequence:FeaturedDNASequence;
					
					if(notification.getBody() == null) {
						sequence = new FeaturedDNASequence("", new ArrayCollection());
					} else {
						sequence = notification.getBody() as FeaturedDNASequence;
					}
					
					ApplicationFacade.getInstance().sequence = sequence;
					
					sendNotification(Notifications.FETCH_ENTRY_PERMISSIONS);
					
					sequenceFetched();
					
					sendNotification(Notifications.LOAD_SEQUENCE);
					
					if(ApplicationFacade.getInstance().sequenceProvider.circular) {
						sendNotification(Notifications.SHOW_PIE);
					} else {
						sendNotification(Notifications.SHOW_RAIL);
					}
					
					// TODO: Do something with this
					sendNotification(Notifications.USER_PREFERENCES_CHANGED);
					
					ApplicationFacade.getInstance().sequenceInitialized = true;
					
					break;
				case Notifications.ENTRY_PERMISSIONS_FETCHED:
					ApplicationFacade.getInstance().isReadOnly = !(notification.getBody() as Boolean);
					
					break;
				case Notifications.UNDO:
					ApplicationFacade.getInstance().actionStack.undo();
					
					break;
				case Notifications.REDO:
					ApplicationFacade.getInstance().actionStack.redo();
					
					break;
				case Notifications.FETCHING_DATA:
					Logger.getInstance().info(notification.getBody() as String);
					
					ApplicationFacade.getInstance().application.lock();
					
					break;
				case Notifications.DATA_FETCHED:
					ApplicationFacade.getInstance().application.unlock();
					
					break;
				case Notifications.SEQUENCE_PROVIDER_CHANGED:
					if(ApplicationFacade.getInstance().sequenceInitialized) {
						ApplicationFacade.getInstance().updateBrowserSaveTitleState(false);
					}
					
					break;
				case Notifications.SEQUENCE_SAVED:
					ApplicationFacade.getInstance().updateBrowserSaveTitleState(true);
					
					break;
                case Notifications.REVERSE_COMPLEMENT_SEQUENCE:
                    ApplicationFacade.getInstance().sequenceProvider.reverseComplementSequence();
                    
                    break;
			}
		}
		
		private function sequenceFetched():void
		{
			var sequenceProvider:SequenceProvider = FeaturedDNASequenceUtils.featuredDNASequenceToSequenceProvider(ApplicationFacade.getInstance().sequence, ApplicationFacade.getInstance().entry.combinedName(), ((ApplicationFacade.getInstance().entry is Plasmid) ? (ApplicationFacade.getInstance().entry as Plasmid).circular : false));
            sequenceProvider.addEventListener(SequenceProviderEvent.SEQUENCE_CHANGED, onSequenceProviderChanged);
			
			var orfMapper:ORFMapper = new ORFMapper(sequenceProvider);
			
			var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
			for(var i:int = 0; i < RestrictionEnzymeGroupManager.instance.activeGroup.length; i++) {
				restrictionEnzymeGroup.addRestrictionEnzyme(RestrictionEnzymeGroupManager.instance.activeGroup[i]);
			}
			
			var reMapper:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(sequenceProvider, restrictionEnzymeGroup);
			
            sequenceProvider.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_INITIALIZED));
			
			var aaMapper:AAMapper = new AAMapper(sequenceProvider);
			
			ApplicationFacade.getInstance().sequenceProvider = sequenceProvider;
			ApplicationFacade.getInstance().orfMapper = orfMapper;
			ApplicationFacade.getInstance().restrictionEnzymeMapper = reMapper;
			ApplicationFacade.getInstance().aaMapper = aaMapper;
		}
		
		private function onSequenceProviderChanged(event:SequenceProviderEvent):void
		{
			sendNotification(Notifications.SEQUENCE_PROVIDER_CHANGED, event.data, event.kind);
		}
	}
}
