package org.jbei.registry.mediators
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.TraceSequence;
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
				
				, Notifications.ENTRY_FETCHED
				, Notifications.SEQUENCE_FETCHED
				, Notifications.TRACES_FETCHED
				
				, Notifications.TRACE_SEQUENCE_SELECTION_CHANGED
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
				case Notifications.ENTRY_FETCHED:
					sendNotification(Notifications.FETCH_SEQUENCE);
					
					break;
				case Notifications.SEQUENCE_FETCHED:
					ApplicationFacade.getInstance().sequenceFetched();
					
					sendNotification(Notifications.FETCH_TRACES);
					
					break;
				case Notifications.TRACES_FETCHED:
					ApplicationFacade.getInstance().tracesFetched();
					
					break;
				case Notifications.TRACE_SEQUENCE_SELECTION_CHANGED:
					if(notification.getBody() != null) {
						var traceSequence:TraceSequence = notification.getBody() as TraceSequence;
						
						if(traceSequence.traceSequenceAlignment != null) {
							ApplicationFacade.getInstance().activeSequenceComponent.select(traceSequence.traceSequenceAlignment.queryStart - 1, traceSequence.traceSequenceAlignment.queryEnd - 1); // -1 because our sequence starts from 0
						}
					}
					
					break;
			}
		}
	}
}
