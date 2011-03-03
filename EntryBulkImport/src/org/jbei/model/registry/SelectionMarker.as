package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.SelectionMarker")]
	public class SelectionMarker
	{
		private var _name:String;
		private var _entry:Entry;
		
		public function SelectionMarker()
		{
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