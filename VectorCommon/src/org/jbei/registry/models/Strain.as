package org.jbei.registry.models
{
	[RemoteClass(alias="org.jbei.ice.lib.models.Strain")]
	public class Strain extends Entry
	{
		private var _host:String;
		private var _genotypePhenotype:String;
		private var _plasmids:String;
		
		// Properties
		public function get host():String
		{
			return _host;
		}
		
		public function set host(value:String):void	
		{
			_host = value;
		}
		
		public function get genotypePhenotype():String
		{
			return _genotypePhenotype;
		}
		
		public function set genotypePhenotype(value:String):void	
		{
			_genotypePhenotype = value;
		}
		
		public function get plasmids():String
		{
			return _plasmids;
		}
		
		public function set plasmids(value:String):void
		{
			_plasmids = value;
		}
	}
}
