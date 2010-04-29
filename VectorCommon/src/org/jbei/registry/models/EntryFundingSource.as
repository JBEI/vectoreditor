package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.EntryFundingSource")]
	public class EntryFundingSource
	{
		private var _fundingSource:FundingSource;
		
		// Constructor
		public function EntryFundingSource(fundingSource:FundingSource = null)
		{
			_fundingSource = fundingSource;
		}
		
		// Properties
		public function get fundingSource():FundingSource
		{
			return _fundingSource;
		}
		
		public function set fundingSource(value:FundingSource):void
		{
			_fundingSource = value;
		}
	}
}
