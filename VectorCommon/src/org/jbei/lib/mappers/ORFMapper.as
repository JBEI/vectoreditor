package org.jbei.lib.mappers
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.orf.ORF;
	import org.jbei.bio.orf.ORFFinder;
	import org.jbei.bio.sequence.DNATools;
	import org.jbei.bio.sequence.common.SymbolList;
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	
	public class ORFMapper extends EventDispatcher
	{
		private var dirty:Boolean = true;
		private var _orfs:ArrayCollection /* of ORF */;
		private var _minORFSize:int = 300;
		private var _featuredSequence:FeaturedSequence;
		
		// Constructor
		public function ORFMapper(featuredSequence:FeaturedSequence)
		{
			super();
			
			_featuredSequence = featuredSequence;
			_featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
		}
		
		// Properties
		public function get orfs():ArrayCollection /* of ORF */
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _orfs;
		}
		
		public function get minORFSize():int
		{
			return _minORFSize
		}
		
		public function set minORFSize(value:int):void
		{
			if(_minORFSize != value) {
				_minORFSize = value;
				
				dirty = true;
			}
		}
		
		// Private Methods
		private function recalculate():void
		{
			if(_featuredSequence) {
				if(_featuredSequence.circular) {
					recalculateCircular();
				} else {
					recalculateNonCircular();
				}
			} else {
				_orfs = null;
			}
			
			dispatchEvent(new ORFMapperEvent(ORFMapperEvent.ORF_MAPPER_UPDATED));
		}
		
		private function recalculateNonCircular():void
		{
			var orfsSequence:Vector.<ORF> = ORFFinder.calculateORFBothDirections(_featuredSequence.sequence, _featuredSequence.getReverseComplementSequence(), _minORFSize);
			
			_orfs = new ArrayCollection();
			for(var i:int = 0; i < orfsSequence.length; i++) {
				_orfs.addItem(orfsSequence[i]);
			}
		}
		
		private function recalculateCircular():void
		{
			var forwardSequence:SymbolList = _featuredSequence.sequence;
			var backwardSequence:SymbolList = _featuredSequence.getReverseComplementSequence();
			
			var doubleForwardSequence:SymbolList = DNATools.createDNA(forwardSequence.seqString() + forwardSequence.seqString());
			var doubleBackwardSequence:SymbolList = DNATools.createDNA(backwardSequence.seqString() + backwardSequence.seqString());
			
			var orfsSequence:Vector.<ORF> = ORFFinder.calculateORFBothDirections(doubleForwardSequence, doubleBackwardSequence, _minORFSize);
			
			var maxLength:int = forwardSequence.length;
			
			_orfs = new ArrayCollection();
			
			var normalORFs:Array = new Array();
			
			for(var i:int = 0; i < orfsSequence.length; i++) {
				var orf:ORF = orfsSequence[i] as ORF;
				
				if(orf.start >= maxLength) {
				} else if(orf.end < maxLength) {
					normalORFs.push(orf);
				} else if(orf.end >= maxLength && orf.start < maxLength) {
					orf.end -= maxLength;
					
					for(var j:int = 0; j < orf.startCodons.length; j++) {
						if(orf.startCodons[j] >= maxLength) {
							orf.startCodons[j] -= maxLength;
						}
					}
					
					_orfs.addItem(orf);
				}
			}
			
			// eliminating orf that overlaps with circular orfs
			for(var k:int = 0; k < normalORFs.length; k++) {
				var normalORF:ORF = normalORFs[k] as ORF;
				
				var skip:Boolean = false;
				for(var l:int = 0; l < _orfs.length; l++) {
					var circularORF:ORF = _orfs[l] as ORF;
					
					if(circularORF.end == normalORF.end && circularORF.strand == normalORF.strand) {
						skip = true;
						break;
					}
				}
				
				if(!skip) {
					_orfs.addItem(normalORF);
				}
			}
		}
		
		private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
		{
			dirty = true;
		}
	}
}
