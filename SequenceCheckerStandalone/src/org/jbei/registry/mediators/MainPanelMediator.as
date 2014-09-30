package org.jbei.registry.mediators
{
	import org.jbei.components.Pie;
	import org.jbei.components.Rail;
	import org.jbei.components.common.CaretEvent;
	import org.jbei.components.common.SelectionEvent;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
    import org.jbei.registry.models.TraceSequenceAnalysis;
    import org.jbei.registry.view.ui.MainPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

    /**
     * @author Zinovii Dmytriv
     */
	public class MainPanelMediator extends Mediator
	{
		private const NAME:String = "MainPanelMediator"
		
		private var pie:Pie;
		private var rail:Rail;
		private var mainPanel:MainPanel;
		private var controlsInitialized:Boolean = false;
		
		// Constructor
		public function MainPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			initializeControls(viewComponent as MainPanel);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [
				  Notifications.SHOW_RAIL
				, Notifications.SHOW_PIE
				
				, Notifications.SHOW_FEATURES
				
				, Notifications.LOAD_SEQUENCE
				
				, Notifications.TRACE_SEQUENCE_SELECTION_CHANGED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.LOAD_SEQUENCE:
					loadSequence();
					
					break;
				case Notifications.SHOW_RAIL:
					showRail();
					
					break;
				case Notifications.SHOW_PIE:
					showPie();
					
					break;
				case Notifications.SHOW_FEATURES:
					displayFeatures(notification.getBody() as Boolean);
					
					break;
				case Notifications.TRACE_SEQUENCE_SELECTION_CHANGED:
					if(notification.getBody() != null) {
						var traceSequence:TraceSequenceAnalysis = notification.getBody() as TraceSequenceAnalysis;
						
						if(traceSequence.traceSequenceAlignment != null) {
							var start:int = traceSequence.traceSequenceAlignment.queryStart - 1; // -1 because our sequence starts from 0
							var end:int = traceSequence.traceSequenceAlignment.queryEnd - 1; // -1 because our sequence starts from 0
							
							pie.select(start, end);
							rail.select(start, end);
						}
					}
					
					break;
			}
		}
		
		// Private Methods
		private function initializeControls(mainPanel:MainPanel):void
		{
			if(! controlsInitialized) {
				this.mainPanel = mainPanel;
				
				pie = mainPanel.pie;
				rail = mainPanel.rail;
				
				initializeEventHandlers();
				
				controlsInitialized = true;
			}
		}
		
		private function showPie():void
		{
			pie.visible = true;
			pie.includeInLayout = true;
			pie.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
			
			rail.visible = false;
			rail.includeInLayout = false;
			rail.sequenceProvider = null;
		}
		
		private function showRail():void
		{
			pie.visible = false;
			pie.includeInLayout = false;
			pie.sequenceProvider = null;
			
			rail.visible = true;
			rail.includeInLayout = true;
			rail.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
		}
		
		private function displayFeatures(showFeatures:Boolean):void
		{
			pie.showFeatures = showFeatures;
			rail.showFeatures = showFeatures;
		}
		
		private function initializeEventHandlers():void
		{
			pie.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
			rail.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
			
			pie.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
			rail.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
		}
		
		private function onSelectionChanged(event:SelectionEvent):void
		{
			sendNotification(Notifications.SELECTION_CHANGED, [event.start, event.end]);
		}
		
		private function onCaretPositionChanged(event:CaretEvent):void
		{
			sendNotification(Notifications.CARET_POSITION_CHANGED, event.position);
		}
		
		private function loadSequence():void
		{
			pie.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
			rail.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
			
			pie.traceMapper = ApplicationFacade.getInstance().traceMapper;
			rail.traceMapper = ApplicationFacade.getInstance().traceMapper;
		}
	}
}
