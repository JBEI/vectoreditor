package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.EntryFundingSource")]
	public class EntryFundingSource
	{
		private var _id:int;
		private var _fundingSource:FundingSource;
		private var _entry:Entry;
		
		// Constructor
		public function EntryFundingSource(fundingSource:FundingSource = null)
		{
			_fundingSource = fundingSource;
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
		
		public function get fundingSource():FundingSource
		{
			return _fundingSource;
		}
		
		public function set fundingSource(value:FundingSource):void
		{
			_fundingSource = value;
		}
		
		public function get entry():Entry
		{
			return _entry;
		}
		
		public function set entry(value:Entry):void
		{
			_entry = value;
		}
	}
}
