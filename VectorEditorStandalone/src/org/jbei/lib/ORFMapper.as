package org.jbei.lib
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.data.ORF;
	import org.jbei.bio.utils.ORFUtils;
	import org.jbei.bio.utils.SequenceUtils;
	
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
				
				CONFIG::debugging {
					trace("ORF REQUESTED AND RECALCULATED!");
				}
				
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
			var orfsSequence:Array = ORFUtils.calculateORFs(_featuredSequence.sequence, _minORFSize);
			var orfsComplimentary:Array = ORFUtils.calculateReverseComplementaryORFs(SequenceUtils.reverseSequence(_featuredSequence.oppositeSequence), _minORFSize);
			
			_orfs = new ArrayCollection();
			for(var i:int = 0; i < orfsSequence.length; i++) {
				_orfs.addItem(orfsSequence[i]);
			}
			
			for(var j:int = 0; j < orfsComplimentary.length; j++) {
				_orfs.addItem(orfsComplimentary[j]);
			}
		}
		
		private function recalculateCircular():void
		{
			var forwardSequence:DNASequence = _featuredSequence.sequence;
			var backwardSequence:DNASequence = SequenceUtils.reverseSequence(_featuredSequence.oppositeSequence);
			
			var doubleForwardSequence:DNASequence = new DNASequence(forwardSequence.sequence + forwardSequence.sequence);
			var doubleBackwardSequence:DNASequence = new DNASequence(backwardSequence.sequence + backwardSequence.sequence);
			
			var orfsSequence:Array = ORFUtils.calculateORFs(doubleForwardSequence, _minORFSize);
			var orfsComplimentary:Array = ORFUtils.calculateReverseComplementaryORFs(doubleBackwardSequence, _minORFSize);
			
			var maxLength:int = forwardSequence.length;
			
			_orfs = new ArrayCollection();
			
			var normalORFs:Array = new Array();
			
			for(var i1:int = 0; i1 < orfsSequence.length; i1++) {
				var orf1:ORF = orfsSequence[i1] as ORF;
				
				if(orf1.start >= maxLength) {
				} else if(orf1.end < maxLength) {
					normalORFs.push(orf1);
				} else if(orf1.end >= maxLength && orf1.start < maxLength) {
					orf1.end -= maxLength;
					
					for(var j1:int = 0; j1 < orf1.startCodons.length; j1++) {
						if(orf1.startCodons[j1] >= maxLength) {
							orf1.startCodons[j1] -= maxLength;
						}
					}
					
					_orfs.addItem(orf1);
				}
			}
			
			for(var i2:int = 0; i2 < orfsComplimentary.length; i2++) {
				var orf2:ORF = orfsComplimentary[i2] as ORF;
				
				if(orf2.start >= maxLength) {
				} else if(orf2.end < maxLength) {
					normalORFs.push(orf2);
				} else if(orf2.end >= maxLength && orf2.start < maxLength) {
					orf2.end -= maxLength;
					
					for(var j2:int = 0; j2 < orf2.startCodons.length; j2++) {
						if(orf2.startCodons[j2] >= maxLength) {
							orf2.startCodons[j2] -= maxLength;
						}
					}
					
					_orfs.addItem(orf2);
				}
			}
			
			// eliminating orf that overlaps with circular orfs
			for(var k:int = 0; k < normalORFs.length; k++) {
				var normalORF:ORF = normalORFs[k] as ORF;
				
				var skip:Boolean = false;
				for(var l:int = 0; l < _orfs.length; l++) {
					var circularORF:ORF = _orfs[l] as ORF;
					
					if(circularORF.end == normalORF.end && circularORF.isComplement == normalORF.isComplement) {
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
