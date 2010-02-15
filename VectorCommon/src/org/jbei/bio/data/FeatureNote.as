package org.jbei.bio.data
{
	public class FeatureNote
	{
		private var _name:String;
		private var _value:String;
		
		// Constructor
		public function FeatureNote(name:String, value:String)
		{
			_name = name;
			_value = value;
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
		
		public function get value():String
		{
			return _value;
		}
		
		public function set value(value:String):void
		{
			_value = value;
		}
		
		// Public Methods
		public function clone():FeatureNote
		{
			return new FeatureNote(_name, _value);
		}
		
		public function toString():String
		{
			return _name + "=" + _value;
		}
	}
}
