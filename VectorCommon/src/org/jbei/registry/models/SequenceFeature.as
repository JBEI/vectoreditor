package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.SequenceFeature")]
	public class SequenceFeature
	{
		private var _name:String;
		private var _start:int;
		private var _end:int;
		private var _strand:int;
		private var _feature:Feature;
		private var _sequence:String;
		
		// Constructor
		public function SequenceFeature(start:int = 0, end:int = 0, strand:int = 0, feature:Feature = null, sequence:String = null)
		{
			_start = start;
			_end = end;
			_strand = strand;
			_feature = feature;
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
		
		public function get start():int
		{
			return _start;
		}
		
		public function set start(value:int):void	
		{
			_start = value;
		}
		
		public function get end():int
		{
			return _end;
		}
		
		public function set end(value:int):void	
		{
			_end = value;
		}
		
		public function get strand():int
		{
			return _strand;
		}
		
		public function set strand(value:int):void	
		{
			_strand = value;
		}
		
		public function get feature():Feature
		{
			return _feature;
		}
		
		public function set feature(value:Feature):void	
		{
			_feature = value;
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
