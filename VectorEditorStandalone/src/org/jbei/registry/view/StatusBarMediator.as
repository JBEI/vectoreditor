package org.jbei.registry.view
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.ui.StatusBar;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
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
			return [Notifications.SELECTION_CHANGED
				, Notifications.CARET_POSITION_CHANGED
				
				, Notifications.FETCHING_DATA
				, Notifications.DATA_FETCHED
				, Notifications.FEATURED_SEQUENCE_CHANGED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.SELECTION_CHANGED:
					var selectionPositions:Array = notification.getBody() as Array;
					
					if(selectionPositions.length != 2 || !ApplicationFacade.getInstance().featuredSequence) { return; }
					
					var start:int = selectionPositions[0] as int;
					var end:int = selectionPositions[1] as int;
					
					if(start > -1 && end > -1 && start != end) {
						var selectionLength:int;
						if (start < end) {
							selectionLength = end - start;
						} else {
							selectionLength = end + ApplicationFacade.getInstance().featuredSequence.sequence.length - start;
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
				case Notifications.FETCHING_DATA:
					statusBar.statusLabel.text = notification.getBody() as String;
					break;
				case Notifications.DATA_FETCHED:
					statusBar.statusLabel.text = "Done";
					break;
				case Notifications.FEATURED_SEQUENCE_CHANGED:
					if(ApplicationFacade.getInstance().featuredSequence) {
						statusBar.sequenceLengthLabel.text = String(ApplicationFacade.getInstance().featuredSequence.sequence.length);
					} else {
						statusBar.sequenceLengthLabel.text = "-";
					}
					
					break;
			}
		}
	}
}
