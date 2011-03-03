package org.jbei.view.mediators
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.Notifications;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.HeaderTextInput;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;

	public class HeaderTextInputMediator extends Mediator
	{
		private static const NAME:String = "org.jbei.view.HeaderTextInputMediator";
		
		public function HeaderTextInputMediator( viewComponent:TextInput )
		{
			super( NAME, viewComponent );
			
			// add event listeners using functions defined here
			this.headerInput.addEventListener( TextOperationEvent.CHANGE, textInput );
		}
		
		private function textInput( event:Event ) : void
		{
			sendNotification( Notifications.HEADER_INPUT_TEXT_CHANGE, this.headerInput.text );
		}
		
		protected function get headerInput() : HeaderTextInput
		{
			return viewComponent as HeaderTextInput;
		}
		
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		override public function listNotificationInterests() : Array
		{
			return [ Notifications.ACTIVE_GRID_CELL_TEXT_CHANGE, Notifications.GRID_CELL_SELECTED,
				Notifications.PART_TYPE_SELECTION, Notifications.RESET_APP ];
		}
		
		override public function handleNotification( notification:INotification ) : void
		{
			switch( notification.getName() )
			{
				case Notifications.ACTIVE_GRID_CELL_TEXT_CHANGE:
					var activeCell:GridCell = notification.getBody() as GridCell;
					headerInput.text = activeCell.text;
					break;
				
				case Notifications.GRID_CELL_SELECTED:
					var cells:ArrayCollection = notification.getBody() as ArrayCollection;
					if( cells.length != 1 )
						break;
					
					var cell:GridCell = cells[0];
					
					if( !cell )
					{
						trace( "cell is null" );
						break;
					}
					this.headerInput.text = cell.text;
					break;
				
				case Notifications.PART_TYPE_SELECTION:
					this.headerInput.text = "";
					break;
				
				case Notifications.RESET_APP:
					this.headerInput.text = "";
					break;
			}
		}
	}
}