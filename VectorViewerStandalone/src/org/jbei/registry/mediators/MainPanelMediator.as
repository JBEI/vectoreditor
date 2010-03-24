package org.jbei.registry.mediators
{
	import org.jbei.components.Pie;
	import org.jbei.components.Rail;
	import org.jbei.components.SequenceAnnotator;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.ui.MainPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

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
				, Notifications.SHOW_SEQUENCE
				
				, Notifications.SHOW_FEATURES
				, Notifications.SHOW_CUTSITES
				, Notifications.SHOW_ORFS
				
				, Notifications.COPY
				, Notifications.SELECT_ALL
				
				, Notifications.SELECTION_CHANGED
				, Notifications.CARET_POSITION_CHANGED
				
				, Notifications.FIND
				, Notifications.FIND_NEXT
				, Notifications.HIGHLIGHT
				, Notifications.CLEAR_HIGHLIGHT
				
				, Notifications.SHOW_PROPERTIES_DIALOG
				
				, Notifications.ENTRY_FETCHED
				, Notifications.SEQUENCE_FETCHED
				
				, Notifications.PRINT_CURRENT
				, Notifications.PRINT_PIE
				, Notifications.PRINT_RAIL
				, Notifications.PRINT_SEQUENCE
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
				case Notifications.SHOW_SEQUENCE:
					ApplicationFacade.getInstance().showSequence();
					
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
				case Notifications.SHOW_PROPERTIES_DIALOG:
					ApplicationFacade.getInstance().showPropertiesDialog();
					
					break;
				case Notifications.COPY:
					ApplicationFacade.getInstance().copyToClipboard();
					
					break;
				case Notifications.SELECT_ALL:
					ApplicationFacade.getInstance().selectAll();
					
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
				case Notifications.PRINT_CURRENT:
					if(ApplicationFacade.getInstance().activeSequenceComponent is Pie) {
						sendNotification(Notifications.PRINT_PIE);
					} else if(ApplicationFacade.getInstance().activeSequenceComponent is Rail) {
						sendNotification(Notifications.PRINT_RAIL);
					} else if(ApplicationFacade.getInstance().activeSequenceComponent is SequenceAnnotator) {
						sendNotification(Notifications.PRINT_SEQUENCE);
					}
					
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
			}
		}
	}
}
