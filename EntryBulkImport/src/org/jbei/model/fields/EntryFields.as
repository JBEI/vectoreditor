package org.jbei.model.fields
{
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.save.EntrySet;
	import org.jbei.view.components.GridRow;

	public interface EntryFields
	{	
		function get fields() : ArrayCollection;		 // <EntryTypeField>
		
		function extractFromRow( row:GridRow ) : Object; // <Entry> or <StrainWithPlasmid>
		
		/**
		 * set the row values from the index 
		 * @return true is set successful, false otherwise. False can occur if, for
		 * e.g. entrySet.getItemAt( currentIndex ) throws an IndexOutBoundsException
		 */
		function setToRow( currentRowIndex:int, currentRow:GridRow ) : Boolean;
		
		// ignore if you do not use zip files
		function set sequenceZipFile( file:FileReference ) : void;
		function set attachmentZipFile( file:FileReference ) : void; 
		
		function get errors() : ArrayCollection;		// <FieldCellError>
		
		// this is meant to only return an instance of entryset
		function get entrySet() : EntrySet;			
	}
}