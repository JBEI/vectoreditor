package org.jbei.registry.mediators
{
    import org.jbei.lib.ui.menu.MenuItemEvent;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.results.ResultsMenu;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ResultsMenuMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "ResultsMenuMediator";
        
        private var resultsMenu:ResultsMenu;
        
        // Constructor
        public function ResultsMenuMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            resultsMenu = viewComponent as ResultsMenu;
            
            resultsMenu.addEventListener(ResultsMenu.BACK_TO_ASSEMBLY, onBackToAssembly);
            resultsMenu.addEventListener(ResultsMenu.COPY, onCopy);
            resultsMenu.addEventListener(ResultsMenu.SHOW_ABOUT_DIALOG, onShowAboutDialog);
            resultsMenu.addEventListener(ResultsMenu.GO_SUGGEST_FEATURE_WEB_LINK, onGoSuggestFeatureWebLink);
            resultsMenu.addEventListener(ResultsMenu.GO_REPORT_BUG_WEB_LINK, onGoReportBugWebLink);
        }
        
        // Event Handlers
        private function onBackToAssembly(event:MenuItemEvent):void
        {
            sendNotification(Notifications.SWITCH_TO_ASSEMBLY_VIEW);
        }
        
        private function onCopy(event:MenuItemEvent):void
        {
            sendNotification(Notifications.RESULTS_COPY);
        }
        
        private function onShowAboutDialog(event:MenuItemEvent):void
        {
            sendNotification(Notifications.SHOW_ABOUT_DIALOG);
        }
        
        private function onGoSuggestFeatureWebLink(event:MenuItemEvent):void
        {
            sendNotification(Notifications.GO_SUGGEST_FEATURE);
        }
        
        private function onGoReportBugWebLink(event:MenuItemEvent):void
        {
            sendNotification(Notifications.GO_REPORT_BUG);
        }
    }
}