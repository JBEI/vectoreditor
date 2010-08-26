package org.jbei.registry.mediators
{
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.TraceSequence;
    import org.jbei.registry.view.ui.MainStatusBar;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class MainStatusBarMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "MainStatusBarMediator";
        
        private static const ACTION_MESSAGE_DELAY_TIME:int = 8000;
        
        private var mainStatusBar:MainStatusBar;
        private var timer:Timer;
        
        // Constructor
        public function MainStatusBarMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            mainStatusBar = viewComponent as MainStatusBar;
            
            createTimer();
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.SELECTION_CHANGED:
                    var selectionPositions:Array = notification.getBody() as Array;
                    
                    if(selectionPositions.length != 2 || !ApplicationFacade.getInstance().sequenceProvider) { 
                        mainStatusBar.selectionPositionLabel.text = "- : -";
                        
                        return; 
                    }
                    
                    updateSelection(selectionPositions[0], selectionPositions[1]);
                    
                    break;
                case Notifications.ACTION_MESSAGE:
                    updateActionMessage(notification.getBody() as String);
                    
                    break;
                case Notifications.CARET_POSITION_CHANGED:
                    updateCaretPosition(notification.getBody() as int);
                    
                    break;
                case Notifications.PROJECT_UPDATED:
                    var seqLength:int = (ApplicationFacade.getInstance().sequenceProvider && ApplicationFacade.getInstance().sequenceProvider.sequence) ? ApplicationFacade.getInstance().sequenceProvider.sequence.length : -1;
                    
                    updateSequenceLength(seqLength);
                    
                    break;
                case Notifications.SELECTED_TRACE_SEQUENCE_CHANGED:
                    updateSelectedTrace(notification.getBody() as TraceSequence);
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [
                Notifications.CARET_POSITION_CHANGED
                , Notifications.SELECTION_CHANGED
                , Notifications.PROJECT_UPDATED
                , Notifications.SELECTED_TRACE_SEQUENCE_CHANGED
                , Notifications.ACTION_MESSAGE
            ];
        }
        
        // Event Handlers
        private function onActionMessageTimerComplete(event:TimerEvent):void
        {
            mainStatusBar.actionMessageLabel.text = "";
        }
        
        // Private Methods
        private function updateCaretPosition(newPosition:int):void
        {
            if(newPosition > -1) {
                mainStatusBar.caretPositionLabel.text = String(newPosition);
            } else {
                mainStatusBar.caretPositionLabel.text = "  ";
            }
        }
        
        private function updateSelection(fromIndex:int, toIndex:int):void
        {
            if(fromIndex > -1 && toIndex > -1 && fromIndex != toIndex) {
                var selectionLength:int;
                
                if (fromIndex < toIndex) {
                    selectionLength = toIndex - fromIndex;
                } else {
                    selectionLength = toIndex + ApplicationFacade.getInstance().sequenceProvider.sequence.length - fromIndex;
                }
                
                mainStatusBar.selectionPositionLabel.text = String(fromIndex + 1) + " : " + String(toIndex) + " (" + String(selectionLength) + ")";
            } else {
                mainStatusBar.selectionPositionLabel.text = '- : -';
            }
        }
        
        private function updateSequenceLength(length:int):void
        {
            if(length >= 0) {
                mainStatusBar.sequenceLengthLabel.text = String(length);   
            } else {
                mainStatusBar.sequenceLengthLabel.text = "";
            }
        }
        
        private function updateSelectedTrace(traceSequence:TraceSequence):void
        {
            if(!traceSequence) {
                return;
            }
            
            mainStatusBar.selectedTraceLabel.text = traceSequence.filename;
        }
        
        private function createTimer():void
        {
            timer = new Timer(ACTION_MESSAGE_DELAY_TIME, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onActionMessageTimerComplete);
        }
        
        private function updateActionMessage(message:String):void
        {
            timer.reset();
            timer.start();
            
            mainStatusBar.actionMessageLabel.text = message;
        }
    }
}