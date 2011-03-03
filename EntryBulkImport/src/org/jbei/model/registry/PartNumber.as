package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.PartNumber")]
	public class PartNumber
	{
		private var _id:Number;
		private var _partNumber:String;
		private var _entry:Entry;
		
		public function PartNumber()
		{
		}
		
		public function get id() : Number
		{
			return this._id
		}
		
		public function set id( id:Number ) : void
		{
			this._id = id; 
		}
		
		public function get partNumber() : String
		{
			return this._partNumber
		}
		
		public function set partNumber( partNumber:String ) : void
		{
			this._partNumber = partNumber; 
		}
		
		public function get entry() : Entry
		{
			return this._entry
		}
		
		public function set entry( entry:Entry ) : void
		{
			this._entry = entry; 
		}
	}
}