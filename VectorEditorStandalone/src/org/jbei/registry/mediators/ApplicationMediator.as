package org.jbei.registry.mediators
{
	import mx.core.Application;
	
	import org.jbei.bio.data.RestrictionEnzymeGroup;
	import org.jbei.lib.ui.dialogs.ModalDialog;
	import org.jbei.lib.ui.dialogs.ModalDialogEvent;
	import org.jbei.lib.ui.dialogs.SimpleDialog;
	import org.jbei.lib.utils.SystemUtils;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Constants;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.dialogs.AboutDialogForm;
	import org.jbei.registry.view.dialogs.FeatureDialogForm;
	import org.jbei.registry.view.dialogs.GoToDialogForm;
	import org.jbei.registry.view.dialogs.PreferencesDialogForm;
	import org.jbei.registry.view.dialogs.PropertiesDialogForm;
	import org.jbei.registry.view.dialogs.RestrictionEnzymeManagerForm;
	import org.jbei.registry.view.dialogs.SelectDialogForm;
	import org.jbei.registry.view.ui.PropertiesDialog;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

    /**
     * @author Zinovii Dmytriv
     */
	public class ApplicationMediator extends Mediator
	{
		private const NAME:String = "ApplicationMediator";
		
		// Constructor
		public function ApplicationMediator()
		{
			super(NAME);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array
		{
			return [
				Notifications.GO_REPORT_BUG
				, Notifications.GO_SUGGEST_FEATURE
				, Notifications.SHOW_ENTRY_IN_REGISTRY
				
				, Notifications.SHOW_PREFERENCES_DIALOG
				, Notifications.SHOW_PROPERTIES_DIALOG
				, Notifications.SHOW_ABOUT_DIALOG
				, Notifications.SHOW_CREATE_NEW_FEATURE_DIALOG
				, Notifications.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG
				, Notifications.SHOW_GOTO_DIALOG
				, Notifications.SHOW_SELECTION_BY_RANGE_DIALOG
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.GO_REPORT_BUG:
					reportBug();
					
					break;
				case Notifications.GO_SUGGEST_FEATURE:
					suggestFeature();
					
					break;
				
				case Notifications.SHOW_ENTRY_IN_REGISTRY:
					showEntryInRegistry();
					
					break;
				case Notifications.SHOW_SELECTION_BY_RANGE_DIALOG:
					showSelectionDialog();
					
					break;
				case Notifications.SHOW_PREFERENCES_DIALOG:
					showPreferencesDialog();
					
					break;
				case Notifications.SHOW_PROPERTIES_DIALOG:
					showPropertiesDialog();
					
					break;
				case Notifications.SHOW_CREATE_NEW_FEATURE_DIALOG:
					showCreateNewFeatureDialog();
					
					break;
				case Notifications.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG:
					showRestrictionEnzymesManagerDialog();
					
					break;
				case Notifications.SHOW_GOTO_DIALOG:
					showGoToDialog();
					
					break;
				case Notifications.SHOW_ABOUT_DIALOG:
					showAboutDialog();
					
					break;
			}
		}
		
		// Private Methods
		private function reportBug():void
		{
			goToUrl(Constants.REPORT_BUG_URL);
		}
		
		private function suggestFeature():void
		{
			goToUrl(Constants.SUGGEST_FEATURE_URL);
		}
		
		private function goToUrl(url:String):void
		{
			SystemUtils.goToUrl(url);
		}
		
		private function showEntryInRegistry():void
		{
			// TODO: add context root here
			
			goToUrl("/entry/view/" + ApplicationFacade.getInstance().entry.id);
		}
		
		private function showSelectionDialog():void
		{
			var positions:Array = new Array();
			
			if(ApplicationFacade.getInstance().selectionStart > 0 && ApplicationFacade.getInstance().selectionEnd > 0) {
				positions.push(ApplicationFacade.getInstance().selectionStart);
				positions.push(ApplicationFacade.getInstance().selectionEnd);
			} else {
				positions.push(0);
				positions.push(10);
			}
			
			var selectDialog:ModalDialog = new ModalDialog(SelectDialogForm, positions);
			selectDialog.title = "Select ...";
			selectDialog.open();
			
			selectDialog.addEventListener(ModalDialogEvent.SUBMIT, onSelectDialogSubmit);
		}
		
		private function showPreferencesDialog():void
		{
			var preferencesDialog:ModalDialog = new ModalDialog(PreferencesDialogForm, null);
			preferencesDialog.title = "Preferences";
			preferencesDialog.open();
		}
		
		private function showPropertiesDialog():void
		{
			var propertiesDialog:PropertiesDialog = new PropertiesDialog(PropertiesDialogForm);
			propertiesDialog.title = "Properties";
			propertiesDialog.open();
		}
		
		private function showCreateNewFeatureDialog():void
		{
			var featureDialog:ModalDialog = new ModalDialog(FeatureDialogForm, null);
			featureDialog.title = "Create New Feature";
			featureDialog.open();
		}
		
		private function showRestrictionEnzymesManagerDialog():void
		{
			var restrictionEnzymeManagerDialog:ModalDialog = new ModalDialog(RestrictionEnzymeManagerForm, new RestrictionEnzymeGroup("tmp"));
			restrictionEnzymeManagerDialog.title = "Restriction Enzyme Manager";
			restrictionEnzymeManagerDialog.open();
		}
		
		private function showGoToDialog():void
		{
			var gotoDialog:ModalDialog = new ModalDialog(GoToDialogForm, ApplicationFacade.getInstance().caretPosition);
			gotoDialog.title = "Go To...";
			gotoDialog.open();
			
			gotoDialog.addEventListener(ModalDialogEvent.SUBMIT, onGoToDialogSubmit);
		}
		
		private function showAboutDialog():void
		{
			var aboutDialog:SimpleDialog = new SimpleDialog(AboutDialogForm);
			aboutDialog.title = "About";
			aboutDialog.open();
		}
		
		private function onSelectDialogSubmit(event:ModalDialogEvent):void
		{
			var selectionArray:Array = event.data as Array;
			
			if(selectionArray.length != 2) { return; }
			
			sendNotification(Notifications.SELECTION_CHANGED, selectionArray);
		}
		
		private function onGoToDialogSubmit(event:ModalDialogEvent):void
		{
			sendNotification(Notifications.CARET_POSITION_CHANGED, (event.data as int));
		}
	}
}
