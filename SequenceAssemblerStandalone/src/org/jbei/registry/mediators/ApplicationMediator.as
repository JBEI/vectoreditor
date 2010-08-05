package org.jbei.registry.mediators
{
    import mx.containers.VBox;
    
    import org.jbei.lib.ui.dialogs.SimpleDialog;
    import org.jbei.lib.utils.SystemUtils;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Constants;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.lib.AssemblyHelper;
    import org.jbei.registry.view.ui.MainPanel;
    import org.jbei.registry.view.ui.assembly.AssemblyPanel;
    import org.jbei.registry.view.ui.dialogs.AboutDialogForm;
    import org.jbei.registry.view.ui.results.ResultsPanel;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ApplicationMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "ApplicationMediator";
        
        private var resultsPanel:ResultsPanel;
        private var assemblyPanel:AssemblyPanel;
        
        private var activeViewPanel:VBox;
        
        // Constructor
        public function ApplicationMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            var mainPanel:MainPanel = viewComponent as MainPanel;
            
            assemblyPanel = mainPanel.assemblyPanel;
            resultsPanel = mainPanel.resultsPanel;
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
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
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [
                Notifications.SWITCH_TO_ASSEMBLY_VIEW
                , Notifications.SWITCH_TO_RESULTS_VIEW
                , Notifications.RUN_ASSEMBLY
                , Notifications.SHOW_ABOUT_DIALOG
                , Notifications.GO_SUGGEST_FEATURE
                , Notifications.GO_REPORT_BUG
            ];
        }
        
        // Private Methods
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
        
        private function goSuggestFeature():void
        {
            SystemUtils.goToUrl(Constants.SUGGEST_FEATURE_URL);
        }
        
        private function goReportBug():void
        {
            SystemUtils.goToUrl(Constants.REPORT_BUG_URL);
        }
    }
}