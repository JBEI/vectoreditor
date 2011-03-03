package org.jbei.view.mediators
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.Notifications;
	import org.jbei.events.GridScrollEvent;
	import org.jbei.model.EntryTypeField;
	import org.jbei.model.fields.EntryFields;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.GridColumnHeader;
	import org.jbei.view.components.GridColumnHeaderRowHolder;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class GridColumnHeaderRowMediator extends Mediator
	{
		public static const NAME:String = "org.jbei.view.GridColumnHeaderRowMediator";
		
		public function GridColumnHeaderRowMediator( gridHeader:GridColumnHeaderRowHolder )
		{
			super( NAME, gridHeader );
		}
		
		public function get gridHeaderHolder() : GridColumnHeaderRowHolder
		{
			return this.viewComponent as GridColumnHeaderRowHolder;
		}
		
		override public function getMediatorName() : String
		{
			return NAME;
		}
		
		override public function listNotificationInterests() : Array
		{
			return [ Notifications.PART_TYPE_FIELDS_LOADED, Notifications.HSCROLL, 
				Notifications.GRID_CELL_SELECTED, Notifications.RESET_APP ];
		}
		
		override public function handleNotification( notification:INotification ) : void
		{
			switch( notification.getName() )
			{
				case Notifications.PART_TYPE_FIELDS_LOADED:
//					var fields:ArrayCollection = notification.getBody() as ArrayCollection;
					var entryFields:EntryFields = notification.getBody() as EntryFields;
					this.gridHeaderHolder.headerRowCollection = entryFields.fields;
				break;
				
				case Notifications.HSCROLL:
					var event:GridScrollEvent = notification.getBody() as GridScrollEvent;
					this.gridHeaderHolder.headerRow.x = event.delta; 
				break;
				
				case Notifications.GRID_CELL_SELECTED:
					var cells:ArrayCollection = notification.getBody() as ArrayCollection;
					this.gridHeaderHolder.headerRow.activeSelection( cells );
					break;
				
				case Notifications.RESET_APP:
					this.gridHeaderHolder.headerRow.x = 0;
					this.gridHeaderHolder.headerRow.reset();
					break;
			}
		}
		
		public function typeFieldForCell( cell:GridCell ) : EntryTypeField
		{
			var header:GridColumnHeader = headerFields.getItemAt( cell.index ) as GridColumnHeader;
			if( header == null )
			{
				trace( "ImportPanelMediator: no header collection available" );
				return null
			}
			
			var typeField:EntryTypeField = header.typeField;
			return typeField;
		}
		
		private function get headerFields() : ArrayCollection
		{
			return this.gridHeaderHolder.headerRow.headers;
		}
	}
}