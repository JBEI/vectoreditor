package org.jbei.registry.mediators
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.jbei.components.common.SequenceUtils;
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
	import org.jbei.registry.proxies.RegistryAPIProxy;
	import org.jbei.registry.utils.FeaturedDNASequenceUtils;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class MainMediator extends Mediator
	{
		private const NAME:String = "MainMediator";
        
        private var fileReference:FileReference;
        private var saveSequenceContent:String;
		
		// Constructor
		public function MainMediator()
		{
			super(NAME);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array
		{
			return [
				Notifications.USER_PREFERENCES_FETCHED
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
                
                , Notifications.IMPORT_SEQUENCE_FILE
                , Notifications.EXPORT_SEQUENCE_FILE
                , Notifications.SEQUENCE_GENERATED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.APPLICATION_FAILURE:
					ApplicationFacade.getInstance().application.disableApplication(notification.getBody() as String);
					
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
                case Notifications.IMPORT_SEQUENCE_FILE:
                    fileReference = new FileReference();
                    fileReference.addEventListener(Event.SELECT, onImportSequenceSelect);
                    fileReference.addEventListener(Event.COMPLETE, onImportSequenceComplete);
                    fileReference.addEventListener(IOErrorEvent.IO_ERROR, onImportIOSequenceError);
                    fileReference.browse();
                    
                    break;
                case Notifications.EXPORT_SEQUENCE_FILE:
                    (ApplicationFacade.getInstance().retrieveProxy(RegistryAPIProxy.PROXY_NAME) as RegistryAPIProxy).generateSequenceFile(FeaturedDNASequenceUtils.sequenceProviderToFeaturedDNASequence(ApplicationFacade.getInstance().sequenceProvider));
                    
                    break;
                case Notifications.SEQUENCE_GENERATED:
                    saveSequenceContent = notification.getBody() as String;
                    
                    if(saveSequenceContent == null) {
                        return;
                    }
                    
                    Alert.show("Sequence was generated successfully. Press OK button to save it", "Save sequence", Alert.OK | Alert.CANCEL, ApplicationFacade.getInstance().application, onAlertClose);
                    
                    break;
			}
		}
		
        // Event Handlers
        private function onImportSequenceSelect(event:Event):void
        {
            fileReference.load();
        }
        
        private function onImportSequenceComplete(event:Event):void
        {
            if(fileReference.data == null) {
                showFailedToUploadMessage();
                
                return;
            }
            
            (ApplicationFacade.getInstance().retrieveProxy(RegistryAPIProxy.PROXY_NAME) as RegistryAPIProxy).parseSequenceFile(fileReference.data.toString());
        }
        
        private function onImportIOSequenceError(event:Event):void
        {
            showFailedToUploadMessage();
        }
        
        private function onExportSequenceComplete(event:Event):void
        {
            sendNotification(Notifications.ACTION_MESSAGE, "File saved successfully");
        }
        
        private function onExportIOSequenceError(event:Event):void
        {
            Alert.show("Failed to write file!", "Write file error");
        }
        
        private function onAlertClose(event:CloseEvent):void
        {
            if(event.detail == Alert.OK) {
                fileReference = new FileReference();
                fileReference.addEventListener(IOErrorEvent.IO_ERROR, onExportIOSequenceError);
                fileReference.addEventListener(Event.COMPLETE, onExportSequenceComplete);
                fileReference.save(saveSequenceContent);
            }
        }
        
        private function onSequenceProviderChanged(event:SequenceProviderEvent):void
        {
            sendNotification(Notifications.SEQUENCE_PROVIDER_CHANGED, event.data, event.kind);
        }
        
        // Private Methods
        private function sequenceFetched():void
		{
            var sequenceProvider:SequenceProvider;
            
            CONFIG::toolEdition {
                sequenceProvider = FeaturedDNASequenceUtils.featuredDNASequenceToSequenceProvider(ApplicationFacade.getInstance().sequence, (fileReference == null) ? "" : fileReference.name, true);
            }
            
            CONFIG::registryEdition {
                sequenceProvider = FeaturedDNASequenceUtils.featuredDNASequenceToSequenceProvider(ApplicationFacade.getInstance().sequence, ApplicationFacade.getInstance().entry.combinedName(), ((ApplicationFacade.getInstance().entry is Plasmid) ? (ApplicationFacade.getInstance().entry as Plasmid).circular : false));
            }
            
            CONFIG::standalone {
                sequenceProvider = FeaturedDNASequenceUtils.featuredDNASequenceToSequenceProvider(ApplicationFacade.getInstance().sequence, ApplicationFacade.getInstance().entry.combinedName(), ((ApplicationFacade.getInstance().entry is Plasmid) ? (ApplicationFacade.getInstance().entry as Plasmid).circular : false));
            }
            
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
        
        private function showFailedToUploadMessage():void
        {
            Alert.show("Failed to read file!", "Open file error");
        }
	}
}
