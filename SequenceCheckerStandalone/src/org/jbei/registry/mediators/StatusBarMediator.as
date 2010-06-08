package org.jbei.registry.mediators
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.TraceSequence;
	import org.jbei.registry.view.ui.StatusBar;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class StatusBarMediator extends Mediator
	{
		private const NAME:String = "StatusBarMediator";
		
		private var statusBar:StatusBar;
		
		// Constructor
		public function StatusBarMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			statusBar = viewComponent as StatusBar;
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [Notifications.FETCHING_DATA
				, Notifications.DATA_FETCHED
				
				, Notifications.TRACE_SEQUENCE_SELECTION_CHANGED
				
				, Notifications.SELECTION_CHANGED
				, Notifications.CARET_POSITION_CHANGED
				, Notifications.SEQUENCE_PROVIDER_CHANGED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.FETCHING_DATA:
					statusBar.statusLabel.text = notification.getBody() as String;
					
					break;
				case Notifications.DATA_FETCHED:
					statusBar.statusLabel.text = "Done";
					
					break;
				case Notifications.TRACE_SEQUENCE_SELECTION_CHANGED:
					if(notification.getBody() == null) {
						statusBar.statusLabel.text = "";
					} else {
						statusBar.statusLabel.text = (notification.getBody() as TraceSequence).filename;
					}
					
					break;
				case Notifications.SELECTION_CHANGED:
					var selectionPositions:Array = notification.getBody() as Array;
					
					if(selectionPositions.length != 2 || !ApplicationFacade.getInstance().sequenceProvider) { return; }
					
					var start:int = selectionPositions[0] as int;
					var end:int = selectionPositions[1] as int;
					
					if(start > -1 && end > -1 && start != end) {
						var selectionLength:int;
						if (start < end) {
							selectionLength = end - start;
						} else {
							selectionLength = end + ApplicationFacade.getInstance().sequenceProvider.sequence.length - start;
						}
						
						statusBar.selectionPositionLabel.text = String(start + 1) + " : " + String(end) + " (" + String(selectionLength) + ")";
					} else {
						statusBar.selectionPositionLabel.text = '- : -';
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
				case Notifications.SEQUENCE_PROVIDER_CHANGED:
					if(ApplicationFacade.getInstance().sequenceProvider) {
						statusBar.sequenceLengthLabel.text = String(ApplicationFacade.getInstance().sequenceProvider.sequence.length);
					} else {
						statusBar.sequenceLengthLabel.text = "-";
					}
					
					break;
			}
		}
	}
}
