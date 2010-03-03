package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;

	[RemoteClass(alias="org.jbei.ice.services.blazeds.SequenceChecker.vo.TracedSequenceAlignments")]
	public class TraceAlignment
	{
		private var _name:String;
		private var _isCircular:Boolean;
		private var _sequence:Sequence;
		private var _traces:ArrayCollection /* of Trace */;
		
		// Constructor
		public function TraceAlignment(name:String = "", isCircular:Boolean = false, sequence:Sequence = null, traces:ArrayCollection /* of Trace */ = null)
		{
			super();
			
			_name = name;
			_isCircular = isCircular;
			_sequence = sequence;
			_traces = traces;
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
		
		public function get isCircular():Boolean
		{
			return _isCircular;
		}
		
		public function set isCircular(value:Boolean):void
		{
			_isCircular = value;
		}
		
		public function get sequence():Sequence
		{
			return _sequence;
		}
		
		public function set sequence(value:Sequence):void
		{
			_sequence = value;
		}
		
		public function get traces():ArrayCollection /* of Trace */
		{
			return _traces;
		}
		
		public function set traces(value:ArrayCollection):void
		{
			_traces = value;
		}
	}
}