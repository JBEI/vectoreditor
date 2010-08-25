package org.jbei.registry.mediators
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.FileReference;
    import flash.net.FileReferenceList;
    import flash.utils.ByteArray;
    
    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    
    import org.jbei.lib.ui.dialogs.ModalDialog;
    import org.jbei.lib.ui.dialogs.ModalDialogEvent;
    import org.jbei.lib.ui.dialogs.SimpleDialog;
    import org.jbei.lib.utils.Logger;
    import org.jbei.lib.utils.LoggerEvent;
    import org.jbei.lib.utils.SystemUtils;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Constants;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.SequenceCheckerProject;
    import org.jbei.registry.models.TraceData;
    import org.jbei.registry.view.dialogs.AboutDialogForm;
    import org.jbei.registry.view.dialogs.PropertiesDialogForm;
    import org.jbei.registry.view.ui.ApplicationPanel;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ApplicationMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "ApplicationMediator";
        
        private var applicationPanel:ApplicationPanel;
        private var importSequenceFileReference:FileReference;
        private var importTraceFileReferenceList:FileReferenceList;
        private var traceFilesToParse:ArrayCollection = new ArrayCollection();
        private var numberOfTraceFilesToParse:int;
        
        // Constructor
        public function ApplicationMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            Logger.getInstance().addEventListener(LoggerEvent.LOG, onLogMessage);
            
            applicationPanel = viewComponent as ApplicationPanel;
            
            var applicationFacade:ApplicationFacade = ApplicationFacade.getInstance();
            
            applicationFacade.registerMediator(new MainMenuMediator(applicationPanel.mainPanel.mainMenu));
            applicationFacade.registerMediator(new MainControlBarMediator(applicationPanel.mainPanel.mainControlBar));
            applicationFacade.registerMediator(new MainContentPanelMediator(applicationPanel.mainPanel.mainContentPanel));
            applicationFacade.registerMediator(new MainStatusBarMediator(applicationPanel.mainPanel.mainStatusBar));
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.APPLICATION_FAILURE:
                    var failureMessage:String = notification.getBody() as String;
                    
                    lockApplication(failureMessage);
                    
                    Alert.show(failureMessage, "Application Failure");
                    
                    break;
                case Notifications.ACTION_MESSAGE:
                    logActionMessage(notification.getBody() as String);
                    
                    break;
                case Notifications.LOCK:
                    lockApplication(notification.getBody() as String);
                    
                    break;
                case Notifications.UNLOCK:
                    unlockApplication();
                    
                    break;
                case Notifications.SHOW_ACTION_PROGRESSBAR:
                    showActionProgressBar(notification.getBody() as String);
                    
                    break;
                case Notifications.HIDE_ACTION_PROGRESSBAR:
                    hideActionProgressBar();
                    
                    break;
                case Notifications.SHOW_ABOUT_DIALOG:
                    showAboutDialog();
                    
                    break;
                case Notifications.GO_SUGGEST_FEATURE:
                    goSuggestFeature();
                    
                    break;
                case Notifications.GO_REPORT_BUG:
                    goReportBug();
                    
                    break;
                case Notifications.SHOW_PROPERTIES_DIALOG:
                    showPropertiesDialog();
                    
                    break;
                case Notifications.SAVE_PROJECT:
                    saveProject();
                    
                    break;
                case Notifications.SAVE_AS_PROJECT:
                    saveAsProject();
                    
                    break;
                case Notifications.IMPORT_SEQUENCE:
                    importSequence();
                    
                    break;
                case Notifications.IMPORT_TRACE:
                    importTrace();
                    
                    break;
                case Notifications.REMOVE_TRACE:
                    removeTrace(notification.getBody() as int);
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [
                Notifications.ACTION_MESSAGE
                , Notifications.LOCK
                , Notifications.UNLOCK
                , Notifications.SHOW_ACTION_PROGRESSBAR
                , Notifications.HIDE_ACTION_PROGRESSBAR
                , Notifications.APPLICATION_FAILURE
                , Notifications.SAVE_PROJECT
                , Notifications.SAVE_AS_PROJECT
                , Notifications.SHOW_PROPERTIES_DIALOG
                , Notifications.SHOW_ABOUT_DIALOG
                , Notifications.IMPORT_SEQUENCE
                , Notifications.IMPORT_TRACE
                , Notifications.REMOVE_TRACE
                , Notifications.GO_SUGGEST_FEATURE
                , Notifications.GO_REPORT_BUG
            ];
        }
        
        // Event Handlers
        private function onLogMessage(event:LoggerEvent):void
        {
            applicationPanel.loggerTextArea.text += event.message + "\n";
        }
        
        private function onCreateProjectPropertiesDialogSubmit(event:ModalDialogEvent):void
        {
            ApplicationFacade.getInstance().createProject();
        }
        
        private function onPropertiesDialogSubmit(event:ModalDialogEvent):void
        {
            if(ApplicationFacade.getInstance().project.uuid != null && ApplicationFacade.getInstance().project.uuid != "") {
                ApplicationFacade.getInstance().saveProject();
            } else {
                ApplicationFacade.getInstance().createProject();
            }
        }
        
        private function onImportSequenceFileReferenceSelect(event:Event):void
        {
            importSequenceFileReference.load();
        }
        
        private function onImportSequenceFileReferenceComplete(event:Event):void
        {
            if(importSequenceFileReference.data == null) {
                showFileImportErrorAlert("Empty file!");
                
                return;
            }
            
            ApplicationFacade.getInstance().importSequence(importSequenceFileReference.data.toString());
        }
        
        private function onImportTraceFileReferenceLoadError(event:IOErrorEvent):void
        {
            showFileImportErrorAlert(event.text);
        }
        
        private function onImportTraceFileReferenceSelect(event:Event):void
        {
            if(!importTraceFileReferenceList.fileList || importTraceFileReferenceList.fileList.length == 0) {
                return;
            }
            
            numberOfTraceFilesToParse = importTraceFileReferenceList.fileList.length;
            
            for(var i:int = 0; i < importTraceFileReferenceList.fileList.length; i++) {
                var fileReference:FileReference = importTraceFileReferenceList.fileList[i] as FileReference;
                
                fileReference.addEventListener(Event.COMPLETE, onImportTraceFileReferenceComplete);
                
                fileReference.load();
            }
        }
        
        private function onImportTraceFileReferenceComplete(event:Event):void
        {
            if(!event.currentTarget || !(event.currentTarget as FileReference).data) {
                showFileImportErrorAlert("Empty file!");
                
                return;
            }
            
            var fileReference:FileReference = event.currentTarget as FileReference;
            
            traceFilesToParse.addItem({filename : fileReference.name, data : fileReference.data});
            
            numberOfTraceFilesToParse--;
            
            if(numberOfTraceFilesToParse == 0) {
                parseTraceFiles();
            }
        }
        
        private function onImportSequenceFileReferenceLoadError(event:IOErrorEvent):void
        {
            showFileImportErrorAlert(event.text);
        }
        
        // Private Methods
        private function logActionMessage(message:String):void
        {
            Logger.getInstance().info(message);
        }
        
        private function lockApplication(lockMessage:String = ""):void
        {
            applicationPanel.mainPanel.enabled = false;
            
            sendNotification(Notifications.SHOW_ACTION_PROGRESSBAR, lockMessage);
            
            if(lockMessage != null && lockMessage != "") {
                sendNotification(Notifications.ACTION_MESSAGE, lockMessage);
            }
        }
        
        private function unlockApplication():void
        {
            applicationPanel.mainPanel.enabled = true;
            
            sendNotification(Notifications.HIDE_ACTION_PROGRESSBAR);
        }
        
        private function showActionProgressBar(message:String = ""):void
        {
            applicationPanel.actionProgressBar.visible = true;
            applicationPanel.actionProgressBar.label = message;
            applicationPanel.actionProgressBar.x = applicationPanel.width / 2 - applicationPanel.actionProgressBar.width / 2;
            applicationPanel.actionProgressBar.y = applicationPanel.height / 2 - applicationPanel.actionProgressBar.height / 2;
        }
        
        private function hideActionProgressBar():void
        {
            applicationPanel.actionProgressBar.visible = false;
        }
        
        private function showAboutDialog():void
        {
            var aboutDialog:SimpleDialog = new SimpleDialog(AboutDialogForm);
            aboutDialog.title = Constants.APPLICATION_NAME;
            aboutDialog.open();
        }
        
        private function showPropertiesDialog():void
        {
            var propertiesDialog:ModalDialog = new ModalDialog(PropertiesDialogForm, ApplicationFacade.getInstance().project);
            propertiesDialog.title = "Properties";
            propertiesDialog.addEventListener(ModalDialogEvent.SUBMIT, onPropertiesDialogSubmit);
            propertiesDialog.open();
        }
        
        private function goSuggestFeature():void
        {
            SystemUtils.goToUrl(Constants.SUGGEST_FEATURE_URL);
        }
        
        private function goReportBug():void
        {
            SystemUtils.goToUrl(Constants.REPORT_BUG_URL);
        }
        
        private function saveProject():void
        {
            var project:SequenceCheckerProject = ApplicationFacade.getInstance().project;
            
            if(project.uuid == null || project.uuid == "") { // project not saved
                var createProjectPropertiesDialog:ModalDialog = new ModalDialog(PropertiesDialogForm, project);
                createProjectPropertiesDialog.title = "Save Project";
                createProjectPropertiesDialog.addEventListener(ModalDialogEvent.SUBMIT, onCreateProjectPropertiesDialogSubmit);
                createProjectPropertiesDialog.open();
            } else { // project was saved before
                ApplicationFacade.getInstance().saveProject();
            }
        }
        
        private function saveAsProject():void
        {
            var project:SequenceCheckerProject = ApplicationFacade.getInstance().project;
            
            var createProjectPropertiesDialog:ModalDialog = new ModalDialog(PropertiesDialogForm, project);
            createProjectPropertiesDialog.title = "Save As ...";
            createProjectPropertiesDialog.addEventListener(ModalDialogEvent.SUBMIT, onCreateProjectPropertiesDialogSubmit);
            createProjectPropertiesDialog.open();
        }
        
        private function importSequence():void
        {
            importSequenceFileReference = new FileReference();
            importSequenceFileReference.addEventListener(Event.SELECT, onImportSequenceFileReferenceSelect);
            importSequenceFileReference.addEventListener(Event.COMPLETE, onImportSequenceFileReferenceComplete);
            importSequenceFileReference.addEventListener(IOErrorEvent.IO_ERROR, onImportSequenceFileReferenceLoadError);
            importSequenceFileReference.browse();
        }
        
        private function showFileImportErrorAlert(message:String):void
        {
            Alert.show("Failed to open file!", message);
        }
        
        private function importTrace():void
        {
            importTraceFileReferenceList = new FileReferenceList();
            importTraceFileReferenceList.addEventListener(Event.SELECT, onImportTraceFileReferenceSelect);
            importTraceFileReferenceList.addEventListener(IOErrorEvent.IO_ERROR, onImportTraceFileReferenceLoadError);
            importTraceFileReferenceList.browse();
        }
        
        private function removeTrace(index:int):void
        {
            var traceData:TraceData = ApplicationFacade.getInstance().getTraceByIndex(index);
            
            if(traceData) {
                ApplicationFacade.getInstance().removeTrace(traceData);
            }
        }
        
        private function parseTraceFiles():void
        {
            if(!traceFilesToParse || traceFilesToParse.length == 0) {
                return;
            }
            
            ApplicationFacade.getInstance().startTraceFilesParsing(traceFilesToParse.length);
            
            try {
                for(var i:int = 0; i < traceFilesToParse.length; i++) {
                    ApplicationFacade.getInstance().parseTraceFile(traceFilesToParse.getItemAt(i).filename as String, traceFilesToParse.getItemAt(i).data as ByteArray);
                }
            } finally {
                traceFilesToParse.removeAll();
            }
        }
    }
}