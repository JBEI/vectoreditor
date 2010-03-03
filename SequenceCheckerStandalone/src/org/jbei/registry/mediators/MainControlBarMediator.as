package org.jbei.registry.mediators
{
	import flash.events.Event;
	
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.ui.MainControlBar;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class MainControlBarMediator extends Mediator
	{
		private const NAME:String = "MainControlBarMediator";
		
		private var controlBar:MainControlBar;
		
		// Constructor
		public function MainControlBarMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			controlBar = viewComponent as MainControlBar;
			
			controlBar.addEventListener(MainControlBar.SHOW_RAIL_VIEW, onShowRailView);
			controlBar.addEventListener(MainControlBar.SHOW_PIE_VIEW, onShowPieView);
			controlBar.addEventListener(MainControlBar.SHOW_FEATURES_STATE_CHANGED, onShowFeaturesStateChanged);
		}
		
		public override function listNotificationInterests():Array 
		{
			return [Notifications.SHOW_RAIL
				, Notifications.SHOW_PIE
				, Notifications.SHOW_FEATURES
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.SHOW_PIE:
					controlBar.viewToggleButtonBar.selectedIndex = 0;
					break;
				case Notifications.SHOW_RAIL:
					controlBar.viewToggleButtonBar.selectedIndex = 1;
					break;
				case Notifications.SHOW_FEATURES:
					controlBar.showFeaturesButton.selected = (notification.getBody() as Boolean);
					break;
			}
		}
		
		// Private Methods
		private function onShowFeaturesStateChanged(event:Event):void
		{
			sendNotification(Notifications.SHOW_FEATURES, controlBar.showFeaturesButton.selected);
		}
		
		private function onShowRailView(event:Event):void
		{
			sendNotification(Notifications.SHOW_RAIL);
		}
		
		private function onShowPieView(event:Event):void
		{
			sendNotification(Notifications.SHOW_PIE);
		}
	}
}
