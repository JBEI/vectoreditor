package org.jbei.registry.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.ItemClickEvent;
	
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.ui.MainControlBar;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

    /**
     * @author Zinovii Dmytriv
     */
	public class MainControlBarMediator extends Mediator
	{
		private const NAME:String = "MainControlBarMediator";
		
		private var controlBar:MainControlBar;
        private var applicationFacade:ApplicationFacade;
		
		// Constructor
		public function MainControlBarMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			controlBar = viewComponent as MainControlBar;
            
            applicationFacade = ApplicationFacade.getInstance();
			
            controlBar.saveToRegistryButton.addEventListener(MouseEvent.CLICK, onSaveToRegistryClick);
            controlBar.saveProjectButton.addEventListener(MouseEvent.CLICK, onSaveProjectClick);
            controlBar.projectPropertiesButton.addEventListener(MouseEvent.CLICK, onProjectPropertiesButtonClick);
			controlBar.viewToggleButtonBar.addEventListener(ItemClickEvent.ITEM_CLICK, onChangeViewButtonClick);
			controlBar.copyButton.addEventListener(MouseEvent.CLICK, onCopy);
            controlBar.cutButton.addEventListener(MouseEvent.CLICK, onCut);
            controlBar.pasteButton.addEventListener(MouseEvent.CLICK, onPaste);
            controlBar.undoButton.addEventListener(MouseEvent.CLICK, onUndo);
            controlBar.redoButton.addEventListener(MouseEvent.CLICK, onRedo);
            controlBar.safeEditingButton.addEventListener(Event.CHANGE, onSafeEditingChanged);
            controlBar.showFindPanelButton.addEventListener(MouseEvent.CLICK, onShowFindPanel);
            controlBar.showFeaturesButton.addEventListener(Event.CHANGE, onShowFeaturesStateChanged);
            controlBar.showCutSitesButton.addEventListener(Event.CHANGE, onShowCutSitesStateChanged);
            controlBar.showORFsButton.addEventListener(Event.CHANGE, onShowORFsStateChanged);
            controlBar.showRestrictionEnzymesManagerDialogButton.addEventListener(MouseEvent.CLICK, onShowRestrictionEnzymesManagerDialog);
            controlBar.propertiesButton.addEventListener(MouseEvent.CLICK, onShowPropertiesDialog);
            
            CONFIG::registryEdition {
                controlBar.saveToRegistryButton.visible = false;
                controlBar.saveToRegistryButton.includeInLayout = false;
            }
            
            CONFIG::entryEdition {
                controlBar.saveProjectButton.visible = false;
                controlBar.saveProjectButton.includeInLayout = false;
                controlBar.projectPropertiesButton.visible = false;
                controlBar.projectPropertiesButton.includeInLayout = false;
            }
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
				, Notifications.SEQUENCE_PROVIDER_CHANGED
                , Notifications.PERMISSIONS_FETCHED
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
					controlBar.updateUndoButtonState(!applicationFacade.isUndoStackEmpty);
					controlBar.updateRedoButtonState(!applicationFacade.isRedoStackEmpty);
                    
					break;
                case Notifications.PERMISSIONS_FETCHED:
                    if(applicationFacade.hasWritablePermissions) {
                        controlBar.updateSaveButtonState(true);
                    } else {
                        controlBar.updateSaveButtonState(false);
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
		
		// Event Handlers
        private function onSaveToRegistryClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SAVE_TO_REGISTRY);
        }
        
        private function onSaveProjectClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SAVE_PROJECT);
        }
        
        private function onProjectPropertiesButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SHOW_PROJECT_PROPERTIES_DIALOG);
        }
        
        private function onChangeViewButtonClick(event:ItemClickEvent):void
        {
            if(event.index == 0) { // Circular View
                sendNotification(Notifications.SHOW_PIE);
            } else if (event.index == 1) { // Linear View
                sendNotification(Notifications.SHOW_RAIL);
            }
        }
        
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
		
		private function onShowRestrictionEnzymesManagerDialog(event:MouseEvent):void
		{
			sendNotification(Notifications.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG);
		}
		
		private function onUndo(event:MouseEvent):void
		{
			sendNotification(Notifications.UNDO);
		}
		
		private function onRedo(event:MouseEvent):void
		{
			sendNotification(Notifications.REDO);
		}
		
		private function onCopy(event:MouseEvent):void
		{
			sendNotification(Notifications.COPY);
		}
		
		private function onCut(event:MouseEvent):void
		{
			sendNotification(Notifications.CUT);
		}
		
		private function onPaste(event:MouseEvent):void
		{
			sendNotification(Notifications.PASTE);
		}
		
		private function onShowFindPanel(event:MouseEvent):void
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
	}
}
