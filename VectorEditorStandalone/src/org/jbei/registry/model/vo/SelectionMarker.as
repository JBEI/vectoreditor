package org.jbei.registry.model.vo
{
	[RemoteClass(alias="org.jbei.registry.lib.models.SelectionMarker")]
	public class SelectionMarker
	{
		private var _id:int;
		private var _name:String;
		
		// Constructor
		public function SelectionMarker(name:String = null)	
		{
			_name = name;
		}
		
		// Properties
		public function get id():int
		{
			return _id;
		}
		
		public function set id(value:int):void	
		{
			_id = value;
		}
		
		public function get name():String	
		{
			return _name;
		}
		
		public function set name(value:String):void	
		{
			_name = value;
		}
	}
}
