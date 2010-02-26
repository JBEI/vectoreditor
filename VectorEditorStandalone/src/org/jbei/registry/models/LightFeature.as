package org.jbei.registry.models
{
	[RemoteClass(alias="org.jbei.ice.services.blazeds.VectorEditor.vo.LightFeature")]
	public class LightFeature
	{
		private var _name:String;
		private var _start:int;
		private var _end:int;
		private var _type:String;
		private var _strand:int;
		private var _description:String;
		
		// Contructor
		public function LightFeature(start:int, end:int, strand:int, name:String, description:String, type:String)
		{
			_start = start;
			_end = end;
			_strand = strand;
			_name = name;
			_description = description;
			_type = type;
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
		
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
		}
		
		public function get strand():int
		{
			return _strand;
		}
		
		public function set strand(value:int):void
		{
			_strand = value;
		}
		
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String):void
		{
			_description = value;
		}
	}
}
