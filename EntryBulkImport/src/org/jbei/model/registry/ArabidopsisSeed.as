package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.ArabidopsisSeed")]
	public class ArabidopsisSeed extends Entry
	{
		private var _generation:String;
		private var _homozygosity:String;
		private var _ecotype:String;
		private var _harvestDate:Date;
		private var _parents:String;
		private var _plantType:String;
		
		public function ArabidopsisSeed()
		{
			super();
		}
		
		public function get harvestDate() : Date
		{
			return this._harvestDate;
		}
		
		public function set harvestDate( value:Date ) : void
		{
			this._harvestDate = value;
		}
		
		public function get generation() : String
		{
			return this._generation;	
		}
		
		public function set generation( value:String ) : void
		{
			this._generation = value;	
		}
		
		public function get homozygosity () : String
		{
			return this._homozygosity;	
		}
		
		public function set homozygosity( value:String ) : void
		{
			this._homozygosity = value;
		}
		
		public function get ecotype() : String
		{
			return this._ecotype;
		}
		
		public function set ecotype( value:String ) : void
		{
			this._ecotype = value;
		}
		
		public function get plantType() : String
		{
			return this._plantType;
		}
		
		public function set plantType( value:String ) : void
		{
			this._plantType = value;
		}
		
		public function get parents() : String
		{
			return this._parents;
		}
		
		public function set parents( value:String ) : void
		{
			this._parents = value;
		}
	}
}