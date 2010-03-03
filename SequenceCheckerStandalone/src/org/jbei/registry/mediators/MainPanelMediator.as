package org.jbei.registry.mediators
{
	import org.jbei.components.Pie;
	import org.jbei.components.Rail;
	import org.jbei.components.SequenceAnnotator;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.ui.MainPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class MainPanelMediator extends Mediator
	{
		private const NAME:String = "MainPanelMediator"
		
		// Constructor
		public function MainPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			ApplicationFacade.getInstance().initializeControls(viewComponent as MainPanel);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [
				  Notifications.SHOW_RAIL
				, Notifications.SHOW_PIE
				
				, Notifications.SHOW_FEATURES
				
				//, Notifications.ENTRY_FETCHED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.SHOW_RAIL:
					ApplicationFacade.getInstance().showRail();
					
					break;
				case Notifications.SHOW_PIE:
					ApplicationFacade.getInstance().showPie();
					
					break;
				case Notifications.SHOW_FEATURES:
					ApplicationFacade.getInstance().displayFeatures(notification.getBody() as Boolean);
					
					break;
				/*case Notifications.ENTRY_FETCHED:
					ApplicationFacade.getInstance().entryFetched();
					
					break;*/
			}
		}
	}
}
