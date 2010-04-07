package org.jbei.registry.models
{
	[RemoteClass(alias="org.jbei.ice.lib.vo.DNASequence")]
	public class DNASequence
	{
		private var _identifier:String = "";
		private var _accessionNumber:String = "";
		private var _locus:String = "";
		private var _sequence:String = "";
		
		// Constructor
		public function DNASequence(sequence:String)
		{
			super();
			
			_sequence = sequence;
		}
		
		// Properties
		public function get identifier():String
		{
			return _identifier;
		}
		
		public function set identifier(value:String):void
		{
			_identifier = value;
		}
		
		public function get accessionNumber():String
		{
			return _accessionNumber;
		}
		
		public function set accessionNumber(value:String):void
		{
			_accessionNumber = value;
		}
		
		public function get locus():String
		{
			return _locus;
		}
		
		public function set locus(value:String):void
		{
			_locus = value;
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