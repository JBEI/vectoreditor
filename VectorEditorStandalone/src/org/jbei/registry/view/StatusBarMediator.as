package org.jbei.registry.view
{
	import org.jbei.ApplicationFacade;
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
			return [ApplicationFacade.SELECTION_CHANGED
				, ApplicationFacade.CARET_POSITION_CHANGED
				
				, ApplicationFacade.FETCHING_DATA
				, ApplicationFacade.DATA_FETCHED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case ApplicationFacade.SELECTION_CHANGED:
					var selectionPositions:Array = notification.getBody() as Array;
					
					if(selectionPositions[0] > -1 && selectionPositions[1] > -1) {
						statusBar.selectionPositionLabel.text = String(selectionPositions[0] + 1) + " : " + String(selectionPositions[1] + 1);
					} else {
						statusBar.selectionPositionLabel.text = '- : -';
					}
					
					break;
				case ApplicationFacade.CARET_POSITION_CHANGED:
					var caretPosition:int = notification.getBody() as int;
					if(caretPosition > -1) {
						statusBar.caretPositionLabel.text = String(caretPosition);
					} else {
						statusBar.caretPositionLabel.text = "  ";
					}
					
					break;
				case ApplicationFacade.FETCHING_DATA:
					statusBar.statusLabel.text = notification.getBody() as String;
					break;
				case ApplicationFacade.DATA_FETCHED:
					statusBar.statusLabel.text = "Done";
					break;
			}
		}
	}
}
