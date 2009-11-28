package org.jbei.registry.view
{
	import flash.events.Event;
	
	import org.jbei.ApplicationFacade;
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
			
			controlBar.addEventListener(MainControlBar.SHOW_FEATURES_STATE_CHANGED, onShowFeaturesStateChanged);
			controlBar.addEventListener(MainControlBar.SHOW_CUTSITES_STATE_CHANGED, onShowCutSitesStateChanged);
			controlBar.addEventListener(MainControlBar.SHOW_ORFS_STATE_CHANGED, onShowORFsStateChanged);
			controlBar.addEventListener(MainControlBar.SHOW_CREATE_NEW_FEATURE_DIALOG, onShowCreateNewFeatureDialog);
			controlBar.addEventListener(MainControlBar.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG, onShowRestrictionEnzymesManagerDialog);
			controlBar.addEventListener(MainControlBar.SHOW_GOTO_DIALOG, onShowGoToDialog);
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
			return [ApplicationFacade.SHOW_FEATURES, ApplicationFacade.SHOW_CUTSITES, ApplicationFacade.SHOW_ORFS, ApplicationFacade.ACTION_STACK_CHANGED, ApplicationFacade.SELECTION_CHANGED];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case ApplicationFacade.SHOW_FEATURES:
					controlBar.showFeaturesButton.selected = (notification.getBody() as Boolean);
					break;
				case ApplicationFacade.SHOW_CUTSITES:
					controlBar.showCutSitesButton.selected = (notification.getBody() as Boolean);
					break;
				case ApplicationFacade.SHOW_ORFS:
					controlBar.showORFsButton.selected = (notification.getBody() as Boolean);
					break;
				case ApplicationFacade.ACTION_STACK_CHANGED:
					controlBar.updateUndoButtonState(!ApplicationFacade.getInstance().actionStack.undoStackIsEmpty);
					controlBar.updateRedoButtonState(!ApplicationFacade.getInstance().actionStack.redoStackIsEmpty);
					break;
				case ApplicationFacade.SELECTION_CHANGED:
					var selectionPositions:Array = notification.getBody() as Array;
					
					if(selectionPositions.length == 2 && selectionPositions[0] > -1 && selectionPositions[1] > -1) {
						controlBar.updateCopyAndCutButtonState(true);
					} else {
						controlBar.updateCopyAndCutButtonState(false);
					}
					break;
			}
		}
		
		// Private Methods
		private function onShowFeaturesStateChanged(event:Event):void
		{
			sendNotification(ApplicationFacade.SHOW_FEATURES, controlBar.showFeaturesButton.selected);
		}
		
		private function onShowCutSitesStateChanged(event:Event):void
		{
			sendNotification(ApplicationFacade.SHOW_CUTSITES, controlBar.showCutSitesButton.selected);
		}
		
		private function onShowORFsStateChanged(event:Event):void
		{
			sendNotification(ApplicationFacade.SHOW_ORFS, controlBar.showORFsButton.selected);
		}
		
		private function onShowCreateNewFeatureDialog(event:Event):void
		{
			sendNotification(ApplicationFacade.SHOW_CREATE_NEW_FEATURE_DIALOG);
		}
		
		private function onShowRestrictionEnzymesManagerDialog(event:Event):void
		{
			sendNotification(ApplicationFacade.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG);
		}
		
		private function onUndo(event:Event):void
		{
			sendNotification(ApplicationFacade.UNDO);
		}
		
		private function onRedo(event:Event):void
		{
			sendNotification(ApplicationFacade.REDO);
		}
		
		private function onCopy(event:Event):void
		{
			sendNotification(ApplicationFacade.COPY);
		}
		
		private function onCut(event:Event):void
		{
			sendNotification(ApplicationFacade.CUT);
		}
		
		private function onPaste(event:Event):void
		{
			sendNotification(ApplicationFacade.PASTE);
		}
		
		private function onShowGoToDialog(event:Event):void
		{
			sendNotification(ApplicationFacade.SHOW_GOTO_DIALOG);
		}
		
		private function onShowFindPanel(event:Event):void
		{
			sendNotification(ApplicationFacade.SHOW_FIND_PANEL);
		}
		
		private function onShowPropertiesDialog(event:Event):void
		{
			sendNotification(ApplicationFacade.SHOW_PROPERTIES_DIALOG);
		}
	}
}
