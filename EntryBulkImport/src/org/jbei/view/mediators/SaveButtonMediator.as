package org.jbei.view.mediators
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import org.jbei.Notifications;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Button;

	public class SaveButtonMediator extends Mediator
	{
		private static const NAME:String = "org.jbei.view.mediators.SaveButtonMediator";
		
		public function SaveButtonMediator( save:Button )
		{
			super( NAME, save );
			
			this.saveButton.enabled = false;
			
			// mouse click and "enter" when focused triggers a save
			this.saveButton.addEventListener( MouseEvent.CLICK, saveEvent );
			this.saveButton.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
		}
		
		// EVENT Handlers
		private function saveEvent( event : MouseEvent ) : void
		{
			sendNotification( Notifications.SAVE_CLICK );
		}
		
		private function keyDown( event:KeyboardEvent ) : void
		{
			switch( event.keyCode )
			{
				case Keyboard.ENTER:
					sendNotification( Notifications.SAVE_CLICK );
				break;
			}
		}
		
		override public function listNotificationInterests() : Array
		{
			return [ Notifications.PART_TYPE_SELECTION ];
		}
		
		override public function handleNotification( notification:INotification ) : void
		{
			switch( notification.getName() )
			{
				case Notifications.PART_TYPE_SELECTION:
					this.saveButton.enabled = true;
					break;
			}
		}
		
		public function get saveButton() : Button
		{
			return this.viewComponent as Button;
		}
	}
}