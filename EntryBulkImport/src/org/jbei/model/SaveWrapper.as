package org.jbei.model
{
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;

	public class SaveWrapper
	{
		private var _entries:ArrayCollection;			// <Entry>
		private var _sequences:ArrayCollection;			// <Sequence>
		private var _attachments:ArrayCollection;		// <Attachment>
		private var _zip:ByteArray;
		private var _filename:String;
		private var _attachmentZip:ByteArray;
		
		// specific entry types
		private var _plasmidWithStrains:StrainWithPlasmid
		
		public function SaveWrapper()
		{
		}
		
		public function set entries( entries:ArrayCollection ) : void
		{
			this._entries = entries;
		}
		
		public function get entries() : ArrayCollection
		{
			return this._entries;
		}
		
		public function get sequences() : ArrayCollection
		{
			return this._sequences;
		}
		
		public function set sequences( sequences:ArrayCollection ) : void
		{
			this._sequences = sequences;
		}
		
		public function get attachments() : ArrayCollection
		{
			return this._attachments;
		}
		
		public function set attachments( attachments:ArrayCollection ) : void
		{
			this._attachments = attachments;
		}
		
		public function set zipFile( bytes:ByteArray ) : void
		{
			this._zip = bytes;
		}
		
		public function get zip() : ByteArray
		{
			return this._zip;
		}
		
		public function set attachmentZip( bytes:ByteArray ) : void
		{
			this._attachmentZip = bytes;
		}
		
		public function get attachmentZip() : ByteArray
		{
			return this._attachmentZip;
		}
		
		public function get filename() : String
		{
			return this._filename;
		}
		
		public function set filename( name:String ) : void
		{
			this._filename = name;
		}
	}
}