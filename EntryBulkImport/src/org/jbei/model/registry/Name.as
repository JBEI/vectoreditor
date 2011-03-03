package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.Name")]
	public class Name
	{
		private var _id:Number;
		private var _name:String;
		private var _entry:Entry;
		
		public function get id() : Number
		{
			return this._id;
		}
		
		public function set id( id:Number ) : void
		{
			this._id = id;
		}
		
		public function get name() : String
		{
			return this._name;
		}
		
		public function set name( name:String ) : void
		{
			this._name = name;
		}
		
		public function get entry() : Entry
		{
			return this._entry;
		}
		
		public function set entry( entry:Entry ) : void
		{
			this._entry = entry;
		}
	}
}