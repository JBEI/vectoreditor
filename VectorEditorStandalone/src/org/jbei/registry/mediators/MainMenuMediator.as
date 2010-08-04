package org.jbei.registry.mediators
{
	import org.jbei.lib.ui.menu.MenuItem;
	import org.jbei.lib.ui.menu.MenuItemEvent;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.ui.MainMenu;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

    /**
     * @author Zinovii Dmytriv
     */
	public class MainMenuMediator extends Mediator
	{
		private const NAME:String = "MainMenuMediator";
		
		private var mainMenu:MainMenu;
		
		// Constructor
		public function MainMenuMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			mainMenu = viewComponent as MainMenu;
			mainMenu.addEventListener(MainMenu.SHOW_RAIL, onShowRail);
			mainMenu.addEventListener(MainMenu.SHOW_PIE, onShowPie);
			mainMenu.addEventListener(MainMenu.SHOW_FEATURES_STATE_CHANGED, onShowFeaturesStateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_CUTSITES_STATE_CHANGED, onShowCutSitesStateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_ORFS_STATE_CHANGED, onShowORFsStateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_COMPLEMENTARY_STATE_CHANGED, onShowComplementaryStateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_AA1_STATE_CHANGED, onShowAA1StateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_AA1_REVCOM_STATE_CHANGED, onShowAA1RevComStateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_AA3_STATE_CHANGED, onShowAA3StateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_SPACES_STATE_CHANGED, onShowSpacesStateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_FEATURE_LABELS_STATE_CHANGED, onShowFeatureLabelsStateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_CUT_SITE_LABELS_STATE_CHANGED, onShowCutSiteLabelsStateChanged);
			mainMenu.addEventListener(MainMenu.SHOW_SELECT_BY_RANGE_DIALOG, onShowSelectByRangeDialog);
			mainMenu.addEventListener(MainMenu.SHOW_PREFERENCES_DIALOG, onShowPreferencesDialog);
			mainMenu.addEventListener(MainMenu.SHOW_GOTO_DIALOG, onShowGoToDialog);
			mainMenu.addEventListener(MainMenu.SHOW_FIND_DIALOG, onShowFindDialog);
			mainMenu.addEventListener(MainMenu.SHOW_ABOUT_DIALOG, onShowAboutDialog);
			mainMenu.addEventListener(MainMenu.SHOW_PROPERTIES_DIALOG, onShowPropertiesDialog);
			mainMenu.addEventListener(MainMenu.PRINT_SEQUENCE, onPrintSequence);
			mainMenu.addEventListener(MainMenu.PRINT_PIE, onPrintPie);
			mainMenu.addEventListener(MainMenu.PRINT_RAIL, onPrintRail);
			mainMenu.addEventListener(MainMenu.COPY, onCopy);
			mainMenu.addEventListener(MainMenu.CUT, onCut);
			mainMenu.addEventListener(MainMenu.PASTE, onPaste);
			mainMenu.addEventListener(MainMenu.SELECT_ALL, onSelectAll);
			mainMenu.addEventListener(MainMenu.UNDO, onUndo);
			mainMenu.addEventListener(MainMenu.REDO, onRedo);
			mainMenu.addEventListener(MainMenu.SHOW_CREATE_NEW_FEATURE_DIALOG, onShowCreateNewFeatureDialog);
			mainMenu.addEventListener(MainMenu.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG, onShowRestrictionEnzymesManagerDialog);
            mainMenu.addEventListener(MainMenu.SHOW_SIMULATE_DIGESTION_DIALOG, onShowSimulateDigestionDialog);
			mainMenu.addEventListener(MainMenu.GO_REPORT_BUG_WEB_LINK, onGoReportBugWebLink);
			mainMenu.addEventListener(MainMenu.GO_SUGGEST_FEATURE_WEB_LINK, onGoSuggestFeatureWebLink);
			mainMenu.addEventListener(MainMenu.SAFE_EDITING_CHANGED, onSafeEditingChanged);
			mainMenu.addEventListener(MainMenu.SAVE, onSave);
            mainMenu.addEventListener(MainMenu.IMPORT_SEQUENCE_FILE, onImportSequence);
            mainMenu.addEventListener(MainMenu.EXPORT_SEQUENCE_FILE, onExportSequence);
			mainMenu.addEventListener(MainMenu.SHOW_ENTRY_IN_REGISTRY, onShowEntryInRegistry);
            mainMenu.addEventListener(MainMenu.REVERSE_COMPLEMENT, onReverseComplement);
		}
		
		public override function listNotificationInterests():Array 
		{
			return [Notifications.SHOW_RAIL
				, Notifications.SHOW_PIE
				, Notifications.SHOW_FEATURES
				, Notifications.SHOW_CUTSITES
				, Notifications.SHOW_ORFS
				, Notifications.SHOW_COMPLEMENTARY
				, Notifications.SHOW_AA1
				, Notifications.SHOW_AA3
				, Notifications.ACTION_STACK_CHANGED
				, Notifications.SEQUENCE_SAVED
				, Notifications.SELECTION_CHANGED
				, Notifications.SAFE_EDITING_CHANGED
				, Notifications.SEQUENCE_PROVIDER_CHANGED
				];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.SHOW_PIE:
					mainMenu.menuItemByName("showPieMenuItem").toggled = true;
					mainMenu.menuItemByName("showRailMenuItem").toggled = false;
					break;
				case Notifications.SHOW_RAIL:
					mainMenu.menuItemByName("showPieMenuItem").toggled = false;
					mainMenu.menuItemByName("showRailMenuItem").toggled = true;
					break;
				case Notifications.SHOW_FEATURES:
					mainMenu.menuItemByName("showFeaturesMenuItem").toggled = notification.getBody() as Boolean;
					break;
				case Notifications.SHOW_CUTSITES:
					mainMenu.menuItemByName("showCutSitesMenuItem").toggled = notification.getBody() as Boolean;
					break;
				case Notifications.SHOW_ORFS:
					mainMenu.menuItemByName("showORFsMenuItem").toggled = notification.getBody() as Boolean;
					break;
				case Notifications.SHOW_COMPLEMENTARY:
					mainMenu.menuItemByName("showComplementaryMenuItem").toggled = notification.getBody() as Boolean;
					break;
				case Notifications.SHOW_AA1:
					mainMenu.menuItemByName("showAA3MenuItem").toggled = false;
					break;
				case Notifications.SHOW_AA3:
					mainMenu.menuItemByName("showAA1MenuItem").toggled = false;
					break;
				case Notifications.ACTION_STACK_CHANGED:
					mainMenu.menuItemByName("undoMenuItem").enabled = !ApplicationFacade.getInstance().actionStack.undoStackIsEmpty;
					mainMenu.menuItemByName("redoMenuItem").enabled = !ApplicationFacade.getInstance().actionStack.redoStackIsEmpty;
					break;
				case Notifications.SEQUENCE_SAVED:
					mainMenu.menuItemByName("saveMenuItem").enabled = false;
					break;
				case Notifications.SEQUENCE_PROVIDER_CHANGED:
					if(ApplicationFacade.getInstance().hasWritablePermissions) {
						mainMenu.menuItemByName("saveMenuItem").enabled = true;
					} else {
						mainMenu.menuItemByName("saveMenuItem").enabled = false;
					}
					
					break;
				case Notifications.SELECTION_CHANGED:
					var selectionPositions:Array = notification.getBody() as Array;
					
					if(selectionPositions[0] > -1 && selectionPositions[1] > -1) {
						mainMenu.menuItemByName("cutMenuItem").enabled = true;
						mainMenu.menuItemByName("copyMenuItem").enabled = true;
					} else {
						mainMenu.menuItemByName("cutMenuItem").enabled = false;
						mainMenu.menuItemByName("copyMenuItem").enabled = false;
					}
					break;
				case Notifications.SAFE_EDITING_CHANGED:
					mainMenu.menuItemByName("safeEditingMenuItem").toggled = notification.getBody() as Boolean;
					break;
			}
		}
		
		// Private Methods
		private function onShowFeaturesStateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_FEATURES, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowCutSitesStateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_CUTSITES, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowORFsStateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_ORFS, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowComplementaryStateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_COMPLEMENTARY, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowAA1StateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_AA1, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowAA3StateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_AA3, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowAA1RevComStateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_AA1_REVCOM, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowSpacesStateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_SPACES, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowFeatureLabelsStateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_FEATURE_LABELS, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowCutSiteLabelsStateChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_CUT_SITE_LABELS, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowSelectByRangeDialog(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_SELECTION_BY_RANGE_DIALOG);
		}
		
		private function onShowPreferencesDialog(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_PREFERENCES_DIALOG);
		}
		
		private function onShowAboutDialog(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_ABOUT_DIALOG);
		}
		
		private function onUndo(event:MenuItemEvent):void
		{
			sendNotification(Notifications.UNDO);
		}
		
		private function onRedo(event:MenuItemEvent):void
		{
			sendNotification(Notifications.REDO);
		}
		
		private function onCopy(event:MenuItemEvent):void
		{
			sendNotification(Notifications.COPY);
		}
		
		private function onCut(event:MenuItemEvent):void
		{
			sendNotification(Notifications.CUT);
		}
		
		private function onPaste(event:MenuItemEvent):void
		{
			sendNotification(Notifications.PASTE);
		}
		
		private function onSelectAll(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SELECT_ALL);
		}
		
		private function onShowCreateNewFeatureDialog(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_CREATE_NEW_FEATURE_DIALOG);
		}
		
		private function onShowRestrictionEnzymesManagerDialog(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG);
		}
		
        private function onShowSimulateDigestionDialog(event:MenuItemEvent):void
        {
            sendNotification(Notifications.SHOW_SIMULATE_DIGESTION_DIALOG);
        }
        
		private function onShowGoToDialog(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_GOTO_DIALOG);
		}
		
		private function onShowFindDialog(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_FIND_PANEL);
		}
		
		private function onGoReportBugWebLink(event:MenuItemEvent):void
		{
			sendNotification(Notifications.GO_REPORT_BUG);
		}
		
		private function onGoSuggestFeatureWebLink(event:MenuItemEvent):void
		{
			sendNotification(Notifications.GO_SUGGEST_FEATURE);
		}
		
		private function onShowPropertiesDialog(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_PROPERTIES_DIALOG);
		}
		
		private function onSafeEditingChanged(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SAFE_EDITING_CHANGED, (event.menuItem as MenuItem).toggled);
		}
		
		private function onShowRail(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_RAIL);
		}
		
		private function onShowPie(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_PIE);
		}
		
		private function onPrintSequence(event:MenuItemEvent):void
		{
			sendNotification(Notifications.PRINT_SEQUENCE);
		}
		
		private function onPrintRail(event:MenuItemEvent):void
		{
			sendNotification(Notifications.PRINT_RAIL);
		}
		
		private function onPrintPie(event:MenuItemEvent):void
		{
			sendNotification(Notifications.PRINT_PIE);
		}
		
		private function onShowEntryInRegistry(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SHOW_ENTRY_IN_REGISTRY);
		}
		
		private function onSave(event:MenuItemEvent):void
		{
			sendNotification(Notifications.SAVE_SEQUENCE);
		}
        
        private function onReverseComplement(event:MenuItemEvent):void
        {
            sendNotification(Notifications.REVERSE_COMPLEMENT_SEQUENCE);
        }
        
        private function onImportSequence(event:MenuItemEvent):void
        {
            sendNotification(Notifications.IMPORT_SEQUENCE_FILE);
        }
        
        private function onExportSequence(event:MenuItemEvent):void
        {
            sendNotification(Notifications.EXPORT_SEQUENCE_FILE);
        }
	}
}
