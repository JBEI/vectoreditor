package org.jbei.registry.mediators
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
			return [Notifications.FETCHING_DATA
				, Notifications.DATA_FETCHED
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
			}
		}
	}
}
