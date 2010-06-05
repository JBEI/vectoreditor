package org.jbei.registry.mediators
{
	import mx.core.Application;
	
	import org.jbei.lib.ui.dialogs.SimpleDialog;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.view.dialogs.PropertiesDialogForm;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

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
				Notifications.SHOW_PROPERTIES_DIALOG
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.SHOW_PROPERTIES_DIALOG:
					showPropertiesDialog();
					
					break;
			}
		}
		
		private function showPropertiesDialog():void
		{
			var propertiesDialog:SimpleDialog = new SimpleDialog(PropertiesDialogForm);
			propertiesDialog.title = "Properties";
			propertiesDialog.open();
		}
	}
}
