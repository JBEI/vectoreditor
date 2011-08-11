package org.jbei.model.save
{
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.view.EntryType;

	public class EntrySet
	{
		private var _type:EntryType;
		private var _errMsg:String;
		
		protected var _seqZip:FileReference;
		protected var _attZip:FileReference;
		
		protected var _records:ArrayCollection = new ArrayCollection; // <? implements Entry>
		
		public function set sequenceZipfile( file:FileReference ) : void
		{
			this._seqZip = file;
		}
		
		public function get sequenceZipfile() : FileReference
		{
			return this._seqZip;
		}
		
		public function set attachmentZipfile( file:FileReference ) : void
		{
			this._attZip = file;
		}	
		
		public function get attachmentZipfile() : FileReference
		{
			return this._attZip;
		}
		
		public function EntrySet( type:EntryType ) 
		{
			this._type = type;
		}
		
		public function get type() : EntryType
		{
			return this._type;
		}
		
		public function get recordCount() : Number 
		{ 
			return _records.length; 
		}
		
		public function get entries() : ArrayCollection
		{
			return this._records;
		}
		
		// Override the following functions
		public function addToSet( obj:Object ) : void {}
	}
}