package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.Name")]
    /**
     * @author Zinovii Dmytriv
     */
	public class Name
	{
		private var _name:String;
		
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
		
		// Public Methods
		public function toString():String
		{
			return _name;
		}
	}
}
