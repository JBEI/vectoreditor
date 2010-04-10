package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;

	[RemoteClass(alias="org.jbei.ice.services.blazeds.SequenceChecker.vo.TraceSequenceAlignment")]
	public class TraceSequenceAlignment
	{
		private var _score:int;
		private var _queryStart:int;
		private var _queryEnd:int;
		private var _subjectStart:int;
		private var _subjectEnd:int;
		private var _queryAlignment:String;
		private var _subjectAlignment:String;
		
		// Constructor
		public function TraceSequenceAlignment(score:int, queryStart:int, queryEnd:int, subjectStart:int, subjectEnd:int, queryAlignment:String, subjectAlignment:String)
		{
			super();
			
			_score = score;
			_queryStart = queryStart;
			_queryEnd = queryEnd;
			_subjectStart = subjectStart;
			_subjectEnd = subjectEnd;
			_queryAlignment = queryAlignment;
			_subjectAlignment = subjectAlignment;
		}
		
		// Properties
		public function get score():int
		{
			return _score;
		}
		
		public function set score(value:int):void
		{
			_score = value;
		}
		
		public function get queryStart():int
		{
			return _queryStart;
		}
		
		public function set queryStart(value:int):void
		{
			_queryStart = value;
		}
		
		public function get queryEnd():int
		{
			return _queryEnd;
		}
		
		public function set queryEnd(value:int):void
		{
			_queryEnd = value;
		}
		
		public function get subjectStart():int
		{
			return _subjectStart;
		}
		
		public function set subjectStart(value:int):void
		{
			_subjectStart = value;
		}
		
		public function get subjectEnd():int
		{
			return _subjectEnd;
		}
		
		public function set subjectEnd(value:int):void
		{
			_subjectEnd = value;
		}
		
		public function get queryAlignment():String
		{
			return _queryAlignment;
		}
		
		public function set queryAlignment(value:String):void
		{
			_queryAlignment = value;
		}
		
		public function get subjectAlignment():String
		{
			return _subjectAlignment;
		}
		
		public function set subjectAlignment(value:String):void
		{
			_subjectAlignment = value;
		}
	}
}