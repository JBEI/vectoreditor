package org.jbei.registry.models
{
	[RemoteClass(alias="org.jbei.ice.lib.models.TraceSequence")]
    /**
     * @author Zinovii Dmytriv
     */
	public class TraceSequence
	{
		private var _filename:String;
		private var _depositor:String;
		private var _sequence:String;
		private var _traceSequenceAlignment:TraceSequenceAlignment;
		
		// Constructor
		public function TraceSequence(filename:String = "", depositor:String = "", sequence:String = "", traceSequenceAlignment:TraceSequenceAlignment = null) {
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
		
		public function get traceSequenceAlignment():TraceSequenceAlignment
		{
			return _traceSequenceAlignment;
		}
		
		public function set traceSequenceAlignment(value:TraceSequenceAlignment):void
		{
			_traceSequenceAlignment = value;
		}
	}
}
