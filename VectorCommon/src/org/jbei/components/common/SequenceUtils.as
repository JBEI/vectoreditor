package org.jbei.components.common
{
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.bio.sequence.alphabets.DNAAlphabet;
    import org.jbei.bio.sequence.dna.DNASequence;

    /**
     * @author Zinovii Dmytriv
     */
	public class SequenceUtils
	{
		public static const COMPATIBLE_SYMBOLS:Array = new Array(" ", "\t", "\n", "\r", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"); 
		
		// Public Methods
		/* Compatible sequence is sequence with characters like 0-9, ATGCUYRSWKMBVDHN, &lt;newline&gt;, &lt;space&gt;, &lt;tab&gt;, &lt;return&gt;
		 * */
		public static function isCompatibleSequence(sequence:String):Boolean
		{
			var result:Boolean = true;
			
            sequence = sequence.toLowerCase();
            
			for(var j:int = 0; j < sequence.length; j++) {
                if(DNAAlphabet.instance.symbolByValue(sequence.charAt(j))) {
                    continue;
                } else if(COMPATIBLE_SYMBOLS.indexOf(sequence.charAt(j)) >= 0) {
                    continue;
				} else {
                    result = false;
                    break;
                }
			}
			
			return result;
		}
		
		public static function purifyCompatibleSequence(sequence:String):String
		{
			var result:String = "";
			
            sequence = sequence.toLowerCase();
            
			for(var j:int = 0; j < sequence.length; j++) {
				var currentCharacter:String = sequence.charAt(j);
				
				if(COMPATIBLE_SYMBOLS.indexOf(sequence.charAt(j)) >= 0) {
					continue;
				} else if(DNAAlphabet.instance.symbolByValue(sequence.charAt(j))) {
					result += sequence.charAt(j);
				} else {
					result = "";
				}
			}
			
			return result;
		}
	}
}
