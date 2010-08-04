package org.jbei.registry.mediators
{
    import flash.events.MouseEvent;
    
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.results.ResultsPanel;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ResultsPanelMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "ResultsPanelMediator";
        
        private var resultsPanel:ResultsPanel;
        
        // Constructor
        public function ResultsPanelMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            resultsPanel = viewComponent as ResultsPanel;
            ApplicationFacade.getInstance().registerMediator(new ResultsMenuMediator(resultsPanel.resultsMenu));
            ApplicationFacade.getInstance().registerMediator(new ResultsControlBarMediator(resultsPanel.resultsControlBar));
            ApplicationFacade.getInstance().registerMediator(new ResultsContentPanelMediator(resultsPanel.resultsContentPanel));
            ApplicationFacade.getInstance().registerMediator(new ResultsStatusBarMediator(resultsPanel.resultsStatusBar));
        }
    }
}