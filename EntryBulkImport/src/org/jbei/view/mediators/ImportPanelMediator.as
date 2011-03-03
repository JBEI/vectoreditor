package org.jbei.view.mediators
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.NotificationTypes;
	import org.jbei.Notifications;
	import org.jbei.events.GridCellEvent;
	import org.jbei.events.GridEvent;
	import org.jbei.events.GridScrollEvent;
	import org.jbei.model.GridPaste;
	import org.jbei.model.SaveWrapper;
	import org.jbei.model.ValueExtractorProxy;
	import org.jbei.model.fields.EntryFields;
	import org.jbei.model.registry.Entry;
	import org.jbei.model.util.EntryFieldUtils;
	import org.jbei.view.EntryType;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.GridColumnHeader;
	import org.jbei.view.components.ImportMainPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.patterns.observer.Notification;

	// TODO : eventually this needs to be split into multiple mediators 
	
	public class ImportPanelMediator extends Mediator
	{
		private static const NAME : String = "org.jbei.view.ImportPanelMediator";
		private var currentTypeSelection:EntryType;
		
		public function ImportPanelMediator( importPanel:ImportMainPanel )
		{
			super( NAME, importPanel );
			
			// event listeners
			this.importPanel.addEventListener( GridCellEvent.TEXT_CHANGE, cellChange );
			this.importPanel.addEventListener( GridScrollEvent.HSCROLL, hScroll );
			this.importPanel.addEventListener( GridScrollEvent.VSCROLL, vScroll );
			this.importPanel.addEventListener( GridCellEvent.PASTE, paste );
			this.importPanel.addEventListener( GridEvent.ROW_ADDED, rowAdded );
			this.importPanel.addEventListener( GridEvent.CELLS_SELECTED, cellsSelected );
		}
		
		protected function get importPanel() : ImportMainPanel
		{
			return this.viewComponent as ImportMainPanel;
		}
		
		// EVENT HANDLERS
		
		private function rowAdded( event:GridEvent ) : void
		{
			sendNotification( Notifications.ROW_CREATED, event );
		}
		
		private function paste( event:GridCellEvent ) : void
		{
			sendNotification( Notifications.PASTE, event );
		}

		private function hScroll( event:GridScrollEvent ) : void
		{
			sendNotification( Notifications.HSCROLL, event );
		}
		
		private function vScroll( event:GridScrollEvent ) : void
		{
			sendNotification( Notifications.VSCROLL, event );
		}
		
		private function cellsSelected( event:GridEvent ) : void
		{
			sendNotification( Notifications.GRID_CELL_SELECTED, event.cells );
		}
		
		private function cellChange( event:GridCellEvent ) : void
		{
			sendNotification( Notifications.ACTIVE_GRID_CELL_TEXT_CHANGE, event.cell );
		}
		
		override public function listNotificationInterests() : Array
		{
			return [ Notifications.HEADER_INPUT_TEXT_CHANGE, Notifications.PART_TYPE_FIELDS_LOADED, 
				Notifications.SAVE_CLICK, Notifications.PASTE_CELL_DISTRIBUTION, Notifications.PART_TYPE_SELECTION, 
				Notifications.INVALID_CELL_CONTENT, Notifications.RESET_APP, Notifications.AUTO_COMPLETE_DATA, 
				Notifications.GRID_ROW_SELECTED ];
		}
		
		// called on when any of the notifications above is sent 
		override public function handleNotification( notification:INotification ) : void
		{
			switch( notification.getName() )
			{
				case Notifications.RESET_APP:
					this.importPanel.resetGridHolder();
					break;
				
				case Notifications.HEADER_INPUT_TEXT_CHANGE:
					var text:String = notification.getBody() as String;
					if( !importPanel.activeGridCell.inEditMode )
						importPanel.activeGridCell.switchToEditMode();
					
					importPanel.activeGridCell.text = text;
					break;
				
				case Notifications.PART_TYPE_FIELDS_LOADED:
					var entryFields:EntryFields = notification.getBody() as EntryFields;
					this.importPanel.gridFields = entryFields.fields;
					break;
				
				case Notifications.SAVE_CLICK:
					// TODO : Have a save error param and send out a separate notification type with details
					// handle it in the SaveCommand
					
					var proxy:ValueExtractorProxy = facade.retrieveProxy( ValueExtractorProxy.NAME ) as ValueExtractorProxy;	
					var entrySet:EntrySet = proxy.retrieveValues( this.importPanel.gridHolder, currentTypeSelection );
					if( entrySet != null )
						sendNotification( Notifications.SAVE, entrySet );
					break;
				
				case Notifications.PASTE_CELL_DISTRIBUTION:
					var gridPaste:GridPaste = notification.getBody() as GridPaste;
					this.importPanel.pasteIntoCells( gridPaste );
					break;
				
				case Notifications.PART_TYPE_SELECTION:
					var selected:EntryType = notification.getBody() as EntryType;
					currentTypeSelection = selected;
					this.importPanel.gridHolder.reset();
					break;
				
				case Notifications.INVALID_CELL_CONTENT:
					var cell:GridCell = notification.getBody() as GridCell;
					var msg:String = notification.getType();
					cell.errorFill( msg );
					break;
				
				// auto complete data. grid is created when all are loaded
				case Notifications.AUTO_COMPLETE_DATA:
					this.importPanel.gridHolder.createGrid();
					break;
				
				case Notifications.GRID_ROW_SELECTED:
					var index:Number = notification.getBody() as Number;
					var additive:Boolean = ( notification.getType() == NotificationTypes.ADDITIVE );
					importPanel.gridHolder.selectRow( index, additive );
					break;
			}
		}
	}
}