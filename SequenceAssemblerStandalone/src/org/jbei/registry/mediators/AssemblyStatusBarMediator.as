package org.jbei.registry.mediators
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.assembly.AssemblyStatusBar;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyStatusBarMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "AssemblyStatusBarMediator";
        private static const ACTION_MESSAGE_DELAY_TIME:int = 8000;
        
        private var assemblyStatusBar:AssemblyStatusBar;
        private var timer:Timer;
        
        // Constructor
        public function AssemblyStatusBarMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            assemblyStatusBar = viewComponent as AssemblyStatusBar;
            
            createTimer();
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.ASSEMBLY_ACTION_MESSAGE:
                    updateActionMessage(notification.getBody() as String);
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [Notifications.ASSEMBLY_ACTION_MESSAGE];
        }
        
        // Event Handlers
        private function onActionMessageTimerComplete(event:TimerEvent):void
        {
            assemblyStatusBar.statusLabel.text = "";
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
            
            assemblyStatusBar.statusLabel.text = message;
        }
    }
}