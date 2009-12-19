package org.jbei.registry.view
{
	import flash.events.Event;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.registry.view.ui.FindPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class FindPanelMediator extends Mediator
	{
		private const NAME:String = "FindPanelMediator"
		
		private var findPanel:FindPanel;
		
		// Constructor
		public function FindPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			findPanel = viewComponent as FindPanel;
			
			findPanel.addEventListener(FindPanel.FIND, onFind);
			findPanel.addEventListener(FindPanel.FIND_NEXT, onFindNext);
			findPanel.addEventListener(FindPanel.HIGHLIGHT, onHighlight);
			findPanel.addEventListener(FindPanel.CLEAR_HIGHLIGHT, onClearHighlight);
			findPanel.addEventListener(FindPanel.HIDE_FIND_PANEL, onHideFindPanel);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [ApplicationFacade.SHOW_FIND_PANEL
				, ApplicationFacade.HIDE_FIND_PANEL
				, ApplicationFacade.FIND_MATCH_FOUND
				, ApplicationFacade.FIND_MATCH_NOT_FOUND
				, ApplicationFacade.FEATURED_SEQUENCE_CHANGED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case ApplicationFacade.SHOW_FIND_PANEL:
					findPanel.show();
					
					break;
				case ApplicationFacade.HIDE_FIND_PANEL:
					findPanel.hide();
					sendNotification(ApplicationFacade.CLEAR_HIGHLIGHT);
					
					break;
				case ApplicationFacade.FIND_MATCH_FOUND:
					findPanel.highlightFindBox(true);
					
					break;
				case ApplicationFacade.FIND_MATCH_NOT_FOUND:
					findPanel.highlightFindBox(false);
					
					break;
				case ApplicationFacade.FEATURED_SEQUENCE_CHANGED:
					findPanel.updateHighlight();
					
					break;
			}
		}
		
		// Private Methods
		private function onFind(event:Event):void
		{
			sendNotification(ApplicationFacade.FIND, [findPanel.findExpression, findPanel.dataType, findPanel.searchType]);
		}
		
		private function onFindNext(event:Event):void
		{
			sendNotification(ApplicationFacade.FIND_NEXT, [findPanel.findExpression, findPanel.dataType, findPanel.searchType]);
		}
		
		private function onHighlight(event:Event):void
		{
			sendNotification(ApplicationFacade.HIGHLIGHT, [findPanel.findExpression, findPanel.dataType, findPanel.searchType]);
		}
		
		private function onClearHighlight(event:Event):void
		{
			sendNotification(ApplicationFacade.CLEAR_HIGHLIGHT);
		}
		
		private function onHideFindPanel(event:Event):void
		{
			sendNotification(ApplicationFacade.HIDE_FIND_PANEL);
		}
	}
}
