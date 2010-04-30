package org.jbei.bio.data
{
	[RemoteClass(alias="org.jbei.bio.data.Segment")]
	public class Segment implements IAnnotation
	{
		private var _start:int;
		private var _end:int;
		
		// Constructor
		public function Segment(start:int, end:int)
		{
			_start = start;
			_end = end;
		}
		
		// Properties
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
	}
}
