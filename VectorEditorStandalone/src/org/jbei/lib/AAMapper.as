package org.jbei.lib
{
	import flash.events.EventDispatcher;
	
	import org.jbei.bio.data.AminoAcid;
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.utils.AminoAcidsHelper;
	import org.jbei.bio.utils.SequenceUtils;
	
	public class AAMapper extends EventDispatcher
	{
		private var dirty:Boolean = true;
		
		private var _sequenceAA1Frame1:String;
		private var _sequenceAA1Frame2:String;
		private var _sequenceAA1Frame3:String;
		private var _sequenceAA3Frame1:String;
		private var _sequenceAA3Frame2:String;
		private var _sequenceAA3Frame3:String;
		private var _revComAA1Frame1:String;
		private var _revComAA1Frame2:String;
		private var _revComAA1Frame3:String;
		private var _revComAA3Frame1:String;
		private var _revComAA3Frame2:String;
		private var _revComAA3Frame3:String;
		
		private var featuredSequence:FeaturedSequence;
		
		// Constructor
		public function AAMapper(featuredSequence:FeaturedSequence)
		{
			super();
			
			this.featuredSequence = featuredSequence;
			featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
		}
		
		// Properties
		public function get sequenceAA1Frame1():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _sequenceAA1Frame1;
		}
		
		public function get sequenceAA1Frame2():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _sequenceAA1Frame2;
		}
		
		public function get sequenceAA1Frame3():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _sequenceAA1Frame3;
		}
		
		public function get sequenceAA3Frame1():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _sequenceAA3Frame1;
		}
		
		public function get sequenceAA3Frame2():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _sequenceAA3Frame2;
		}
		
		public function get sequenceAA3Frame3():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _sequenceAA3Frame3;
		}
		
		public function get revComAA1Frame1():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _revComAA1Frame1;
		}
		
		public function get revComAA1Frame2():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _revComAA1Frame2;
		}
		
		public function get revComAA1Frame3():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _revComAA1Frame3;
		}
		
		public function get revComAA3Frame1():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _revComAA3Frame1;
		}
		
		public function get revComAA3Frame2():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _revComAA3Frame2;
		}
		
		public function get revComAA3Frame3():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _revComAA3Frame3;
		}
		
		// Private Methods
		private function recalculate():void
		{
			if(featuredSequence) {
				if(featuredSequence.circular) {
					recalculateNonCircular();
					//recalculateCircular();
				} else {
					recalculateNonCircular();
				}
			} else {
				_sequenceAA1Frame1 = "";
				_sequenceAA1Frame2 = "";
				_sequenceAA1Frame3 = "";
				_sequenceAA3Frame1 = "";
				_sequenceAA3Frame2 = "";
				_sequenceAA3Frame3 = "";
				_revComAA1Frame1 = "";
				_revComAA1Frame2 = "";
				_revComAA1Frame3 = "";
				_revComAA3Frame1 = "";
				_revComAA3Frame2 = "";
				_revComAA3Frame3 = "";
			}
			
			dispatchEvent(new AAMapperEvent(AAMapperEvent.AA_MAPPER_UPDATED));
		}
		
		private function recalculateNonCircular():void
		{
			_sequenceAA1Frame1 = "";
			_sequenceAA1Frame2 = "";
			_sequenceAA1Frame3 = "";
			_sequenceAA3Frame1 = "";
			_sequenceAA3Frame2 = "";
			_sequenceAA3Frame3 = "";
			_revComAA1Frame1 = "";
			_revComAA1Frame2 = "";
			_revComAA1Frame3 = "";
			_revComAA3Frame1 = "";
			_revComAA3Frame2 = "";
			_revComAA3Frame3 = "";
			
			for(var i:int = 0; i < featuredSequence.sequence.length; i++) {
				var codonSeq:String = "";
				
				if(i >= featuredSequence.sequence.length - 2) { break; }
				
				codonSeq = featuredSequence.sequence.sequence.charAt(i) + featuredSequence.sequence.sequence.charAt(i + 1) + featuredSequence.sequence.sequence.charAt(i + 2);
				
				var aminoAcid:AminoAcid = AminoAcidsHelper.instance.aminoAcidFromBP(codonSeq);
				
				var aa3:String = (! aminoAcid) ? (AminoAcidsHelper.instance.isStopCodon(codonSeq) ? '...' : '---') : aminoAcid.name3;
				var aa1:String = (! aminoAcid) ? (AminoAcidsHelper.instance.isStopCodon(codonSeq) ? '.' : '-') : aminoAcid.name1;
				
				if(i == 0 || (i % 3) == 0) {
					_sequenceAA1Frame1 += aa1;
					_sequenceAA3Frame1 += aa3;
				} else if(i == 1 || ((i + 2) % 3 == 0)) {
					_sequenceAA1Frame2 += aa1;
					_sequenceAA3Frame2 += aa3;
				} else if(i == 2 || ((i + 1) % 3 == 0)) {
					_sequenceAA1Frame3 += aa1;
					_sequenceAA3Frame3 += aa3;
				}
			}
			
			var revComSequence:DNASequence = SequenceUtils.reverseSequence(featuredSequence.oppositeSequence);
			
			for(var j:int = 0; j < revComSequence.sequence.length; j++) {
				var revComCodonSeq:String = "";
				
				if(j >= revComSequence.sequence.length - 2) { break; }
				
				revComCodonSeq = revComSequence.sequence.charAt(j) + revComSequence.sequence.charAt(j + 1) + revComSequence.sequence.charAt(j + 2);
				
				var revComAminoAcid:AminoAcid = AminoAcidsHelper.instance.aminoAcidFromBP(revComCodonSeq);
				
				var revComAA3:String = (! revComAminoAcid) ? (AminoAcidsHelper.instance.isStopCodon(revComCodonSeq) ? '...' : '---') : revComAminoAcid.name3;
				var revComAA1:String = (! revComAminoAcid) ? (AminoAcidsHelper.instance.isStopCodon(revComCodonSeq) ? '.' : '-') : revComAminoAcid.name1;
				
				if(j == 0 || (j % 3) == 0) {
					_revComAA1Frame1 += revComAA1;
					_revComAA3Frame1 += revComAA3;
				} else if(j == 1 || ((j + 2) % 3 == 0)) {
					_revComAA1Frame2 += revComAA1;
					_revComAA3Frame2 += revComAA3;
				} else if(j == 2 || ((j + 1) % 3 == 0)) {
					_revComAA1Frame3 += revComAA1;
					_revComAA3Frame3 += revComAA3;
				}
			}
		}
		
		private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
		{
			dirty = true;
		}
	}
}
