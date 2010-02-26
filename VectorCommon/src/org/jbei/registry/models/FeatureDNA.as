package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.FeatureDNA")]
	public class FeatureDNA
	{
		private var _id:int;
		private var _hash:String;
		private var _sequence:String;
		private var _feature:Feature;
		
		// Constructor
		public function FeatureDNA(hash:String = null, sequence:String = null)
		{
			_hash = hash;
			_sequence = sequence;
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
		
		public function get hash():String	
		{
			return _hash;
		}
		
		public function set hash(value:String):void	
		{
			_hash = value;
		}
		
		public function get sequence():String	
		{
			return _sequence;
		}
		
		public function set sequence(value:String):void	
		{
			_sequence = value;
		}
		
		public function get feature():Feature	
		{
			return _feature;
		}
		
		public function set feature(value:Feature):void	
		{
			_feature = value;
		}
	}
}
