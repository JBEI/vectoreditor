package org.jbei.view.mediators
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.NotificationTypes;
	import org.jbei.Notifications;
	import org.jbei.events.GridCellEvent;
	import org.jbei.events.GridEvent;
	import org.jbei.events.GridScrollEvent;
	import org.jbei.model.BulkImportVerifierProxy;
	import org.jbei.model.GridPaste;
	import org.jbei.model.RegistryAPIProxy;
	import org.jbei.model.SaveWrapper;
	import org.jbei.model.ValueExtractorProxy;
	import org.jbei.model.fields.EntryFields;
	import org.jbei.model.fields.EntryFieldsFactory;
	import org.jbei.model.registry.Entry;
	import org.jbei.model.save.BulkImportEntryData;
	import org.jbei.model.save.EntrySet;
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
		private var currentTypeSelection:EntryType = EntryType.STRAIN;
		
		// problem this tries to resolve is that having fields loaded (for each entry type: strain etc)
		// and having the autocomplete
		private var _dataCollection:ArrayCollection = null;	// list of values that are loaded from importId passed as parameter
		
		public function ImportPanelMediator( importPanel:ImportMainPanel )
		{
			super( NAME, importPanel );			
			this.importPanel.createGrid();
			
			// event listeners
			this.importPanel.addEventListener( GridCellEvent.TEXT_CHANGE, cellChange );
			this.importPanel.addEventListener( GridScrollEvent.HSCROLL, hScroll );
			this.importPanel.addEventListener( GridScrollEvent.VSCROLL, vScroll );
			this.importPanel.addEventListener( GridCellEvent.PASTE, paste );
			this.importPanel.addEventListener( GridEvent.ROW_ADDED, rowAdded );
			this.importPanel.addEventListener( GridEvent.CELLS_SELECTED, cellsSelected );
			
			// check if we are verifying
			if( ApplicationFacade.getInstance().importId != null )
			{
				// retrieve the grid data
				var importId:String = ApplicationFacade.getInstance().importId;
				var verifierProxy:BulkImportVerifierProxy = facade.retrieveProxy( BulkImportVerifierProxy.NAME ) as BulkImportVerifierProxy;
				verifierProxy.retrieveData( importId );
			}			
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
			return [ Notifications.HEADER_INPUT_TEXT_CHANGE, Notifications.SAVE_CLICK, Notifications.PASTE_CELL_DISTRIBUTION, 
				Notifications.PART_TYPE_SELECTION, Notifications.INVALID_CELL_CONTENT, Notifications.RESET_APP, Notifications.GRID_ROW_SELECTED, Notifications.VERIFY ];
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
				
				case Notifications.SAVE_CLICK:
					// TODO : Have a save error param and send out a separate notification type with details
					// handle it in the SaveCommand
					
					var proxy:ValueExtractorProxy = facade.retrieveProxy( ValueExtractorProxy.NAME ) as ValueExtractorProxy;	
					var entrySet:EntrySet = proxy.retrieveValues( this.importPanel.gridHolder, currentTypeSelection );
					if( entrySet != null ) 
					{
						if( entrySet.entries == null || entrySet.entries.length == 0 )
							Alert.show( "Please fill out at least one row.", "No Records" );
						else								
							sendNotification( Notifications.SAVE, entrySet );
					}
					else
						Alert.show( "Please fix any validation errors before proceeding", "Error Saving" );
					break;
				
				case Notifications.PASTE_CELL_DISTRIBUTION:
					var gridPaste:GridPaste = notification.getBody() as GridPaste;
					this.importPanel.pasteIntoCells( gridPaste );
					break;
				
				case Notifications.PART_TYPE_SELECTION:
					handlePartTypeSelection( notification );
					break;
				
				case Notifications.INVALID_CELL_CONTENT:
					var cell:GridCell = notification.getBody() as GridCell;
					var msg:String = notification.getType();
					cell.errorFill( msg );
					break;
				
				case Notifications.GRID_ROW_SELECTED:
					var index:Number = notification.getBody() as Number;
					var additive:Boolean = ( notification.getType() == NotificationTypes.ADDITIVE );
					importPanel.gridHolder.selectRow( index, additive );
					break;
				
				case Notifications.VERIFY:
					handleVerify( notification );
					break;
				
				default:
					Alert.show( "No handler in ImportPanelMediator for nofication: " + notification.getName() );
			}
		}
		
		// NOTIFICATION HANDLER METHODS	
		protected function handlePartTypeSelection( notification:INotification ) : void
		{
			var selected:EntryType = notification.getBody() as EntryType;
			this.currentTypeSelection = selected;			
			
			if( _dataCollection != null && _dataCollection.length > 0 ) 
			{
				var entryFields1:EntryFields = EntryFieldsFactory.fieldsForType( this.currentTypeSelection );
				this.importPanel.gridFields = entryFields1.fields;
				this.importPanel.setCellValues( _dataCollection );
			}
			else
			{				
				var entryFields:EntryFields = EntryFieldsFactory.fieldsForType( this.currentTypeSelection );
				this.importPanel.gridFields = entryFields.fields;
				this.importPanel.gridHolder.reset();
			}
		}
		
		protected function handleVerify( notification:INotification ) : void 
		{
			var gridPaste:GridPaste = new GridPaste( 0, 0 );
			var results:Object = notification.getBody();	
			
			// type
			var type:String = results.type as String;			
			var entryType:EntryType = EntryType.valueOf( type );
			if( entryType == null ) 
			{
				Alert.show( "Could not deal with record type: " + type );
				return;
			}
			
			var primaryCollection:ArrayCollection = new ArrayCollection();		// <EntryFields>
			
			// need to get both at the same time
			var primaryData:ArrayCollection = results.primaryData as ArrayCollection;	
			var secondaryData:ArrayCollection = results.secondaryData as ArrayCollection;
			
			for( var x:int = 0; x < primaryData.length; x += 1 )
			{
				// primary data
				var obj:Object = primaryData.getItemAt( x );
				var entry:Entry = obj.entry as Entry;
				var fields:EntryFields = EntryFieldsFactory.fieldsForType( entryType );
				var fieldsEntrySet:EntrySet = fields.entrySet;
				
				// TODO 
				// secondary data
				if( secondaryData != null && secondaryData.length > 0 )
				{
					var obj2:Object = secondaryData.getItemAt( x );
					var entry2:Entry = obj2.entry as Entry;			// this should be a plasmid
					var col:ArrayCollection = new ArrayCollection();
					col.addItem( entry );
					col.addItem( entry2 );
					fieldsEntrySet.addToSet( col );
				} 
				else 
				{
					fieldsEntrySet.addToSet( entry );
				}
				
				// TODO : need to do something with this
				// individual row filenames that are contained in zip file (if any)
				var attFilename:String = obj.attachmentFilename as String;
				var seqFilename:String = obj.sequenceFilename as String;
				
				primaryCollection.addItem( fields );
			}
			
			if( primaryCollection.length > 0 ) {
				this._dataCollection = primaryCollection;
			}
		}
	}
}