package org.jbei.registry.model
{
	[RemoteClass(alias="org.jbei.ice.lib.models.Plasmid")]
	public class Plasmid extends Entry
	{
		private var _backbone:String;
		private var _originOfReplication:String;
		private var _promoters:String;
		private var _circular:Boolean;
		
		// Properties
		public function get backbone():String
		{
			return _backbone;
		}
		
		public function set backbone(value:String):void	
		{
			_backbone = value;
		}
		
		public function get originOfReplication():String
		{
			return _originOfReplication;
		}
		
		public function set originOfReplication(value:String):void	
		{
			_originOfReplication = value;
		}
		
		public function get promoters():String
		{
			return _promoters;
		}
		
		public function set promoters(value:String):void	
		{
			_promoters = value;
		}
		
		public function get circular():Boolean
		{
			return _circular;
		}
		
		public function set circular(value:Boolean):void	
		{
			_circular = value;
		}
	}
}
