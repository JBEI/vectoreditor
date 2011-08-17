package org.jbei.model.fields
{
	import deng.fzip.FZip;
	
	import flash.utils.ByteArray;
	
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
		 * e.g. entrySet.getItemAt( currentIndex ) 
		 */
		function setToRow( currentRowIndex:int, currentRow:GridRow ) : Boolean;
        
        function setZipFiles( attBytes:ByteArray, att:FZip, attName:String, seqByte:ByteArray, seq:FZip, seqName:String ) : void;        
		
		function get errors() : ArrayCollection;		// <FieldCellError>
		
		// this is meant to only return an instance of entryset
		function get entrySet() : EntrySet;			
	}
}