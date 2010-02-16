package org.jbei.registry.mediators
{
	import flash.events.Event;
	
	import org.jbei.registry.Notifications;
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
			return [Notifications.SHOW_FIND_PANEL
				, Notifications.HIDE_FIND_PANEL
				, Notifications.FIND_MATCH_FOUND
				, Notifications.FIND_MATCH_NOT_FOUND
				, Notifications.FEATURED_SEQUENCE_CHANGED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.SHOW_FIND_PANEL:
					findPanel.show();
					
					break;
				case Notifications.HIDE_FIND_PANEL:
					findPanel.hide();
					sendNotification(Notifications.CLEAR_HIGHLIGHT);
					
					break;
				case Notifications.FIND_MATCH_FOUND:
					findPanel.highlightFindBox(true);
					
					break;
				case Notifications.FIND_MATCH_NOT_FOUND:
					findPanel.highlightFindBox(false);
					
					break;
				case Notifications.FEATURED_SEQUENCE_CHANGED:
					findPanel.updateHighlight();
					
					break;
			}
		}
		
		// Private Methods
		private function onFind(event:Event):void
		{
			sendNotification(Notifications.FIND, [findPanel.findExpression, findPanel.dataType, findPanel.searchType]);
		}
		
		private function onFindNext(event:Event):void
		{
			sendNotification(Notifications.FIND_NEXT, [findPanel.findExpression, findPanel.dataType, findPanel.searchType]);
		}
		
		private function onHighlight(event:Event):void
		{
			sendNotification(Notifications.HIGHLIGHT, [findPanel.findExpression, findPanel.dataType, findPanel.searchType]);
		}
		
		private function onClearHighlight(event:Event):void
		{
			sendNotification(Notifications.CLEAR_HIGHLIGHT);
		}
		
		private function onHideFindPanel(event:Event):void
		{
			sendNotification(Notifications.HIDE_FIND_PANEL);
		}
	}
}
