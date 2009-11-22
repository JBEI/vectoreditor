package org.jbei.bio.data
{
	public class AminoAcid
	{
		private var _name:String;
		private var _name1:String;
		private var _name3:String;
		
		// Constructor
		public function AminoAcid(name:String, name3:String, name1:String)
		{
			_name = name;
			_name1 = name1;
			_name3 = name3;
		}
		
		// Properties
		public function get name():String
		{
			return _name;
		}
		
		public function get name1():String
		{
			return _name1;
		}
		
		public function get name3():String
		{
			return _name3;
		}
	}
}
