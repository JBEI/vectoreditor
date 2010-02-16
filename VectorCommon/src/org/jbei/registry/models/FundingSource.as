package org.jbei.registry.models
{
	[RemoteClass(alias="org.jbei.ice.lib.models.FundingSource")]
	public class FundingSource
	{
		private var _id:int;
		
		private var _fundingSource:String;
		
		private var _principalInvestigator:String;
		
		// Constructor
		public function FundingSource()
		{
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
		
		public function get principalInvestigator():String
		{
			return _principalInvestigator;
		}
		
		public function set principalInvestigator(value:String):void	
		{
			_principalInvestigator = value;
		}
		
		public function get fundingSource():String
		{
			return _fundingSource;
		}
		
		public function set fundingSource(value:String):void	
		{
			_fundingSource = value;
		}
	}
}