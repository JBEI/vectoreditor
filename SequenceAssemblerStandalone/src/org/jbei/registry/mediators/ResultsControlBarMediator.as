package org.jbei.registry.mediators
{
    import flash.events.MouseEvent;
    
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.results.ResultsControlBar;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ResultsControlBarMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "ResultsControlBarMediator";
        
        private var resultsControlBar:ResultsControlBar;
        
        // Constructor
        public function ResultsControlBarMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            resultsControlBar = viewComponent as ResultsControlBar;
            
            resultsControlBar.backToAssemblyButton.addEventListener(MouseEvent.CLICK, onBackToAssemblyButtonMouseClick);
            resultsControlBar.copyButton.addEventListener(MouseEvent.CLICK, onCopyButtonMouseClick);
        }
        
        // Event Handlers
        private function onBackToAssemblyButtonMouseClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SWITCH_TO_ASSEMBLY_VIEW);
        }
        
        private function onCopyButtonMouseClick(event:MouseEvent):void
        {
            sendNotification(Notifications.RESULTS_COPY);
        }
    }
}