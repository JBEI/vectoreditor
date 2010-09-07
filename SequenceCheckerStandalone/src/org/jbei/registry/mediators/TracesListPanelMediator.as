package org.jbei.registry.mediators
{
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.TraceSequence;
	import org.jbei.registry.view.ui.TracesListPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class TracesListPanelMediator extends Mediator
	{
		private const NAME:String = "TracesListPanelMediator";
		
		private var tracesListPanel:TracesListPanel;
		private var traces:ArrayCollection; /* TraceSequence */
		
		// Constructor
		public function TracesListPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			tracesListPanel = viewComponent as TracesListPanel;
			
			tracesListPanel.tracesDataGrid.addEventListener(ListEvent.CHANGE, onTracesDataGridChange);
            tracesListPanel.tracesDataGrid.addEventListener(FlexEvent.DATA_CHANGE, onDataChange);
        }
		private function onDataChange(event:FlexEvent):void
        {
            ApplicationFacade.getInstance().updateVisibleTraces();
        }
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [
				Notifications.TRACES_FETCHED
				, Notifications.SELECTION_CHANGED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.TRACES_FETCHED:
					populateDataGrid();
					
					break;
				case Notifications.SELECTION_CHANGED:
					if(notification.getBody() != null) {
						var selection:Array = notification.getBody() as Array;
						
						for(var i:int = 0; i < traces.length; i++) {
							var traceSequence:TraceSequence = (traces[i] as TraceSequence);
							
							if(traceSequence.traceSequenceAlignment == null) {
								continue;
							}
							
							if(selection[0] == traceSequence.traceSequenceAlignment.queryStart - 1 && selection[1] == traceSequence.traceSequenceAlignment.queryEnd) {
								if(tracesListPanel.tracesDataGrid.selectedIndex != i) {
									tracesListPanel.tracesDataGrid.selectedIndex = i;
									
									sendNotification(Notifications.TRACE_SEQUENCE_SELECTION_CHANGED, traceSequence);
								}
								
								break;
							}
						}
					}
					
					break;
			}
		}
		
		// Private Methods
		private function populateDataGrid():void {
			traces = ApplicationFacade.getInstance().traces;
			
            tracesListPanel.tracesDataGrid.dataProvider = ApplicationFacade.getInstance().visibleTracesCollection;
		}
		
        private function onTracesDataGridChange(event:ListEvent):void {
			sendNotification(Notifications.TRACE_SEQUENCE_SELECTION_CHANGED, ((event.itemRenderer.data == null) ? null : (event.itemRenderer.data.traceData as TraceSequence)));
		}
	}
}