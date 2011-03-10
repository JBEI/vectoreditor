package org.jbei.view.mediators
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.Notifications;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Button;
	import spark.components.TitleWindow;

	public class CancelButtonMediator extends Mediator implements IMediator
	{
		private static const NAME:String = "org.jbei.view.mediators.CancelButtonMediator";
		
		public function CancelButtonMediator( cancel:Button )
		{
			super( NAME, cancel );
			this.cancelButton.addEventListener( MouseEvent.CLICK, cancelEvent );
			this.cancelButton.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
		}
		
		// EVENT handlers
		private function keyDown( event:KeyboardEvent ) : void
		{
			switch( event.keyCode )
			{
				case Keyboard.ENTER:
					this.cancel();
					break;
			}
		}
		
		private function cancelEvent( event:MouseEvent ) : void
		{
			this.cancel();
		}
		
		override public function listNotificationInterests() : Array
		{
			return [ Notifications.PART_TYPE_SELECTION, Notifications.RESET_APP, Notifications.SAVE, Notifications.ACTIVE_GRID_CELL_TEXT_CHANGE ];
		}
		
		override public function handleNotification( notification:INotification ) : void
		{
			switch( notification.getName() )
			{
				case Notifications.PART_TYPE_SELECTION:
				case Notifications.RESET_APP:
				case Notifications.ACTIVE_GRID_CELL_TEXT_CHANGE:
					this.cancelButton.enabled = true;
					break;
				
				case Notifications.SAVE:
					this.cancelButton.enabled = false;
					break;
			}
		}
		
		private function confirmCancel( event:CloseEvent ) : void
		{
			if( event.detail == Alert.YES )
			{
				sendNotification( Notifications.RESET_APP );
			}
		}
		
		private function cancel() : void
		{
			Alert.show( "You will lose any changes that have not been saved. Continue?", "Cancel", Alert.NO|Alert.YES, 
				ApplicationFacade.getInstance().application, confirmCancel, null, Alert.NO );
		}
		
		public function get cancelButton() : Button
		{
			return this.viewComponent as Button;
		}
		
		override public function getMediatorName() : String
		{
			return NAME;
		}
	}
}