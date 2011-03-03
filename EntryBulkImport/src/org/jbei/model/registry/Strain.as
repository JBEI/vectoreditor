package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.Strain")]
	public class Strain extends Entry
	{
		private var _genotypePhenotype:String;
		private var _host:String;
		private var _plasmids:String;		
		
		public function Strain()
		{
			super();
		}
		
		public function get plasmids() : String
		{
			return this._plasmids;
		}
		
		public function set plasmids( plasmids:String ) : void
		{
			this._plasmids = plasmids;
		}
		
		public function get genotypePhenotype() : String
		{
			return this._genotypePhenotype;
		}
		
		public function set genotypePhenotype( type:String ) : void
		{
			this._genotypePhenotype = type;
		}
		
		public function get host() : String
		{
			return this._host;
		}
		
		public function set host( host:String ) : void
		{
			this._host = host;
		}
	}
}