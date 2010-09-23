package org.jbei.lib.mappers
{
	import flash.events.EventDispatcher;
	
	import org.jbei.bio.sequence.TranslationUtils;
	import org.jbei.bio.sequence.alphabets.ProteinAlphabet;
	import org.jbei.bio.sequence.common.SymbolList;
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.bio.sequence.symbols.AminoAcidSymbol;
	import org.jbei.bio.sequence.symbols.GapSymbol;
	import org.jbei.bio.sequence.symbols.ISymbol;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.lib.SequenceProviderEvent;
	
    /**
    * Aminoacids mapper. Maps aminoacids to sequence and remaps only if sequence changed.
    * 
    * @author Zinovii Dmytriv
    */
	public class AAMapper extends EventDispatcher
	{
		private var dirty:Boolean = true;
		
		private var _sequenceAA1Frame1:String;
		private var _sequenceAA1Frame2:String;
		private var _sequenceAA1Frame3:String;
		private var _sequenceAA1Frame1Sparse:String;
		private var _sequenceAA1Frame2Sparse:String;
		private var _sequenceAA1Frame3Sparse:String;
		private var _revComAA1Frame1:String;
		private var _revComAA1Frame2:String;
		private var _revComAA1Frame3:String;
		private var _revComAA1Frame1Sparse:String;
		private var _revComAA1Frame2Sparse:String;
		private var _revComAA1Frame3Sparse:String;
		
		private var sequenceProvider:SequenceProvider;
		
		// Constructor
        /**
        * Contructor
        */
		public function AAMapper(sequenceProvider:SequenceProvider)
		{
			super();
			
			this.sequenceProvider = sequenceProvider;
            sequenceProvider.addEventListener(SequenceProviderEvent.SEQUENCE_CHANGED, onSequenceProviderChanged);
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
		
		public function get sequenceAA1Frame1Sparse():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _sequenceAA1Frame1Sparse;
		}
		
		public function get sequenceAA1Frame2Sparse():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _sequenceAA1Frame2Sparse;
		}
		
		public function get sequenceAA1Frame3Sparse():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _sequenceAA1Frame3Sparse;
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
		
		public function get revComAA1Frame1Sparse():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _revComAA1Frame1Sparse;
		}
		
		public function get revComAA1Frame2Sparse():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _revComAA1Frame2Sparse;
		}
		
		public function get revComAA1Frame3Sparse():String
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _revComAA1Frame3Sparse;
		}
		
		// Private Methods
		private function recalculate():void
		{
			if(sequenceProvider) {
				recalculateNonCircular();
			} else {
				_sequenceAA1Frame1 = "";
				_sequenceAA1Frame2 = "";
				_sequenceAA1Frame3 = "";
				_sequenceAA1Frame1Sparse = "";
				_sequenceAA1Frame2Sparse = "";
				_sequenceAA1Frame3Sparse = "";
				_revComAA1Frame1 = "";
				_revComAA1Frame2 = "";
				_revComAA1Frame3 = "";
				_revComAA1Frame1Sparse = "";
				_revComAA1Frame2Sparse = "";
				_revComAA1Frame3Sparse = "";
			}
			
			dispatchEvent(new AAMapperEvent(AAMapperEvent.AA_MAPPER_UPDATED));
		}
		
		private function recalculateNonCircular():void
		{
			_sequenceAA1Frame1 = "";
			_sequenceAA1Frame2 = "";
			_sequenceAA1Frame3 = "";
			_sequenceAA1Frame1Sparse = "";
			_sequenceAA1Frame2Sparse = "";
			_sequenceAA1Frame3Sparse = "";
			_revComAA1Frame1 = "";
			_revComAA1Frame2 = "";
			_revComAA1Frame3 = "";
			_revComAA1Frame1Sparse = "";
			_revComAA1Frame2Sparse = "";
			_revComAA1Frame3Sparse = "";
			
			for(var i:int = 0; i < sequenceProvider.sequence.length; i++) {
				if(i >= sequenceProvider.sequence.length - 2) { break; }
				
				var aminoAcid:ISymbol = TranslationUtils.dnaToProteinSymbol(sequenceProvider.sequence.symbolAt(i), sequenceProvider.sequence.symbolAt(i + 1), sequenceProvider.sequence.symbolAt(i + 2));
				
                var aa1:String = "-";
                if(aminoAcid is GapSymbol) {
                    if(TranslationUtils.isStopCodon(sequenceProvider.sequence.symbolAt(i), sequenceProvider.sequence.symbolAt(i + 1), sequenceProvider.sequence.symbolAt(i + 2))) {
                        aa1 = ".";
                    }
                } else {
                    aa1 = (aminoAcid as AminoAcidSymbol).value;
                }
                
				if(i == 0 || (i % 3) == 0) {
					_sequenceAA1Frame1 += aa1;
					_sequenceAA1Frame1Sparse += aa1 + "  ";
				} else if(i == 1 || ((i + 2) % 3 == 0)) {
					_sequenceAA1Frame2 += aa1;
					_sequenceAA1Frame2Sparse += aa1 + "  ";
				} else if(i == 2 || ((i + 1) % 3 == 0)) {
					_sequenceAA1Frame3 += aa1;
					_sequenceAA1Frame3Sparse += aa1 + "  ";
				}
			}
			
			var revComSequence:SymbolList = sequenceProvider.getReverseComplementSequence();
			
            var revComSequenceString:String = revComSequence.seqString();
            
			for(var j:int = 0; j < revComSequenceString.length; j++) {
				if(j >= revComSequenceString.length - 2) { break; }
				
                var revComAminoAcid:ISymbol = TranslationUtils.dnaToProteinSymbol(revComSequence.symbolAt(j), revComSequence.symbolAt(j + 1), revComSequence.symbolAt(j + 2));
                
                var revComAA1:String = "-";
                if(revComAminoAcid is GapSymbol) {
                    if(TranslationUtils.isStopCodon(revComSequence.symbolAt(j), revComSequence.symbolAt(j + 1), revComSequence.symbolAt(j + 2))) {
                        revComAA1 = ".";
                    }
                } else {
                    revComAA1 = (revComAminoAcid as AminoAcidSymbol).value;
                }
				
				if(j == 0 || (j % 3) == 0) {
					_revComAA1Frame1 += revComAA1;
					_revComAA1Frame1Sparse += revComAA1 + "  ";
				} else if(j == 1 || ((j + 2) % 3 == 0)) {
					_revComAA1Frame2 += revComAA1;
					_revComAA1Frame2Sparse += revComAA1 + "  ";
				} else if(j == 2 || ((j + 1) % 3 == 0)) {
					_revComAA1Frame3 += revComAA1;
					_revComAA1Frame3Sparse += revComAA1 + "  ";
				}
			}
		}
		
		private function onSequenceProviderChanged(event:SequenceProviderEvent):void
		{
			dirty = true;
		}
	}
}
