package org.jbei.registry.view
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ApplicationMediator extends Mediator
	{
		private const NAME:String = "ApplicationMediator";
		
		// Constructor
		public function ApplicationMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array
		{
			return [Notifications.USER_PREFERENCES_FETCHED
				, Notifications.USER_RESTRICTION_ENZYMES_FETCHED
				, Notifications.APPLICATION_FAILURE
				
				, Notifications.DATA_FETCHED
				, Notifications.FETCHING_DATA
				
				, Notifications.UNDO
				, Notifications.REDO];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.APPLICATION_FAILURE:
					ApplicationFacade.getInstance().application.disableApplication(notification.getBody() as String);
					
					break;
				case Notifications.USER_PREFERENCES_FETCHED:
					sendNotification(Notifications.FETCH_USER_RESTRICTION_ENZYMES);
					
					break;
				case Notifications.USER_RESTRICTION_ENZYMES_FETCHED:
					sendNotification(Notifications.FETCH_ENTRY);
					
					break;
				case Notifications.UNDO:
					ApplicationFacade.getInstance().actionStack.undo();
					
					break;
				case Notifications.REDO:
					ApplicationFacade.getInstance().actionStack.redo();
					
					break;
				case Notifications.FETCHING_DATA:
					ApplicationFacade.getInstance().application.lock();
					
					break;
				case Notifications.DATA_FETCHED:
					ApplicationFacade.getInstance().application.unlock();
					
					break;
			}
		}
	}
}
