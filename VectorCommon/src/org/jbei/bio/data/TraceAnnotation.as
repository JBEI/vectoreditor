package org.jbei.bio.data
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.sequence.common.Annotation;
	import org.jbei.registry.models.TraceSequence;

	public class TraceAnnotation extends Annotation
	{
		private var _traceSequence:TraceSequence;
		private var _matches:ArrayCollection = new ArrayCollection(); /* of Segment */
		private var _mismatches:ArrayCollection = new ArrayCollection(); /* of Segment */
		private var _deletions:ArrayCollection = new ArrayCollection(); /* of Segment */
		private var _insertions:ArrayCollection = new ArrayCollection(); /* of Segment */
		private var _allMismatches:ArrayCollection = new ArrayCollection(); /* of Segment */
		
		// Contructor
		public function TraceAnnotation(start:int, end:int, traceSequence:TraceSequence)
		{
			super(start, end);
			
			_traceSequence = traceSequence;
		}
		
		// Properties
		public function get traceSequence():TraceSequence
		{
			return _traceSequence;
		}
		
		public function get matches():ArrayCollection /* of Segment */
		{
			return _matches;
		}
		
		public function set matches(value:ArrayCollection /* of Segment */):void
		{
			_matches = value;
		}
		
		public function get mismatches():ArrayCollection /* of Segment */
		{
			return _mismatches;
		}
		
		public function set mismatches(value:ArrayCollection /* of Segment */):void
		{
			_mismatches = value;
		}
		
		public function get allMismatches():ArrayCollection /* of Segment */
		{
			return _allMismatches;
		}
		
		public function set allMismatches(value:ArrayCollection /* of Segment */):void
		{
			_allMismatches = value;
		}
		
		public function get deletions():ArrayCollection /* of Segment */
		{
			return _deletions;
		}
		
		public function set deletions(value:ArrayCollection /* of Segment */):void
		{
			_deletions = value;
		}
		
		public function get insertions():ArrayCollection /* of Segment */
		{
			return _insertions;
		}
		
		public function set insertions(value:ArrayCollection /* of Segment */):void
		{
			_insertions = value;
		}
		
		// Public Methods
		public function clean():void
		{
			_matches.removeAll();
			_mismatches.removeAll();
			_allMismatches.removeAll();
			_deletions.removeAll();
			_insertions.removeAll();
		}
	}
}