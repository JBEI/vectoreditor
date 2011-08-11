package org.jbei.model.save
{
	import flash.utils.ByteArray;
	
	import mx.rpc.remoting.RemoteObject;
	
	import org.jbei.model.registry.Entry;

	[RemoteObject(alias="org.jbei.ice.lib.utils.BulkImportEntryData")]
	public class BulkImportEntryData
	{
		private var _entry:Entry;
		private var _sequenceFilename:String;
		private var _attachmentFilename:String;
		
		public function BulkImportEntryData()
		{
		}
		
		public function get sequenceFilename() : String
		{
			return this._sequenceFilename;
		}
		
		public function set sequenceFilename( name:String ) : void
		{
			this._sequenceFilename = name;
		}
		
		public function get entry() : Entry 
		{
			return this._entry;
		}
		
		public function set entry( entry:Entry ) : void
		{
			this._entry = entry;
		}
		
		public function get attachmentFilename() : String 
		{
			return this._attachmentFilename;
		}
		
		public function set attachmentFilename( name:String ) : void
		{
			this._attachmentFilename = name;
		}
	}
}