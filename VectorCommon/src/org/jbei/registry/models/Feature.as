package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.Feature")]
	public class Feature
	{
		private var _id:int;
		private var _name:String;
		private var _description:String;
		private var _identification:String;
		private var _uuid:String;
		private var _autoFind:int;
		private var _genbankType:String;
		private var _featureDna:FeatureDNA;
		
		// Constructor
		public function Feature(name:String = null, description:String = null, identification:String = null, uuid:String = null, autoFind:int = 0, genbankType:String = null, featureDNA:FeatureDNA = null)
		{
			_name = name;
			_description = description;
			_identification = identification;
			_uuid = uuid
			_autoFind = autoFind;
			_genbankType = genbankType;
			_featureDna = featureDna;
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
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void	
		{
			_name = value;
		}
		
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String):void	
		{
			_description = value;
		}
		
		public function get identification():String
		{
			return _identification;
		}
		
		public function set identification(value:String):void	
		{
			_identification = value;
		}
		
		public function get uuid():String
		{
			return _uuid;
		}
		
		public function set uuid(value:String):void	
		{
			_uuid = value;
		}
		
		public function get autoFind():int
		{
			return _autoFind;
		}
		
		public function set autoFind(value:int):void	
		{
			_autoFind = value;
		}
		
		public function get genbankType():String
		{
			return _genbankType;
		}
		
		public function set genbankType(value:String):void	
		{
			_genbankType = value;
		}
		
		public function get featureDna():FeatureDNA
		{
			return _featureDna;
		}
		
		public function set featureDna(value:FeatureDNA):void	
		{
			_featureDna = value;
		}
	}
}
