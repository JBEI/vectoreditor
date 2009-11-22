package org.jbei.registry.view
{
	import org.jbei.ApplicationFacade;
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
			return [ApplicationFacade.USER_PREFERENCES_FETCHED
				, ApplicationFacade.USER_RESTRICTION_ENZYMES_FETCHED
				, ApplicationFacade.APPLICATION_FAILURE
				
				, ApplicationFacade.DATA_FETCHED
				, ApplicationFacade.FETCHING_DATA
				
				, ApplicationFacade.UNDO
				, ApplicationFacade.REDO];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case ApplicationFacade.APPLICATION_FAILURE:
					ApplicationFacade.getInstance().application.disableApplication(notification.getBody() as String);
					
					break;
				case ApplicationFacade.USER_PREFERENCES_FETCHED:
					sendNotification(ApplicationFacade.FETCH_USER_RESTRICTION_ENZYMES);
					
					break;
				case ApplicationFacade.USER_RESTRICTION_ENZYMES_FETCHED:
					sendNotification(ApplicationFacade.FETCH_ENTRY);
					
					break;
				case ApplicationFacade.UNDO:
					ApplicationFacade.getInstance().actionStack.undo();
					
					break;
				case ApplicationFacade.REDO:
					ApplicationFacade.getInstance().actionStack.redo();
					
					break;
				case ApplicationFacade.FETCHING_DATA:
					ApplicationFacade.getInstance().application.lock();
					
					break;
				case ApplicationFacade.DATA_FETCHED:
					ApplicationFacade.getInstance().application.unlock();
					
					break;
			}
		}
	}
}
