package org.jbei.view.mediators
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.NotificationTypes;
	import org.jbei.Notifications;
	import org.jbei.events.GridEvent;
	import org.jbei.events.GridScrollEvent;
	import org.jbei.events.RowHeaderEvent;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.GridRowHeaderColumn;
	import org.jbei.view.components.GridRowHeaderColumnHolder;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.patterns.observer.Notification;

	public class GridRowHeaderColumnHolderMediator extends Mediator implements IMediator
	{
		private static const NAME:String = "org.jbei.view.GridColumnHeaderRowHolderMediator";
		private var flag:Boolean = false;
		
		public function GridRowHeaderColumnHolderMediator( rowHeader:GridRowHeaderColumnHolder )
		{
			super( NAME, rowHeader );
			
			// eventListeners
			this.rowHeaderColumn.addEventListener( RowHeaderEvent.MOUSE_DOWN, mouseDown );
			this.rowHeaderColumn.addEventListener( RowHeaderEvent.MOUSE_UP, mouseUp );
			this.rowHeaderColumn.addEventListener( RowHeaderEvent.MOUSE_OVER, mouseOver );
		}
		
		private function mouseDown( event:RowHeaderEvent ) : void
		{
			flag = true;
			this.rowHeaderColumn.hightlightHeader( event.index, true );
			sendNotification( Notifications.GRID_ROW_SELECTED, event.index, NotificationTypes.UNIQUE );
		}
		
		private function mouseOver( event:RowHeaderEvent ) : void
		{
			if( !flag )
				return;
			
			this.rowHeaderColumn.hightlightHeader( event.index, false );
			sendNotification( Notifications.GRID_ROW_SELECTED, event.index, NotificationTypes.ADDITIVE );
		}
		
		private function mouseUp( event:RowHeaderEvent ) : void
		{
			this.flag = false;
		}
		
		public function get rowHeaderHolder() : GridRowHeaderColumnHolder
		{
			return viewComponent as GridRowHeaderColumnHolder;
		}
		
		public function get rowHeaderColumn() : GridRowHeaderColumn
		{
			return this.rowHeaderHolder.rowHeader;
		}
		
		override public function getMediatorName() : String
		{
			return NAME;
		}
		
		override public function listNotificationInterests() : Array
		{
			return [ Notifications.VSCROLL, Notifications.ROW_CREATED, Notifications.GRID_CELL_SELECTED,
				Notifications.PART_TYPE_SELECTION, Notifications.RESET_APP ];
		}
		
		override public function handleNotification( notification:INotification ) : void
		{
			switch( notification.getName() )
			{
				case Notifications.VSCROLL:
					var event:GridScrollEvent = notification.getBody() as GridScrollEvent;
					this.rowHeaderHolder.rowHeader.y = event.delta; 
					break;
				
				case Notifications.ROW_CREATED:
					var gridEvent:GridEvent = notification.getBody() as GridEvent;
					
					// header row exceeds the rows that are available
					if( gridEvent.rowIndex >= rowHeaderHolder.headerCount )
						rowHeaderHolder.addHeader();
					break;
				
				case Notifications.PART_TYPE_SELECTION:
					this.rowHeaderHolder.rowHeader.reset();
					break;
				
				case Notifications.RESET_APP:
					this.rowHeaderHolder.rowHeader.reset();
					break;
				
				case Notifications.GRID_CELL_SELECTED:
					var cells:ArrayCollection = notification.getBody() as ArrayCollection;
					if( !cells )
						break;
					
					this.rowHeaderHolder.highlightHeaders( cells );
					break;
			}
		}
	}
}