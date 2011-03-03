package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.Attachment")]
	public class Attachment
	{
		private var _id:Number;
		private var _description:String;
		private var _fileName:String;
		private var _fileId:String;
		private var _entry:Entry;
		
		public function Attachment() 
		{
		}
		
		public function get id() : Number
		{
			return this._id; 
		}
		
		public function set id( id:Number ) : void
		{
			this._id = id;
		}
		
		public function get description() : String
		{
			return this._description;
		}
		
		public function set description( description:String ) : void
		{
			this._description = description;
		}
		
		public function get fileName() : String
		{
			return this._fileName;
		}
		
		public function set fileName( fileName:String ) : void
		{
			this._fileName = fileName;
		}
		
		public function get fileId() : String
		{
			return this._fileId;
		}
		
		public function set fileId( fileId:String ) : void
		{
			this._fileId = fileId;
		}
		
		public function set entry( entry:Entry ) : void
		{
			this._entry = entry;
		}
		
		public function get entry() : Entry
		{
			return this._entry;
		}
	}
}