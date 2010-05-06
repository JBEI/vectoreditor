package org.jbei.registry.mediators
{
	import flash.events.Event;
	
	import org.jbei.registry.ApplicationFacade;
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
			
			controlBar.addEventListener(MainControlBar.SAVE, onSave);
			controlBar.addEventListener(MainControlBar.SHOW_RAIL_VIEW, onShowRailView);
			controlBar.addEventListener(MainControlBar.SHOW_PIE_VIEW, onShowPieView);
			controlBar.addEventListener(MainControlBar.SHOW_FEATURES_STATE_CHANGED, onShowFeaturesStateChanged);
			controlBar.addEventListener(MainControlBar.SHOW_CUTSITES_STATE_CHANGED, onShowCutSitesStateChanged);
			controlBar.addEventListener(MainControlBar.SAFE_EDITING_CHANGED, onSafeEditingChanged);
			controlBar.addEventListener(MainControlBar.SHOW_ORFS_STATE_CHANGED, onShowORFsStateChanged);
			controlBar.addEventListener(MainControlBar.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG, onShowRestrictionEnzymesManagerDialog);
			controlBar.addEventListener(MainControlBar.SHOW_FIND_PANEL, onShowFindPanel);
			controlBar.addEventListener(MainControlBar.UNDO, onUndo);
			controlBar.addEventListener(MainControlBar.REDO, onRedo);
			controlBar.addEventListener(MainControlBar.COPY, onCopy);
			controlBar.addEventListener(MainControlBar.CUT, onCut);
			controlBar.addEventListener(MainControlBar.PASTE, onPaste);
			controlBar.addEventListener(MainControlBar.SHOW_PROPERTIES_DIALOG, onShowPropertiesDialog);
		}
		
		public override function listNotificationInterests():Array 
		{
			return [Notifications.SHOW_RAIL
				, Notifications.SHOW_PIE
				, Notifications.SHOW_FEATURES
				, Notifications.SHOW_CUTSITES
				, Notifications.SHOW_ORFS
				, Notifications.ACTION_STACK_CHANGED
				, Notifications.SELECTION_CHANGED
				, Notifications.SAFE_EDITING_CHANGED
				, Notifications.SEQUENCE_SAVED
				, Notifications.FEATURED_SEQUENCE_CHANGED
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
				case Notifications.SHOW_CUTSITES:
					controlBar.showCutSitesButton.selected = (notification.getBody() as Boolean);
					break;
				case Notifications.SHOW_ORFS:
					controlBar.showORFsButton.selected = (notification.getBody() as Boolean);
					break;
				case Notifications.ACTION_STACK_CHANGED:
					controlBar.updateUndoButtonState(!ApplicationFacade.getInstance().actionStack.undoStackIsEmpty);
					controlBar.updateRedoButtonState(!ApplicationFacade.getInstance().actionStack.redoStackIsEmpty);
					break;
				case Notifications.SEQUENCE_SAVED:
					controlBar.updateSaveButtonState(false);
					break;
				case Notifications.FEATURED_SEQUENCE_CHANGED:
					if(ApplicationFacade.getInstance().isReadOnly) {
						controlBar.updateSaveButtonState(false);
					} else {
						controlBar.updateSaveButtonState(true);
					}
					
					break;
				case Notifications.SELECTION_CHANGED:
					var selectionPositions:Array = notification.getBody() as Array;
					
					if(selectionPositions.length == 2 && selectionPositions[0] > -1 && selectionPositions[1] > -1) {
						controlBar.updateCopyAndCutButtonState(true);
					} else {
						controlBar.updateCopyAndCutButtonState(false);
					}
					break;
				case Notifications.SAFE_EDITING_CHANGED:
					controlBar.safeEditingButton.selected = (notification.getBody() as Boolean);
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
		
		private function onShowRestrictionEnzymesManagerDialog(event:Event):void
		{
			sendNotification(Notifications.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG);
		}
		
		private function onUndo(event:Event):void
		{
			sendNotification(Notifications.UNDO);
		}
		
		private function onRedo(event:Event):void
		{
			sendNotification(Notifications.REDO);
		}
		
		private function onCopy(event:Event):void
		{
			sendNotification(Notifications.COPY);
		}
		
		private function onCut(event:Event):void
		{
			sendNotification(Notifications.CUT);
		}
		
		private function onPaste(event:Event):void
		{
			sendNotification(Notifications.PASTE);
		}
		
		private function onShowFindPanel(event:Event):void
		{
			sendNotification(Notifications.SHOW_FIND_PANEL);
		}
		
		private function onShowPropertiesDialog(event:Event):void
		{
			sendNotification(Notifications.SHOW_PROPERTIES_DIALOG);
		}
		
		private function onSafeEditingChanged(event:Event):void
		{
			sendNotification(Notifications.SAFE_EDITING_CHANGED, controlBar.safeEditingButton.selected);
		}
		
		private function onShowRailView(event:Event):void
		{
			sendNotification(Notifications.SHOW_RAIL);
		}
		
		private function onShowPieView(event:Event):void
		{
			sendNotification(Notifications.SHOW_PIE);
		}
		
		private function onSave(event:Event):void
		{
			sendNotification(Notifications.SAVE_SEQUENCE);
		}
	}
}
