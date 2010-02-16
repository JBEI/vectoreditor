package org.jbei.bio.utils
{
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.data.ORF;
	
	public class ORFUtils
	{
		// Public Methods
		public static function calculateORFs(dnaSequence:DNASequence, minimumORF:int = -1):Array /* of ORF */
		{
			if(! dnaSequence || dnaSequence.length < 6) {
				return new Array();
			}
			
			var orfs1:Array = orfPerFrame(0, dnaSequence.sequence, minimumORF);
			var orfs2:Array = orfPerFrame(1, dnaSequence.sequence, minimumORF);
			var orfs3:Array = orfPerFrame(2, dnaSequence.sequence, minimumORF);
			
			return orfs1.concat(orfs2, orfs3);
		}
		
		public static function calculateReverseComplementaryORFs(reverseComplementDNASequence:DNASequence, minimumORF:int = -1):Array /* of ORF */
		{
			var orfs:Array = new Array();
			
			if(! reverseComplementDNASequence || reverseComplementDNASequence.length < 6) {
				return new Array();
			}
			
			var orfs1:Array = orfPerFrame(0, reverseComplementDNASequence.sequence, minimumORF, true);
			var orfs2:Array = orfPerFrame(1, reverseComplementDNASequence.sequence, minimumORF, true);
			var orfs3:Array = orfPerFrame(2, reverseComplementDNASequence.sequence, minimumORF, true);
			
			var result:Array = orfs1.concat(orfs2, orfs3);
			
			var sequenceLength:int = reverseComplementDNASequence.length;
			for(var i:int = 0; i < result.length; i++) {
				var orf:ORF = result[i] as ORF;
				
				var start:int = sequenceLength - orf.start - 1;
				var end:int = sequenceLength - orf.end - 1;
				
				orf.start = end;
				orf.end = start;
				
				for(var j:int = 0; j < orf.startCodons.length; j++) {
					orf.startCodons[j] = sequenceLength - orf.startCodons[j] - 1;
				}
				
				orf.startCodons.sort(codonsSort);
			}
			
			return result;
		}
		
		// Private Methods
		private static function orfPerFrame(frameStartIndex:int, sequence:String, minimumORF:int = -1, isComplement:Boolean = false):Array /* of ORF */
		{
			var orfs:Array = new Array();
			var sequenceLength:int = sequence.length;
			
			var index:int = frameStartIndex;
			var startIndex:int = -1;
			var endIndex:int = -1;
			var startCodonIndexes:Array = new Array();
			var possibleStopCodon:Boolean = false;
			while(true) {
				if(index + 2 >= sequenceLength) { break; }
				
				var codonSeq:String = sequence.charAt(index) + sequence.charAt(index + 1) + sequence.charAt(index + 2);
				
				possibleStopCodon = false;
				
				if(!AminoAcidsHelper.instance.aminoAcidFromBP(codonSeq) && !AminoAcidsHelper.instance.isStartCodon(codonSeq)) {
					if(AminoAcidsHelper.instance.evaluatePossibleStop(codonSeq)) {
						possibleStopCodon = true;
					}
				}
				
				if(!possibleStopCodon && AminoAcidsHelper.instance.isStartCodon(codonSeq)) {
					if(startIndex == -1) {
						startIndex = index;
					}
					
					if(startCodonIndexes == null) {
						startCodonIndexes = new Array();
					}
					startCodonIndexes.push(index);
					
					index += 3;
					
					continue;
				}
				
				if(possibleStopCodon || AminoAcidsHelper.instance.isStopCodon(codonSeq)) {
					if(startIndex != -1) {
						endIndex = index + 2;
						if(minimumORF == -1 || (Math.abs(endIndex - startIndex) + 1 >= minimumORF)) {
							if(startCodonIndexes == null) {
								startCodonIndexes = new Array();
							}
							
							orfs.push(new ORF(startIndex, endIndex, startCodonIndexes, isComplement));
						}
					}
					
					startIndex = -1;
					endIndex = -1;
					startCodonIndexes = null;
					
					index += 3;
					
					continue;
				}
				
				index += 3;
			}
			
			return orfs;
		}
		
		private static function codonsSort(a:int, b:int):Number
		{
			if(a > b) {
				return 1;
			} else if(a < b) {
				return -1;
			} else  {
				return 0;
			}
		}
	}
}
