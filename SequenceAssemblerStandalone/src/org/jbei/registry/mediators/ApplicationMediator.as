package org.jbei.registry.mediators
{
    import mx.containers.VBox;
    import mx.controls.Alert;
    
    import org.jbei.components.AssemblyTable;
    import org.jbei.lib.ui.dialogs.ModalDialog;
    import org.jbei.lib.ui.dialogs.ModalDialogEvent;
    import org.jbei.lib.ui.dialogs.SimpleDialog;
    import org.jbei.lib.utils.Logger;
    import org.jbei.lib.utils.SystemUtils;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Constants;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.lib.AssemblyHelper;
    import org.jbei.registry.models.AssemblyProject;
    import org.jbei.registry.proxies.RegistryAPIProxy;
    import org.jbei.registry.utils.AssemblyTableUtils;
    import org.jbei.registry.view.ui.MainPanel;
    import org.jbei.registry.view.ui.assembly.AssemblyPanel;
    import org.jbei.registry.view.ui.dialogs.AboutDialogForm;
    import org.jbei.registry.view.ui.dialogs.PropertiesDialogForm;
    import org.jbei.registry.view.ui.results.ResultsPanel;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ApplicationMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "ApplicationMediator";
        
        private var mainPanel:MainPanel;
        private var resultsPanel:ResultsPanel;
        private var assemblyPanel:AssemblyPanel;
        
        private var activeViewPanel:VBox;
        
        // Constructor
        public function ApplicationMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            mainPanel = viewComponent as MainPanel;
            
            assemblyPanel = mainPanel.assemblyPanel;
            resultsPanel = mainPanel.resultsPanel;
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
                case Notifications.GLOBAL_ACTION_MESSAGE:
                    logActionMessage(notification.getBody() as String);
                    
                    break;
                case Notifications.ASSEMBLY_ACTION_MESSAGE:
                    logActionMessage(notification.getBody() as String);
                    
                    break;
                case Notifications.RESULTS_ACTION_MESSAGE:
                    logActionMessage(notification.getBody() as String);
                    
                    break;
                case Notifications.LOCK:
                    lockApplication(notification.getBody() as String);
                    
                    break;
                case Notifications.UNLOCK:
                    unlockApplication();
                    
                    break;
                case Notifications.SWITCH_TO_ASSEMBLY_VIEW:
                    switchToAssemblyView();
                    
                    break;
                case Notifications.SWITCH_TO_RESULTS_VIEW:
                    switchToResultsView();
                    
                    break;
                case Notifications.RUN_ASSEMBLY:
                    runAssembly();
                    
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
                case Notifications.ASSEMBLY_UNDO:
                    undoAssembly();
                    
                    break;
                case Notifications.ASSEMBLY_REDO:
                    redoAssembly();
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [
                Notifications.SAVE_PROJECT
                , Notifications.SAVE_AS_PROJECT
                , Notifications.LOCK
                , Notifications.UNLOCK
                , Notifications.APPLICATION_FAILURE
                , Notifications.GLOBAL_ACTION_MESSAGE
                , Notifications.ASSEMBLY_ACTION_MESSAGE
                , Notifications.RESULTS_ACTION_MESSAGE
                , Notifications.SWITCH_TO_ASSEMBLY_VIEW
                , Notifications.SWITCH_TO_RESULTS_VIEW
                , Notifications.RUN_ASSEMBLY
                , Notifications.SHOW_ABOUT_DIALOG
                , Notifications.GO_SUGGEST_FEATURE
                , Notifications.GO_REPORT_BUG
                , Notifications.SHOW_PROPERTIES_DIALOG
                , Notifications.ASSEMBLY_UNDO
                , Notifications.ASSEMBLY_REDO
            ];
        }
        
        // Event Handlers
        private function onCreateProjectPropertiesDialogSubmit(event:ModalDialogEvent):void
        {
            ApplicationFacade.getInstance().project.assemblyTable = AssemblyTableUtils.assemblyProviderToAssemblyTable(ApplicationFacade.getInstance().assemblyProvider);
            
            var proxy:RegistryAPIProxy = ApplicationFacade.getInstance().retrieveProxy(RegistryAPIProxy.PROXY_NAME) as RegistryAPIProxy;
            
            proxy.createAssemblyProject(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().project);
        }
        
        private function onPropertiesDialogSubmit(event:ModalDialogEvent):void
        {
            ApplicationFacade.getInstance().project.assemblyTable = AssemblyTableUtils.assemblyProviderToAssemblyTable(ApplicationFacade.getInstance().assemblyProvider);
            
            var proxy:RegistryAPIProxy = ApplicationFacade.getInstance().retrieveProxy(RegistryAPIProxy.PROXY_NAME) as RegistryAPIProxy;
            
            if(ApplicationFacade.getInstance().project.uuid != null && ApplicationFacade.getInstance().project.uuid != "") {
                proxy.saveAssemblyProject(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().project);
            } else {
                proxy.createAssemblyProject(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().project);
            }
        }
        
        // Private Methods
        private function logActionMessage(message:String):void
        {
            Logger.getInstance().info(message);
        }
        
        private function lockApplication(lockMessage:String = ""):void
        {
            mainPanel.enabled = false;
            
            if(lockMessage != null && lockMessage != "") {
                sendNotification(Notifications.GLOBAL_ACTION_MESSAGE, lockMessage);
            }
        }
        
        private function unlockApplication():void
        {
            mainPanel.enabled = true;
        }
        
        private function switchToAssemblyView():void
        {
            if(activeViewPanel == assemblyPanel) {
                return;
            }
            
            activeViewPanel = assemblyPanel;
            
            assemblyPanel.visible = true;
            assemblyPanel.includeInLayout = true;
            
            resultsPanel.visible = false;
            resultsPanel.includeInLayout = false;
        }
        
        private function switchToResultsView():void
        {
            if(activeViewPanel == resultsPanel) {
                return;
            }
            
            activeViewPanel = resultsPanel;
            
            assemblyPanel.visible = false;
            assemblyPanel.includeInLayout = false;
            
            resultsPanel.visible = true;
            resultsPanel.includeInLayout = true;
        }
        
        private function runAssembly():void
        {
            if(!ApplicationFacade.getInstance().assemblyProvider) {
                return;
            }
            
            ApplicationFacade.getInstance().resultPermutations = AssemblyHelper.buildPermutationSet(ApplicationFacade.getInstance().assemblyProvider);
            
            if(ApplicationFacade.getInstance().resultPermutations) {
                sendNotification(Notifications.UPDATE_RESULTS_PERMUTATIONS_TABLE);
                sendNotification(Notifications.SWITCH_TO_RESULTS_VIEW);
            }
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
            var project:AssemblyProject = ApplicationFacade.getInstance().project;
            
            if(project.uuid == null || project.uuid == "") { // project not saved
                var createProjectPropertiesDialog:ModalDialog = new ModalDialog(PropertiesDialogForm, project);
                createProjectPropertiesDialog.title = "Save Project";
                createProjectPropertiesDialog.addEventListener(ModalDialogEvent.SUBMIT, onCreateProjectPropertiesDialogSubmit);
                createProjectPropertiesDialog.open();
            } else { // project was saved
                var proxy:RegistryAPIProxy = ApplicationFacade.getInstance().retrieveProxy(RegistryAPIProxy.PROXY_NAME) as RegistryAPIProxy;
                
                proxy.saveAssemblyProject(ApplicationFacade.getInstance().sessionId, project);
            }
        }
        
        private function saveAsProject():void
        {
            var project:AssemblyProject = ApplicationFacade.getInstance().project;
            
            var createProjectPropertiesDialog:ModalDialog = new ModalDialog(PropertiesDialogForm, project);
            createProjectPropertiesDialog.title = "Save As ...";
            createProjectPropertiesDialog.addEventListener(ModalDialogEvent.SUBMIT, onCreateProjectPropertiesDialogSubmit);
            createProjectPropertiesDialog.open();
        }
        
        private function undoAssembly():void
        {
            ApplicationFacade.getInstance().actionStack.undo();
        }
        
        private function redoAssembly():void
        {
            ApplicationFacade.getInstance().actionStack.redo();
        }
    }
}