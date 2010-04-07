package org.jbei.registry.mediators
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.ui.MainPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.patterns.observer.Notification;

	public class MainPanelMediator extends Mediator
	{
		private const NAME:String = "MainPanelMediator"
		
		// Constructor
		public function MainPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			ApplicationFacade.getInstance().initializeControls(viewComponent as MainPanel);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [
				  Notifications.SHOW_RAIL
				, Notifications.SHOW_PIE
				
				, Notifications.SHOW_FEATURES
				, Notifications.SHOW_CUTSITES
				, Notifications.SHOW_ORFS
				, Notifications.SHOW_COMPLEMENTARY
				, Notifications.SHOW_AA1
				, Notifications.SHOW_AA1_REVCOM
				, Notifications.SHOW_AA3
				, Notifications.SHOW_SPACES
				, Notifications.SHOW_FEATURE_LABELS
				, Notifications.SHOW_CUT_SITE_LABELS
				
				, Notifications.COPY
				, Notifications.CUT
				, Notifications.PASTE
				, Notifications.SHOW_SELECTION_BY_RANGE_DIALOG
				, Notifications.SELECT_ALL
				
				, Notifications.SELECTION_CHANGED
				, Notifications.CARET_POSITION_CHANGED
				, Notifications.SAFE_EDITING_CHANGED 
				
				, Notifications.FIND
				, Notifications.FIND_NEXT
				, Notifications.HIGHLIGHT
				, Notifications.CLEAR_HIGHLIGHT
				
				, Notifications.SHOW_PREFERENCES_DIALOG
				, Notifications.SHOW_PROPERTIES_DIALOG
				, Notifications.SHOW_ABOUT_DIALOG
				, Notifications.SHOW_CREATE_NEW_FEATURE_DIALOG
				, Notifications.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG
				, Notifications.SHOW_GOTO_DIALOG
				, Notifications.GO_REPORT_BUG
				, Notifications.GO_SUGGEST_FEATURE
				
				, Notifications.ENTRY_FETCHED
				, Notifications.SEQUENCE_FETCHED
				, Notifications.USER_PREFERENCES_CHANGED
				, Notifications.USER_RESTRICTION_ENZYMES_CHANGED
				
				, Notifications.PRINT_PIE
				, Notifications.PRINT_RAIL
				, Notifications.PRINT_SEQUENCE
				
				, Notifications.SHOW_ENTRY_IN_REGISTRY
				, Notifications.SAVE_SEQUENCE
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.SHOW_RAIL:
					ApplicationFacade.getInstance().showRail();
					
					break;
				case Notifications.SHOW_PIE:
					ApplicationFacade.getInstance().showPie();
					
					break;
				case Notifications.SHOW_FEATURES:
					ApplicationFacade.getInstance().displayFeatures(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_CUTSITES:
					ApplicationFacade.getInstance().displayCutSites(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_ORFS:
					ApplicationFacade.getInstance().displayORF(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_COMPLEMENTARY:
					ApplicationFacade.getInstance().displayComplementarySequence(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_AA1:
					ApplicationFacade.getInstance().displayAA1(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_AA3:
					ApplicationFacade.getInstance().displayAA3(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_AA1_REVCOM:
					ApplicationFacade.getInstance().displayAA1RevCom(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_SPACES:
					ApplicationFacade.getInstance().displaySpaces(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_FEATURE_LABELS:
					ApplicationFacade.getInstance().displayFeaturesLabel(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_CUT_SITE_LABELS:
					ApplicationFacade.getInstance().displayCutSitesLabel(notification.getBody() as Boolean);
					
					break;
				case Notifications.CARET_POSITION_CHANGED:
					ApplicationFacade.getInstance().moveCaretToPosition(notification.getBody() as int);
					
					break;
				case Notifications.SELECTION_CHANGED:
					var selectionArray:Array = notification.getBody() as Array;
					
					ApplicationFacade.getInstance().select(selectionArray[0], selectionArray[1]);
					
					break;
				case Notifications.ENTRY_FETCHED:
					ApplicationFacade.getInstance().entryFetched();
					
					break;
				case Notifications.SEQUENCE_FETCHED:
					ApplicationFacade.getInstance().sequenceFetched();
					
					break;
				case Notifications.SHOW_SELECTION_BY_RANGE_DIALOG:
					ApplicationFacade.getInstance().showSelectionDialog();
					
					break;
				case Notifications.SHOW_PREFERENCES_DIALOG:
					ApplicationFacade.getInstance().showPreferencesDialog();
					
					break;
				case Notifications.SHOW_PROPERTIES_DIALOG:
					ApplicationFacade.getInstance().showPropertiesDialog();
					
					break;
				case Notifications.SHOW_CREATE_NEW_FEATURE_DIALOG:
					ApplicationFacade.getInstance().showCreateNewFeatureDialog();
					
					break;
				case Notifications.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG:
					ApplicationFacade.getInstance().showRestrictionEnzymesManagerDialog();
					
					break;
				case Notifications.SHOW_GOTO_DIALOG:
					ApplicationFacade.getInstance().showGoToDialog();
					
					break;
				case Notifications.SHOW_ABOUT_DIALOG:
					ApplicationFacade.getInstance().showAboutDialog();
					
					break;
				case Notifications.USER_PREFERENCES_CHANGED:
					ApplicationFacade.getInstance().userPreferencesUpdated();
					
					break;
				case Notifications.USER_RESTRICTION_ENZYMES_CHANGED:
					ApplicationFacade.getInstance().userRestrictionEnzymesUpdated();
					
					break;
				case Notifications.COPY:
					ApplicationFacade.getInstance().copyToClipboard();
					
					break;
				case Notifications.CUT:
					ApplicationFacade.getInstance().cutToClipboard();
					
					break;
				case Notifications.PASTE:
					ApplicationFacade.getInstance().pasteFromClipboard();
					
					break;
				case Notifications.SELECT_ALL:
					ApplicationFacade.getInstance().selectAll();
					
					break;
				case Notifications.GO_REPORT_BUG:
					ApplicationFacade.getInstance().reportBug();
					
					break;
				case Notifications.GO_SUGGEST_FEATURE:
					ApplicationFacade.getInstance().suggestFeature();
					
					break;
				case Notifications.FIND:
					var findData:Array = notification.getBody() as Array;
					
					var findExpression:String = findData[0] as String;
					var findDataType:String = findData[1] as String;
					var findSearchType:String = findData[2] as String;
					
					ApplicationFacade.getInstance().find(findExpression, findDataType, findSearchType);
					
					break;
				case Notifications.FIND_NEXT:
					var findNextData:Array = notification.getBody() as Array;
					
					var findNextExpression:String = findNextData[0] as String;
					var findNextDataType:String = findNextData[1] as String;
					var findNextSearchType:String = findNextData[2] as String;
					
					ApplicationFacade.getInstance().findNext(findNextExpression, findNextDataType, findNextSearchType);
					
					break;
				case Notifications.CLEAR_HIGHLIGHT:
					ApplicationFacade.getInstance().clearHighlight();
					
					break;
				case Notifications.HIGHLIGHT:
					var highlightFindData:Array = notification.getBody() as Array;
					
					var highlightExpression:String = highlightFindData[0] as String;
					var highlightDataType:String = highlightFindData[1] as String;
					var highlightSearchType:String = highlightFindData[2] as String;
					
					ApplicationFacade.getInstance().highlight(highlightExpression, highlightDataType, highlightSearchType);
					
					break;
				case Notifications.SAFE_EDITING_CHANGED:
					ApplicationFacade.getInstance().changeSafeEditingStage(notification.getBody() as Boolean);
					
					break;
				case Notifications.PRINT_SEQUENCE:
					ApplicationFacade.getInstance().printSequence();
					
					break;
				case Notifications.PRINT_RAIL:
					ApplicationFacade.getInstance().printRail();
					
					break;
				case Notifications.PRINT_PIE:
					ApplicationFacade.getInstance().printPie();
					
					break;
				case Notifications.SHOW_ENTRY_IN_REGISTRY:
					ApplicationFacade.getInstance().showEntryInRegistry();
					
					break;
				case Notifications.SAVE_SEQUENCE:
					ApplicationFacade.getInstance().save();
					
					break;
			}
		}
	}
}
