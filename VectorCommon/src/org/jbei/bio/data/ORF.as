package org.jbei.bio.data
{
	public class ORF implements IAnnotation
	{
		private var _start:int;
		private var _end:int;
		private var _startCodons:Array /* of int */;
		private var _frame:int;
		private var _isComplement:Boolean;
		
		// Constructor
		public function ORF(start:int, end:int, startCodons:Array, isComplement:Boolean = false)
		{
			_start = start;
			_end = end;
			_startCodons = startCodons;
			_isComplement = isComplement;
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
		
		public function get startCodons():Array /* of int */
		{
			return _startCodons;
		}
		
		public function set startCodons(value:Array /* of int */):void
		{
			_startCodons = value;
		}
		
		public function get isComplement():Boolean
		{
			return _isComplement;
		}
		
		public function set isComplement(value:Boolean):void
		{
			_isComplement = value;
		}
		
		// Public Methods
		public function frame():int
		{
			return start % 3;
		}
	}
}
