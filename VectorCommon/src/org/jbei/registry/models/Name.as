package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.Name")]
	public class Name
	{
		private var _name:String;
		private var _entry:Entry;
		
		// Constructor
		public function Name(name:String = "")
		{
			_name = name;
		}
		
		// Properties
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void	
		{
			_name = value;
		}
		
		public function get entry():Entry
		{
			return _entry;
		}
		
		public function set entry(value:Entry):void	
		{
			_entry = value;
		}
		
		// Public Methods
		public function toString():String
		{
			return _name;
		}
	}
}
