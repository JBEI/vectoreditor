package org.jbei.registry.models
{
	[RemoteClass(alias="org.jbei.ice.lib.vo.DNAFeatureNote")]
	public class DNAFeatureNote
	{
		private var _name:String;
		private var _value:String;
		
		public function DNAFeatureNote(name:String, aValue:String)
		{
			_name = name;
			_value = aValue;
		}
		
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
		
		public function set value(aValue:String):void
		{
			_value = aValue;
		}
	}
}