package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.FundingSource")]
    /**
     * @author Zinovii Dmytriv
     */
	public class FundingSource
	{
		private var _fundingSource:String;
		private var _principalInvestigator:String;
		private var _entryFundingSources:ArrayCollection; /* EntryFundingSource */
		
		// Constructor
		public function FundingSource(fundingSource:String = null, principalInvestigator:String = null, entryFundingSources:ArrayCollection = null)
		{
			_fundingSource = fundingSource;
			_principalInvestigator = principalInvestigator;
			_entryFundingSources = entryFundingSources;
		}
		
		// Properties
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
		
		public function get entryFundingSources():ArrayCollection
		{
			return _entryFundingSources;
		}
		
		public function set entryFundingSources(value:ArrayCollection):void	
		{
			_entryFundingSources = value;
		}
	}
}