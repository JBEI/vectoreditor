package org.jbei.model
{
	import mx.utils.OnDemandEventDispatcher;
	
	import org.jbei.model.registry.Plasmid;
	import org.jbei.model.registry.Strain;
	
	public class StrainWithPlasmid
	{
		private var _strain:Strain;
		private var _plasmid:Plasmid;
		
		public function StrainWithPlasmid( strain:Strain, plasmid:Plasmid )
		{
			this._strain = strain;
			this._plasmid = plasmid;
		}
		
		// savedPlasmid is this._plasmid saved to registry
		public function setStrainPlasmids( savedPlasmid:Plasmid ) : void
		{
			var plasmidPartNumberString:String = "[[jbei:" + savedPlasmid.onePartNumber.partNumber + 
				"|" + savedPlasmid.oneName.name + "]]";
			this._strain.plasmids = plasmidPartNumberString;
		}
		
		// getters
		
		public function get plasmid() : Plasmid 
		{
			return this._plasmid;
		}
		
		public function get strain() : Strain
		{
			return this._strain;
		}
	}
}
