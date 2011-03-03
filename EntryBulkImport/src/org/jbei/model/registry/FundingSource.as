package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.FundingSource")]
	public class FundingSource
	{
		private var _id:Number;
		private var _fundingSource:String;
		private var _principalInvestigator:String;
		
		public function get id() : Number
		{
			return this._id;
		}
		
		public function set id( id:Number ) : void
		{
			this._id = id;
		}
								
		public function get fundingSource() : String
		{
			return this._fundingSource;
		}
		
		public function set fundingSource( fundingSource:String ) : void
		{
			this._fundingSource = fundingSource;
		}		
		
		public function get principalInvestigator() : String
		{
			return this._principalInvestigator;
		}
		
		public function set principalInvestigator( principalInvestigator:String ) : void
		{
			this._principalInvestigator = principalInvestigator;
		}
	}
}