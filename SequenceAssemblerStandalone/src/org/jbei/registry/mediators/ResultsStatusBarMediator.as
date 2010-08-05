package org.jbei.registry.mediators
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.results.ResultsStatusBar;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ResultsStatusBarMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "ResultsStatusBarMediator";
        
        private static const ACTION_MESSAGE_DELAY_TIME:int = 8000;
        
        private var timer:Timer;
        private var resultsStatusBar:ResultsStatusBar;
        
        // Constructor
        public function ResultsStatusBarMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            resultsStatusBar = viewComponent as ResultsStatusBar;
            
            createTimer();
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.RESULTS_ACTION_MESSAGE:
                    updateActionMessage(notification.getBody() as String);
                    
                    break;
                case Notifications.GLOBAL_ACTION_MESSAGE:
                    updateActionMessage(notification.getBody() as String);
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [
                Notifications.RESULTS_ACTION_MESSAGE
                , Notifications.GLOBAL_ACTION_MESSAGE
            ];
        }
        
        // Event Handlers
        private function onActionMessageTimerComplete(event:TimerEvent):void
        {
            resultsStatusBar.statusLabel.text = "";
        }
        
        // Private Methods
        private function createTimer():void
        {
            timer = new Timer(ACTION_MESSAGE_DELAY_TIME, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onActionMessageTimerComplete);
        }
        
        private function updateActionMessage(message:String):void
        {
            timer.reset();
            timer.start();
            
            resultsStatusBar.statusLabel.text = message;
        }
    }
}