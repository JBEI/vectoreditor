package org.jbei.registry.utils
{
	import org.jbei.bio.data.Segment;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.lib.mappers.AAMapper;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FindUtils;

	public class Finder
	{
		public static const DATA_TYPE_DNA:String = "DataTypeDNA";
		public static const DATA_TYPE_AMINO_ACIDS:String = "DataTypeAA";
		
		public static const SEARCH_TYPE_LITTERAL:String = "SearchTypeLitteral";
		public static const SEARCH_TYPE_AMBIGUOUS:String = "SearchTypeAmbiguous";
		
		// Public Methods
		public static function find(featuredSequence:FeaturedSequence, expression:String, dataType:String = Finder.DATA_TYPE_DNA, searchType:String = Finder.SEARCH_TYPE_LITTERAL, start:int = 0):Segment
		{
			if(!featuredSequence || featuredSequence.sequence.length == 0 || expression.length == 0) { return null; }
			
			var resultSegment:Segment = null;
			
			expression = expression.toUpperCase();
			
			switch(dataType) {
				case DATA_TYPE_DNA:
					if(searchType == Finder.SEARCH_TYPE_AMBIGUOUS) {
						expression = makeAmbiguousDNAExpression(expression);
					}
					
					var sequenceSegment:Segment = FindUtils.find(featuredSequence.sequence.sequence, expression, start);
					var reverseComplementSegment:Segment = FindUtils.findLast(SequenceUtils.reverseSequence(featuredSequence.oppositeSequence).sequence, expression, featuredSequence.sequence.length - start);
					
					if(sequenceSegment && reverseComplementSegment) {
						if(sequenceSegment.start < reverseComplementSegment.start) {
							resultSegment = sequenceSegment;
						} else {
							resultSegment = reverseComplementSegment;
						}
					} else if(sequenceSegment && !reverseComplementSegment) {
						resultSegment = sequenceSegment;
					} else if(!sequenceSegment && reverseComplementSegment) {
						resultSegment = reverseComplementSegment;
					} else {
						resultSegment = null;
					}
					
					break;
				case DATA_TYPE_AMINO_ACIDS:
					var aaMapper:AAMapper = new AAMapper(featuredSequence);
					
					var position1:int = 0;
					if(start == 0) {
						position1 = 0;
					} else {
						if(start % 3 == 0) {
							position1 = (start + 3) / 3;
						} else if(start % 3 == 1) {
							position1 = (start + 2) / 3;
						} else if(start % 3 == 2) {
							position1 = (start + 1) / 3;
						}
					}
					
					var position2:int = 0;
					if((featuredSequence.sequence.length - start - 1) % 3 == 0) {
						position2 = (featuredSequence.sequence.length - start - 1 - 3) / 3;
					} else if((featuredSequence.sequence.length - start - 1) % 3 == 1) {
						position2 = ((featuredSequence.sequence.length - start - 1) - 2) / 3;
					} else if((featuredSequence.sequence.length - start - 1) % 3 == 2) {
						position2 = ((featuredSequence.sequence.length - start - 1) - 1) / 3;
					}
					
					var sequenceSegmentFrame1:Segment = FindUtils.find(aaMapper.sequenceAA1Frame1, expression, position1);
					var sequenceSegmentFrame2:Segment = FindUtils.find(aaMapper.sequenceAA1Frame2, expression, position1);
					var sequenceSegmentFrame3:Segment = FindUtils.find(aaMapper.sequenceAA1Frame3, expression, position1);
					
					var revComSegmentFrame1:Segment = FindUtils.findLast(aaMapper.revComAA1Frame1, expression, position2);
					var revComSegmentFrame2:Segment = FindUtils.findLast(aaMapper.revComAA1Frame2, expression, position2);
					var revComSegmentFrame3:Segment = FindUtils.findLast(aaMapper.revComAA1Frame3, expression, position2);
					
					var smallestStart:int = -1;
					var frame:int = 0;
					
					// sparse AA1 segments 
					if(sequenceSegmentFrame1) {
						sequenceSegmentFrame1.start = 3 * sequenceSegmentFrame1.start;
						sequenceSegmentFrame1.end = 3 * sequenceSegmentFrame1.end;
						
						smallestStart = sequenceSegmentFrame1.start;
						frame = 1;
					}
					
					if(sequenceSegmentFrame2) {
						sequenceSegmentFrame2.start = 3 * sequenceSegmentFrame2.start + 1;
						sequenceSegmentFrame2.end = 3 * sequenceSegmentFrame2.end + 1;
						
						if(frame == 0 || sequenceSegmentFrame2.start < smallestStart) {
							smallestStart = sequenceSegmentFrame2.start;
							
							frame = 2;
						}
					}
					
					if(sequenceSegmentFrame3) {
						sequenceSegmentFrame3.start = 3 * sequenceSegmentFrame3.start + 2;
						sequenceSegmentFrame3.end = 3 * sequenceSegmentFrame3.end + 2;
						
						if(frame == 0 || sequenceSegmentFrame3.start < smallestStart) {
							frame = 3;
						}
					}
					
					if(revComSegmentFrame1) {
						revComSegmentFrame1.start = 3 * revComSegmentFrame1.start;
						revComSegmentFrame1.end = 3 * revComSegmentFrame1.end;
						
						if(frame == 0 || revComSegmentFrame1.start < smallestStart) {
							smallestStart = revComSegmentFrame1.start;
							
							frame = -1;
						}
					}
					
					if(revComSegmentFrame2) {
						revComSegmentFrame2.start = 3 * revComSegmentFrame2.start + 2;
						revComSegmentFrame2.end = 3 * revComSegmentFrame2.end + 2;
						
						if(frame == 0 || revComSegmentFrame2.start < smallestStart) {
							smallestStart = revComSegmentFrame2.start;
							
							frame = -2;
						}
					}
					
					if(revComSegmentFrame3) {
						revComSegmentFrame3.start = 3 * revComSegmentFrame3.start + 1;
						revComSegmentFrame3.end = 3 * revComSegmentFrame3.end + 1;
						
						if(frame == 0 || revComSegmentFrame3.start < smallestStart) {
							smallestStart = revComSegmentFrame3.start;
							
							frame = -3;
						}
					}
					
					if(frame == 1) {
						resultSegment = sequenceSegmentFrame1;
					} else if(frame == 2) {
						resultSegment = sequenceSegmentFrame2;
					} else if(frame == 3) {
						resultSegment = sequenceSegmentFrame3;
					} else if(frame == -1) {
						resultSegment = revComSegmentFrame1;
					} else if(frame == -2) {
						resultSegment = revComSegmentFrame2;
					} else if(frame == -3) {
						resultSegment = revComSegmentFrame3;
					}
					
					break;
			}
			
			return resultSegment;
		}
		
		public static function findAll(featuredSequence:FeaturedSequence, expression:String, dataType:String = Finder.DATA_TYPE_DNA, searchType:String = Finder.SEARCH_TYPE_LITTERAL):Array /* of Segment */
		{
			var result:Array; 
			
			switch(dataType) {
				case DATA_TYPE_DNA:
					if(searchType == Finder.SEARCH_TYPE_AMBIGUOUS) {
						expression = makeAmbiguousDNAExpression(expression);
					}
					
					var sequenceSegments:Array = FindUtils.findAll(featuredSequence.sequence.sequence, expression);
					var reverseComplementSegments:Array = FindUtils.findAll(SequenceUtils.reverseSequence(featuredSequence.oppositeSequence).sequence, expression);
					
					result = new Array();
					
					for(var k1:int = 0; k1 < sequenceSegments.length; k1++) {
						result.push(sequenceSegments[k1]);
					}
					
					for(var k2:int = 0; k2 < reverseComplementSegments.length; k2++) {
						result.push(new Segment(featuredSequence.sequence.length - (reverseComplementSegments[k2] as Segment).end, featuredSequence.sequence.length - (reverseComplementSegments[k2] as Segment).start))
					}
					
					break;
				case DATA_TYPE_AMINO_ACIDS:
					var aaMapper:AAMapper = new AAMapper(featuredSequence);
					
					expression = expression.toUpperCase();
					
					var segments1:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame1, expression);
					var segments2:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame2, expression);
					var segments3:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame3, expression);
					var revComSegments1:Array = FindUtils.findAll(aaMapper.revComAA1Frame1, expression);
					var revComSegments2:Array = FindUtils.findAll(aaMapper.revComAA1Frame2, expression);
					var revComSegments3:Array = FindUtils.findAll(aaMapper.revComAA1Frame3, expression);
					
					result = new Array();
					
					for(var i1:int = 0; i1 < segments1.length; i1++) {
						(segments1[i1] as Segment).start = 3 * (segments1[i1] as Segment).start;
						(segments1[i1] as Segment).end = 3 * (segments1[i1] as Segment).end;
						
						result.push((segments1[i1] as Segment));
					}
					
					for(var i2:int = 0; i2 < segments2.length; i2++) {
						(segments2[i2] as Segment).start = 3 * (segments2[i2] as Segment).start + 1;
						(segments2[i2] as Segment).end = 3 * (segments2[i2] as Segment).end + 1;
						
						result.push((segments2[i2] as Segment));
					}
					
					for(var i3:int = 0; i3 < segments3.length; i3++) {
						(segments3[i3] as Segment).start = 3 * (segments3[i3] as Segment).start + 2;
						(segments3[i3] as Segment).end = 3 * (segments3[i3] as Segment).end + 2;
						
						result.push((segments3[i3] as Segment));
					}
					
					for(var j1:int = 0; j1 < revComSegments1.length; j1++) {
						(revComSegments1[j1] as Segment).start = featuredSequence.sequence.length - 3 * (revComSegments1[j1] as Segment).start;
						(revComSegments1[j1] as Segment).end = featuredSequence.sequence.length - 3 * (revComSegments1[j1] as Segment).end;
						
						result.push((revComSegments1[j1] as Segment));
					}
					
					for(var j2:int = 0; j2 < revComSegments2.length; j2++) {
						(revComSegments2[j2] as Segment).start = featuredSequence.sequence.length - 3 * (revComSegments2[j2] as Segment).start - 1;
						(revComSegments2[j2] as Segment).end = featuredSequence.sequence.length - 3 * (revComSegments2[j2] as Segment).end - 1;
						
						result.push((revComSegments2[j2] as Segment));
					}
					
					for(var j3:int = 0; j3 < revComSegments3.length; j3++) {
						(revComSegments3[j3] as Segment).start = featuredSequence.sequence.length - 3 * (revComSegments3[j3] as Segment).start - 2;
						(revComSegments3[j3] as Segment).end = featuredSequence.sequence.length - 3 * (revComSegments3[j3] as Segment).end - 2;
						
						result.push((revComSegments3[j3] as Segment));
					}
					break;
			}
			
			return result;
		}
		
		private static function makeAmbiguousDNAExpression(expression:String):String
		{
			var result:String = "";
			
			expression = expression.toUpperCase();
			
			var expressionLength:int = expression.length;
			for(var i:int = 0; i < expressionLength; i++) {
				var char:String = expression.charAt(i);
				
				if(char == "A" || char == "T" || char == "C" || char == "G" || char == "U") {
					result += char;
				} else {
					switch(char) {
						case "N":
							result += "[ATGC]";
							break;
						case "K":
							result += "[GT]";
							break;
						case "M":
							result += "[AC]";
							break;
						case "R":
							result += "[AG]";
							break;
						case "Y":
							result += "[CT]";
							break;
						case "S":
							result += "[CG]";
							break;
						case "W":
							result += "[AT]";
							break;
						case "B":
							result += "[CGT]";
							break;
						case "V":
							result += "[ACG]";
							break;
						case "H":
							result += "[ACT]";
							break;
						case "D":
							result += "[AGT]";
							break;
						default:
							result += char;
							break;
					}
				}
			}
			
			return result;
		}
	}
}
