package org.jbei.lib.mappers
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.TraceAnnotation;
	import org.jbei.bio.sequence.common.Annotation;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.registry.models.TraceSequence;
	import org.jbei.registry.models.TraceSequenceAlignment;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class TraceMapper extends EventDispatcher
	{
		private var dirty:Boolean = true;
		
		private var sequenceProvider:SequenceProvider;
		private var _traceAnnotations:ArrayCollection = new ArrayCollection(); /* of TraceAnnotation */
		
		
		// Constructor
		public function TraceMapper(sequenceProvider:SequenceProvider, traces:ArrayCollection /* of TraceSequence */)
		{
			super();
			
			this.sequenceProvider = sequenceProvider;
			
			_traceAnnotations.removeAll();
			
			if(traces == null || traces.length == 0 || sequenceProvider == null) {
				return;
			}
			
			for(var i:int = 0; i < traces.length; i++) {
				var traceSequence:TraceSequence = traces[i] as TraceSequence;
				
				if(traceSequence.traceSequenceAlignment == null) {
					continue;
				}
				
				_traceAnnotations.addItem(new TraceAnnotation(traceSequence.traceSequenceAlignment.queryStart - 1, traceSequence.traceSequenceAlignment.queryEnd - 1, traceSequence)) // -1 because sequenceProvider based on 0 position
			}
		}
		
		// Properties
		
		public function get traceAnnotations():ArrayCollection /* of TraceSequence */
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _traceAnnotations;
		}
		
		// Private Methods
		private function recalculate():void {
			if(_traceAnnotations.length == 0) {
				return;
			}

			for(var i:int = 0; i < _traceAnnotations.length; i++) {
				var traceAnnotation:TraceAnnotation = _traceAnnotations[i];
				
				traceAnnotation.matches = calculateMatches(traceAnnotation.traceSequence.traceSequenceAlignment);
				traceAnnotation.mismatches = calculateMismatches(traceAnnotation.traceSequence.traceSequenceAlignment);
				traceAnnotation.deletions = calculateDeletions(traceAnnotation.traceSequence.traceSequenceAlignment);
				traceAnnotation.insertions = calculateInsertions(traceAnnotation.traceSequence.traceSequenceAlignment);
				
				traceAnnotation.allMismatches.addAll(traceAnnotation.mismatches);
				traceAnnotation.allMismatches.addAll(traceAnnotation.deletions);
				traceAnnotation.allMismatches.addAll(traceAnnotation.insertions);
			}
		}
		
		private function calculateMatches(traceSequenceAlignment:TraceSequenceAlignment):ArrayCollection /* of Annotation */
		{
			var matches:ArrayCollection = new ArrayCollection();
			
			var alignmentLength:int = traceSequenceAlignment.queryAlignment.length;
			
			if(alignmentLength < 1) {
				return matches;
			}
			
			var matchStart:int = -1;
			var matchEnd:int = -1;
			var isMatch:Boolean = false;
			for(var i:int = 0; i < alignmentLength; i++) {
				if(traceSequenceAlignment.queryAlignment.charAt(i) == traceSequenceAlignment.subjectAlignment.charAt(i)) {
					if(!isMatch) {
						matchStart = i;
					}
					
					isMatch = true;
				} else {
					if(isMatch) {
						matchEnd = i - 1;
						
						matches.addItem(new Annotation(traceSequenceAlignment.queryStart + matchStart - 1, traceSequenceAlignment.queryStart + matchEnd - 1)); // -1 because our sequence starts from 0
					}
					
					matchStart = -1;
					matchEnd = -1;
					isMatch = false;
				}
			}
			
			if(isMatch) {
				matchEnd = alignmentLength - 1;
				
				matches.addItem(new Annotation(traceSequenceAlignment.queryStart + matchStart - 1, traceSequenceAlignment.queryStart + matchEnd - 1)); // -1 because our sequence starts from 0
			}
			
			return matches;
		}
		
		private function calculateMismatches(traceSequenceAlignment:TraceSequenceAlignment):ArrayCollection /* of Annotation */
		{
			var mismatches:ArrayCollection = new ArrayCollection();
			
			var alignmentLength:int = traceSequenceAlignment.queryAlignment.length;
			
			if(alignmentLength < 1) {
				return mismatches;
			}
			
			var matchStart:int = -1;
			var matchEnd:int = -1;
			var isMatch:Boolean = false;
			for(var i:int = 0; i < alignmentLength; i++) {
				if(traceSequenceAlignment.queryAlignment.charAt(i) != traceSequenceAlignment.subjectAlignment.charAt(i) && traceSequenceAlignment.subjectAlignment.charAt(i) != "-" && traceSequenceAlignment.queryAlignment.charAt(i) != "-") {
					if(!isMatch) {
						matchStart = i;
					}
					
					isMatch = true;
				} else {
					if(isMatch) {
						matchEnd = i - 1;
						
						mismatches.addItem(new Annotation(traceSequenceAlignment.queryStart + matchStart - 1, traceSequenceAlignment.queryStart + matchEnd - 1)); // -1 because our sequence starts from 0
					}
					
					matchStart = -1;
					matchEnd = -1;
					isMatch = false;
				}
			}
			
			if(isMatch) {
				matchEnd = alignmentLength - 1;
				
				mismatches.addItem(new Annotation(traceSequenceAlignment.queryStart + matchStart - 1, traceSequenceAlignment.queryStart + matchEnd - 1)); // -1 because our sequence starts from 0
			}
			
			return mismatches;
		}
		
		private function calculateDeletions(traceSequenceAlignment:TraceSequenceAlignment):ArrayCollection /* of Annotation */
		{
			var deletions:ArrayCollection = new ArrayCollection();
			
			var alignmentLength:int = traceSequenceAlignment.queryAlignment.length;
			
			if(alignmentLength < 1) {
				return deletions;
			}
			
			var matchStart:int = -1;
			var matchEnd:int = -1;
			var isMatch:Boolean = false;
			for(var i:int = 0; i < alignmentLength; i++) {
				if(traceSequenceAlignment.subjectAlignment.charAt(i) == "-") {
					if(!isMatch) {
						matchStart = i;
					}
					
					isMatch = true;
				} else {
					if(isMatch) {
						matchEnd = i - 1;
						
						deletions.addItem(new Annotation(traceSequenceAlignment.queryStart + matchStart - 1, traceSequenceAlignment.queryStart + matchEnd - 1)); // -1 because our sequence starts from 0
					}
					
					matchStart = -1;
					matchEnd = -1;
					isMatch = false;
				}
			}
			
			if(isMatch) {
				matchEnd = alignmentLength - 1;
				
				deletions.addItem(new Annotation(traceSequenceAlignment.queryStart + matchStart - 1, traceSequenceAlignment.queryStart + matchEnd - 1)); // -1 because our sequence starts from 0
			}
			
			return deletions;
		}
		
		private function calculateInsertions(traceSequenceAlignment:TraceSequenceAlignment):ArrayCollection /* of Annotation */
		{
			var insertions:ArrayCollection = new ArrayCollection();
			
			var alignmentLength:int = traceSequenceAlignment.queryAlignment.length;
			
			if(alignmentLength < 1) {
				return insertions;
			}
			
			var matchStart:int = -1;
			var matchEnd:int = -1;
			var isMatch:Boolean = false;
			for(var i:int = 0; i < alignmentLength; i++) {
				if(traceSequenceAlignment.queryAlignment.charAt(i) == "-") {
					if(!isMatch) {
						matchStart = i;
					}
					
					isMatch = true;
				} else {
					if(isMatch) {
						matchEnd = i - 1;
						
						insertions.addItem(new Annotation(traceSequenceAlignment.queryStart + matchStart - 1, traceSequenceAlignment.queryStart + matchEnd - 1)); // -1 because our sequence starts from 0
					}
					
					matchStart = -1;
					matchEnd = -1;
					isMatch = false;
				}
			}
			
			if(isMatch) {
				matchEnd = alignmentLength - 1;
				
				insertions.addItem(new Annotation(traceSequenceAlignment.queryStart + matchStart - 1, traceSequenceAlignment.queryStart + matchEnd - 1)); // -1 because our sequence starts from 0
			}
			
			return insertions;
		}
	}
}
