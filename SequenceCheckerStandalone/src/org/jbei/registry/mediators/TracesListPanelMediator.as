package org.jbei.registry.mediators
{
	import mx.collections.ArrayCollection;
	import mx.events.ListEvent;
	
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.TraceSequence;
	import org.jbei.registry.view.ui.TracesListPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class TracesListPanelMediator extends Mediator
	{
		private const NAME:String = "TracesListPanelMediator";
		
		private var tracesListPanel:TracesListPanel;
		
		// Constructor
		public function TracesListPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			tracesListPanel = viewComponent as TracesListPanel;
			
			tracesListPanel.tracesDataGrid.addEventListener(ListEvent.CHANGE, onTracesDataGridChange);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [
				Notifications.TRACES_FETCHED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.TRACES_FETCHED:
					populateDataGrid();
					
					break;
			}
		}
		
		// Private Methods
		private function populateDataGrid():void {
			var traces:ArrayCollection = ApplicationFacade.getInstance().traces;
			
			tracesListPanel.tracesDataGrid.dataProvider = null;
			
			if(traces != null && traces.length > 0) {
				tracesListPanel.tracesDataGrid.dataProvider = traces;
			}
		}
		
		private function onTracesDataGridChange(event:ListEvent):void {
			sendNotification(Notifications.TRACE_SEQUENCE_SELECTION_CHANGED, ((event.itemRenderer.data == null) ? null : (event.itemRenderer.data as TraceSequence)));
		}
	}
}
