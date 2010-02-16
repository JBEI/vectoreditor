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
			controlBar.addEventListener(MainControlBar.SHOW_SEQUENCE_VIEW, onShowSequenceView);
			controlBar.addEventListener(MainControlBar.SHOW_FEATURES_STATE_CHANGED, onShowFeaturesStateChanged);
			controlBar.addEventListener(MainControlBar.SHOW_CUTSITES_STATE_CHANGED, onShowCutSitesStateChanged);
			controlBar.addEventListener(MainControlBar.SHOW_ORFS_STATE_CHANGED, onShowORFsStateChanged);
			controlBar.addEventListener(MainControlBar.SHOW_FIND_PANEL, onShowFindPanel);
			controlBar.addEventListener(MainControlBar.COPY, onCopy);
			controlBar.addEventListener(MainControlBar.PRINT, onPrint);
			controlBar.addEventListener(MainControlBar.SHOW_PROPERTIES_DIALOG, onShowPropertiesDialog);
		}
		
		public override function listNotificationInterests():Array 
		{
			return [Notifications.SHOW_RAIL
				, Notifications.SHOW_PIE
				, Notifications.SHOW_SEQUENCE
				, Notifications.SHOW_FEATURES
				, Notifications.SHOW_CUTSITES
				, Notifications.SHOW_ORFS
				, Notifications.SELECTION_CHANGED
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
				case Notifications.SHOW_SEQUENCE:
					controlBar.viewToggleButtonBar.selectedIndex = 2;
					break;
				case Notifications.SHOW_FEATURES:
					controlBar.showFeaturesButton.selected = (notification.getBody() as Boolean);
					break;
				case Notifications.SHOW_CUTSITES:
					controlBar.showCutSitesButton.selected = (notification.getBody() as Boolean);
					break;
				case Notifications.SHOW_ORFS:
					controlBar.showORFsButton.selected = (notification.getBody() as Boolean);
					break;
				case Notifications.SELECTION_CHANGED:
					var selectionPositions:Array = notification.getBody() as Array;
					
					if(selectionPositions.length == 2 && selectionPositions[0] > -1 && selectionPositions[1] > -1) {
						controlBar.updateCopyButtonState(true);
					} else {
						controlBar.updateCopyButtonState(false);
					}
					break;
			}
		}
		
		// Private Methods
		private function onShowFeaturesStateChanged(event:Event):void
		{
			sendNotification(Notifications.SHOW_FEATURES, controlBar.showFeaturesButton.selected);
		}
		
		private function onShowCutSitesStateChanged(event:Event):void
		{
			sendNotification(Notifications.SHOW_CUTSITES, controlBar.showCutSitesButton.selected);
		}
		
		private function onShowORFsStateChanged(event:Event):void
		{
			sendNotification(Notifications.SHOW_ORFS, controlBar.showORFsButton.selected);
		}
		
		private function onCopy(event:Event):void
		{
			sendNotification(Notifications.COPY);
		}
		
		private function onPrint(event:Event):void
		{
			sendNotification(Notifications.PRINT_CURRENT);
		}
		
		private function onShowFindPanel(event:Event):void
		{
			sendNotification(Notifications.SHOW_FIND_PANEL);
		}
		
		private function onShowPropertiesDialog(event:Event):void
		{
			sendNotification(Notifications.SHOW_PROPERTIES_DIALOG);
		}
		
		private function onShowRailView(event:Event):void
		{
			sendNotification(Notifications.SHOW_RAIL);
		}
		
		private function onShowPieView(event:Event):void
		{
			sendNotification(Notifications.SHOW_PIE);
		}
		
		private function onShowSequenceView(event:Event):void
		{
			sendNotification(Notifications.SHOW_SEQUENCE);
		}
	}
}
