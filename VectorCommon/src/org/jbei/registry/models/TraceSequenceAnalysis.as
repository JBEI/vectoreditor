package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
	public class TraceSequenceAnalysis
	{
		private var _filename:String;
		private var _depositor:String;
		private var _sequence:String;
		private var _traceSequenceAlignment:TraceSequenceAlignmentInfo;
		
		// Constructor
		public function TraceSequenceAnalysis(filename:String = "", depositor:String = "", sequence:String = "", traceSequenceAlignment:TraceSequenceAlignmentInfo = null) {
			super();

            _filename = filename;
			_depositor = depositor;
			_sequence = sequence;
			_traceSequenceAlignment = traceSequenceAlignment;
		}
		
		// Properties
		public function get filename():String
		{
			return _filename;
		}
		
		public function set filename(value:String):void
		{
            _filename = value;
		}
		
		public function get depositor():String
		{
			return _depositor;
		}
		
		public function set depositor(value:String):void
		{
			_depositor = value;
		}
		
		public function get sequence():String
		{
			return _sequence;
		}
		
		public function set sequence(value:String):void
		{
			_sequence = value;
		}
		
		public function get traceSequenceAlignment():TraceSequenceAlignmentInfo
		{
			return _traceSequenceAlignment;
		}
		
		public function set traceSequenceAlignment(value:TraceSequenceAlignmentInfo):void
		{
			_traceSequenceAlignment = value;
		}
	}
}
