package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.EntryFundingSource")]
	public class EntryFundingSource
	{
		private var _id:Number;
		private var _fundingSource:FundingSource;
		private var _entry:Entry;
		
		public function get id() : Number
		{
			return this._id;
		}
		
		public function set id( id:Number ) : void
		{
			this._id = id;
		}
		
		public function get fundingSource() : FundingSource
		{
			return this._fundingSource;
		}
		
		public function set fundingSource( fundingSource:FundingSource ) : void
		{
			this._fundingSource = fundingSource;
		}
		
		public function get entry() : Entry
		{
			return this._entry;
		}
		
		public function set entry( entry:Entry ) : void
		{
			this._entry = entry;
		}
	}
}