package org.jbei.registry.models
{
	[RemoteClass(alias="org.jbei.ice.services.blazeds.SequenceChecker.vo.Trace")]
	public class Trace
	{
		private var _name:String;
		private var _start:int;
		private var _end:int;
		private var _alignment:String;
		private var _sequence:String;
		private var _score:int;
		
		// Constructor
		public function Trace(name:String = "", start:int = 0, end:int = 0, alignment:String = "", sequence:String = "", score:int = 0) {
			super();
			
			_name = name;
			_start = start;
			_end = end;
			_alignment = alignment;
			_sequence = sequence;
			_score = score;
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
		
		public function get alignment():String
		{
			return _alignment;
		}
		
		public function set alignment(value:String):void
		{
			_alignment = value;
		}
		
		public function get sequence():String
		{
			return _sequence;
		}
		
		public function set sequence(value:String):void
		{
			_sequence = value;
		}
		
		public function get score():int
		{
			return _score;
		}
		
		public function set score(value:int):void
		{
			_score = value;
		}
	}
}
