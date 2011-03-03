package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.Plasmid")]
	public class Plasmid extends Entry
	{
		private var _backbone:String;
		private var _originOfReplication:String;
		private var _circular:Boolean;
		private var _promoters:String;
		
		public function Plasmid()
		{
		}
		
		public function get promoters() : String
		{
			return this._promoters;
		}
		
		public function set promoters( promoters:String ) : void
		{
			this._promoters = promoters;
		}
		
		public function get backbone() : String
		{
			return this._backbone;
		}
		
		public function set backbone( backbone:String ) : void
		{
			this._backbone = backbone;
		}
		
		public function get originOfReplication() : String
		{
			return this._originOfReplication;
		}
		
		public function set originOfReplication( origin:String ) : void
		{
			this._originOfReplication = origin;
		}
		
		public function get circular() : Boolean
		{
			return this._circular;
		}
		
		public function set circular( circular:Boolean ) : void
		{
			this._circular = circular;
		}
	}
}