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
	import org.jbei.registry.models.FeaturedDNASequence;
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
                Notifications.SEQUENCE_PROVIDER_CHANGED
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
        
        // Private Methods
        private function showFailedToUploadMessage():void
        {
            Alert.show("Failed to read file!", "Open file error");
        }
	}
}
