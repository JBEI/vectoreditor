package org.jbei.registry.mediators
{
	import mx.events.InvalidateRequestData;
	
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.proxies.MainServiceProxy;
	import org.jbei.registry.view.dialogs.properties.GenBankBox;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class GenbankPropertyTabMediator extends Mediator
	{
		public static const NAME:String = "GenbankPropertyTabMediator"
		
		// Constructor
		public function GenbankPropertyTabMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [
				Notifications.GENBANK_FETCHED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.GENBANK_FETCHED:
					var mainProxy:MainServiceProxy = ApplicationFacade.getInstance().retrieveProxy(MainServiceProxy.NAME) as MainServiceProxy;
					
					var genbankBox:GenBankBox = (viewComponent as GenBankBox);
					
					if(notification.getBody()) {
						genbankBox.updateTextArea(notification.getBody() as String);
					}
					
					break;
			}
		}
	}
}
