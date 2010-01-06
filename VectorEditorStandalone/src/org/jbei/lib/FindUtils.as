package org.jbei.lib
{
	import org.jbei.bio.data.Segment;

	public class FindUtils
	{
		public static function find(sequence:String, expression:String, start:int = 0):Segment
		{
			var result:Segment = null;
			
			if(expression.length == 0 || sequence.length == 0) { return result; }
			
			var expressionRegExp:RegExp = new RegExp(expression, "ig");
			
			var match:Object = expressionRegExp.exec(sequence);
			while (match != null) {
				if(match.index < start) {
					match = expressionRegExp.exec(sequence);
					continue;
				}
				
				result = new Segment(match.index, match.index + String(match[0]).length);
				break;
			}
			
			return result;
		}
		
		public static function findLast(sequence:String, expression:String, end:int):Segment
		{
			var result:Segment = null;
			
			if(expression.length == 0 || sequence.length == 0) { return result; }
			
			var expressionRegExp:RegExp = new RegExp(expression, "ig");
			
			var lastReverseStart:int = -1;
			var lastReverseEnd:int = -1;
			
			var match:Object = expressionRegExp.exec(sequence);
			while (match != null) {
				if(match.index + String(match[0]).length > end) { break; }
				
				lastReverseStart = match.index;
				lastReverseEnd = match.index + String(match[0]).length;
				
				match = expressionRegExp.exec(sequence);
			}
			
			if(lastReverseStart > 0 && lastReverseEnd > 0) {
				result = new Segment(sequence.length - lastReverseEnd, sequence.length - lastReverseStart);
			}
			
			return result;
		}
		
		public static function findAll(sequence:String, expression:String):Array /* of Segment */
		{
			var result:Array = new Array();
			
			if(expression.length == 0 || sequence.length == 0) { return result; }
			
			var expressionRegExp:RegExp = new RegExp(expression, "ig");
			
			var match:Object = expressionRegExp.exec(sequence);
			while (match != null) {
				result.push(new Segment(match.index, match.index + String(match[0]).length));
				
				match = expressionRegExp.exec(sequence);
			}
			
			return result;
		}
	}
}
