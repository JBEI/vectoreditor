package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.Feature")]
	public class Feature
	{
		private var _name:String;
		private var _description:String;
		private var _identification:String;
		private var _autoFind:int;
		private var _genbankType:String;
		private var _sequence:String;
		private var _hash:String;
		
		// Constructor
		public function Feature(name:String = null, description:String = null, identification:String = null, autoFind:int = 0, genbankType:String = null, sequence:String = null, hash:String = "")
		{
			_name = name;
			_description = description;
			_identification = identification;
			_autoFind = autoFind;
			_genbankType = genbankType;
			_hash = hash;
			_sequence = sequence;
		}
		
		// Properties
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
		
		public function get hash():String
		{
			return _hash;
		}
		
		public function set hash(value:String):void	
		{
			_hash = value;
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
		
		public function get sequence():String
		{
			return _sequence;
		}
		
		public function set sequence(value:String):void	
		{
			_sequence = value;
		}
	}
}
