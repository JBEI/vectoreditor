package org.jbei.registry.mediators
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.utils.StringUtil;
	
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.bio.tools.TemperatureCalculator;
	import org.jbei.lib.utils.StringFormatter;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.ui.StatusBar;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class StatusBarMediator extends Mediator
	{
		private static const ACTION_MESSAGE_DELAY_TIME:int = 8000;
        private const NAME:String = "StatusBarMediator";
		
		private var statusBar:StatusBar;
        private var timer:Timer = new Timer(ACTION_MESSAGE_DELAY_TIME, 1);
		
		// Constructor
		public function StatusBarMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			statusBar = viewComponent as StatusBar;
            
            timer = new Timer(ACTION_MESSAGE_DELAY_TIME, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onActionMessageTimerComplete);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [Notifications.SELECTION_CHANGED
				, Notifications.CARET_POSITION_CHANGED
				
                , Notifications.ENTRY_PERMISSIONS_CHANGED
				, Notifications.SEQUENCE_PROVIDER_CHANGED
                
                , Notifications.ACTION_MESSAGE
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.SELECTION_CHANGED:
					var selectionPositions:Array = notification.getBody() as Array;
					
					if(selectionPositions.length != 2 || !ApplicationFacade.getInstance().sequenceProvider) {
                        statusBar.selectionPositionLabel.text = '- : -'
                        statusBar.temperatureLabel.text = "";
                        
                        return;
                    }
					
					var start:int = selectionPositions[0] as int;
					var end:int = selectionPositions[1] as int;
					
                    // update positions
					if(start > -1 && end > -1 && start != end) {
						var selectionLength:int;
						if (start < end) {
							selectionLength = end - start;
						} else {
							selectionLength = end + ApplicationFacade.getInstance().sequenceProvider.sequence.length - start;
						}
						
						statusBar.selectionPositionLabel.text = String(start + 1) + " : " + String(end) + " (" + String(selectionLength) + ")";
                        statusBar.temperatureLabel.text = StringFormatter.sprintf('%.2f', String(TemperatureCalculator.calculateTemperature(new DNASequence(ApplicationFacade.getInstance().sequenceProvider.subSequence(start, end))))) + "°C";
					} else {
						statusBar.selectionPositionLabel.text = '- : -';
                        statusBar.temperatureLabel.text = "";
					}
					
					break;
				case Notifications.CARET_POSITION_CHANGED:
					var caretPosition:int = notification.getBody() as int;
					if(caretPosition > -1) {
						statusBar.caretPositionLabel.text = String(caretPosition);
					} else {
						statusBar.caretPositionLabel.text = "  ";
					}
					
					break;
				/*case Notifications.ENTRY_PERMISSIONS_CHANGED:
					statusBar.sequenceStatusLabel.text = ApplicationFacade.getInstance().hasWritablePermissions ? "Writable" : "Read Only";
					
					break;*/
				case Notifications.SEQUENCE_PROVIDER_CHANGED:
					if(ApplicationFacade.getInstance().sequenceProvider) {
						statusBar.sequenceLengthLabel.text = String(ApplicationFacade.getInstance().sequenceProvider.sequence.length);
					} else {
						statusBar.sequenceLengthLabel.text = "-";
					}
					
					break;
                case Notifications.ACTION_MESSAGE:
                    updateActionMessage(notification.getBody() as String);
                    
                    break;
			}
		}
        
        // Event Handlers
        private function onActionMessageTimerComplete(event:TimerEvent):void
        {
            statusBar.actionMessageLabel.text = "";
        }
        
        // Private Methods
        private function updateActionMessage(message:String):void
        {
            timer.reset();
            timer.start();
            
            statusBar.actionMessageLabel.text = message;
        }
	}
}
