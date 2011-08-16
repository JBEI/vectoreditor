package org.jbei.model
{
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Grid;
	import mx.controls.Alert;
	
	import org.jbei.Notifications;
	import org.jbei.model.fields.EntryFields;
	import org.jbei.model.fields.EntryFieldsFactory;
	import org.jbei.model.fields.FieldCellError;
	import org.jbei.model.registry.Entry;
	import org.jbei.model.save.EntrySet;
	import org.jbei.view.EntryType;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.GridHolder;
	import org.jbei.view.components.GridRow;
	import org.jbei.view.mediators.FileUploaderMediator;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ValueExtractorProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "org.jbei.model.ValueExtractorProxy";
		
		private var _missingRequired:Boolean = false;			
		
		public function ValueExtractorProxy()
		{
			super( NAME );
		}
		
		protected function zipContainsSequenceFilename( fileName:String ) : Boolean
		{
			return false;
		}
		
		public function retrieveValues( gridHolder:GridHolder, entryType:EntryType ) : EntrySet
		{
			if( entryType == null )
			{
				return null;
			}
			
			var errors:Boolean = false;									// if any errors were encountered when extracting
			var fields:ArrayCollection = gridHolder.gridFields;
			var rowCellCount:int = gridHolder.grid.rowCellCount;		// number of cells in each row
			var rowCount:int = gridHolder.grid.rowSize();		 		// number of rows in the grid
			var gridRows:ArrayCollection = gridHolder.grid.rows; 		// arrayCollection of GridRows
			var length:int = fields.length;
			
			var entryFields:EntryFields = EntryFieldsFactory.fieldsForType( entryType );
			var mediator:FileUploaderMediator = facade.retrieveMediator( FileUploaderMediator.NAME ) as FileUploaderMediator;
			var entrySet:EntrySet = entryFields.entrySet;
            
            entryFields.setZipFiles( mediator.fileUploader.attachmentZip, mediator.fileUploader.attachmentZipName, 
                mediator.fileUploader.sequenceZip, mediator.fileUploader.sequenceZipName );
            
			// for each row in the grid 
			for( var i:int = 0; i < rowCount; i += 1 )
			{
				var gridRow:GridRow = gridRows.getItemAt( i ) as GridRow;
               
				// skip all rows that do not have any content across all cells
				if( !this.rowHasContent( rowCellCount, gridRow ) )
					continue;
				
				// extract and validate the field (column) values
				var result:Object = entryFields.extractFromRow( gridRow );
                
				// check for errors and send notification of any
				if( entryFields.errors && entryFields.errors.length > 0 )
				{
					for( var j:int = 0; j < entryFields.errors.length; j += 1 )
					{
						var error:FieldCellError = entryFields.errors.getItemAt( j ) as FieldCellError;
						sendNotification( Notifications.INVALID_CELL_CONTENT, error.cell, error.errorMessage );
					}

					errors = true;
					continue;
				}
				else
				{
					if( errors )
						continue;
					
					entrySet.addToSet( result );
				}
			}
			
			if( errors )
				return null;
            
			return entrySet;
		}
		
		private function rowHasContent( rowCellCount:int, row:GridRow ) : Boolean
		{
			for( var j:int = 0; j<rowCellCount; j += 1 )
			{
				var cell:GridCell = row.cellAt( j );
				if( cell.text != null && cell.text.length > 0 )
					return true;
			}
			
			return false;
		}
	}
}