package org.jbei.bio.data
{
	import org.jbei.bio.utils.SequenceUtils;
	
	public class DNASequence
	{
		private var _sequence:String;
		
		// Constructor
		public function DNASequence(sequence:String, skipValidation:Boolean = false)
		{
			sequence = sequence.toUpperCase();
			
			if(!skipValidation) {
				validate(sequence);
			}
			
			_sequence = sequence;
		}
		
		// Properties
		public function get sequence():String
		{
			return _sequence;
		}
		
		public function get length():uint
		{
			return _sequence.length;
		}
		
		// Public Methods
		public function toString():String
		{
			return exportAsText();
		}
		
		public function nucleotideAt(index:uint):String
		{
			return _sequence.charAt(index);
		}
		
		public function subSequence(start:uint, length:uint):DNASequence
		{
			return new DNASequence(_sequence.slice(start, start + length));
		}
		
		public function insert(insertSequence:DNASequence, position:int):void
		{
			var resultSequence:String = "";
			
			if(position < 0 || position > _sequence.length) {
				throw new BioException("Invalid sequence insert position: " + String(position))
			} else {
				if(position == 0) {
					resultSequence = insertSequence.sequence + _sequence;
				} else if(position == _sequence.length) {
					resultSequence = _sequence + insertSequence.sequence;
				} else {
					resultSequence = _sequence.substring(0, position) + insertSequence.sequence + _sequence.substring(position, _sequence.length);
				}
			}
			
			_sequence = resultSequence;
		}
		
		public function remove(position:int, length:int):void
		{
			if(length <= 0) {
				throw new BioException("Invalid sequence remove length: " + String(length));
			} else if(position < 0 || position > _sequence.length) {
				throw new BioException("Invalid sequence remove position: " + String(position));
			} else if(position + length > _sequence.length) {
				throw new BioException("Invalid sequence remove position & length: " + String(position) + ", " + String(length));
			}
			
			_sequence = _sequence.substring(0, position) + _sequence.substring(position + length, _sequence.length);
		}
		
		public function exportAsText(bpPerLine:uint = 60, use10BPSpaceDelimiter:Boolean = true, showLineNumbers:Boolean = false):String
		{
			var result:String = "";
			
			for(var i:int = 0; i < length; i++) {
				if(showLineNumbers) {
					if((i == 0) || i % bpPerLine == 0) {
						result += String(i + 1) + "\t";
					}
				}
				
				result += _sequence.charAt(i);
				
				if((i + 1) % bpPerLine == 0) {
					result += "\n";
				} else if (use10BPSpaceDelimiter && ((i + 1) % 10 == 0)) {
					result += " ";
				}
			}
			
			return result;
		}
		
		// Private Methods
		private function validate(sequence:String):void
		{
			if(! SequenceUtils.isValidDNA(sequence)) {
				throw new BioException("Invalid character in sequence!");
			}
		}
	}
}
