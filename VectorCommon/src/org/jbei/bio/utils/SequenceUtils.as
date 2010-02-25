package org.jbei.bio.utils
{
	import org.jbei.bio.data.DNASequence;
	
	public class SequenceUtils
	{
		public static const ATOMIC_SYMBOLS:Array  = new Array('A', 'T', 'G', 'C');
		public static const SYMBOLS:Array         = new Array('A', 'T', 'G', 'C', 'U', 'Y', 'R', 'S', 'W', 'K', 'M', 'B', 'V', 'D', 'H', 'N');
		public static const REVERSE_SYMBOLS:Array = new Array('T', 'A', 'C', 'G', 'A', 'R', 'Y', 'S', 'W', 'M', 'K', 'V', 'B', 'H', 'D', 'N');
		public static const COMPATIBLE_SYMBOLS:Array = new Array(" ", "\t", "\n", "\r", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"); 
		
		/*
		K = G or T
		M = A or C
		R = A or G
		Y = C or T
		S = C or G
		W = A or T
		B = C or G or T
		V = A or C or G
		H = A or C or T
		D = A or G or T
		N = G or A or T or C
		*/
		
		// Public Methods
		public static function isValidDNA(sequence:String):Boolean
		{
			var result:Boolean = true;
			
			for(var i:int = 0; i < sequence.length; i++) {
				var char:String = sequence.charAt(i);
				if(! (SYMBOLS.indexOf(char) >= 0)) {
					result = false;
					break;
				}
			}
			
			return result;
		}
		
		public static function oppositeSequence(sequence:DNASequence):DNASequence
		{
			var sequenceSymbols:Array = sequence.sequence.split("");
			
			for(var i:int = 0; i < sequenceSymbols.length; i++) {
				sequenceSymbols[i] = REVERSE_SYMBOLS[SYMBOLS.indexOf(sequenceSymbols[i])];
			}
			
			var reverseDNAString:String = sequenceSymbols.join("");
			
			return new DNASequence(reverseDNAString);
		}
		
		public static function reverseComplement(sequence:DNASequence):DNASequence
		{
			return reverseSequence(oppositeSequence(sequence));
		}
		
		public static function reverseSequence(dnaSequence:DNASequence):DNASequence
		{
			var sequence:String = dnaSequence.sequence;
			
			return new DNASequence(sequence.split("").reverse().join(""));
		}
		
		/* Compatible sequence is sequence with characters like 0-9, ATGCUYRSWKMBVDHN, &lt;newline&gt;, &lt;space&gt;, &lt;tab&gt;, &lt;return&gt;
		 * */
		public static function isCompatibleSequence(sequence:String):Boolean
		{
			var result:Boolean = true;
			
			for(var j:int = 0; j < sequence.length; j++) {
				if(COMPATIBLE_SYMBOLS.indexOf(sequence.charAt(j)) >= 0 
					|| SYMBOLS.indexOf(sequence.charAt(j)) >= 0) {
					continue;
				} else {
					return false;
				}
			}
			
			return result;
		}
		
		public static function purifyCompatibleSequence(sequence:String):String
		{
			var result:String = "";
			
			for(var j:int = 0; j < sequence.length; j++) {
				var currentCharacter:String = sequence.charAt(j);
				
				if(COMPATIBLE_SYMBOLS.indexOf(sequence.charAt(j)) >= 0) {
					continue;
				} else if(SYMBOLS.indexOf(sequence.charAt(j)) >= 0) {
					result += sequence.charAt(j);
				} else {
					result = "";
				}
			}
			
			return result;
		}
	}
}
