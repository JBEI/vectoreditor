package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.PartNumber")]
	public class PartNumber
	{
		private var _partNumber:String;
		
		// Constructor
		public function PartNumber(partNumber:String = null)	
		{
			_partNumber = partNumber;
		}
		
		// Properties
		public function get partNumber():String	
		{
			return _partNumber;
		}
		
		public function set partNumber(value:String):void	
		{
			_partNumber = value;
		}
		
		// Public Methods
		public function toString():String
		{
			return _partNumber;
		}
	}
}
