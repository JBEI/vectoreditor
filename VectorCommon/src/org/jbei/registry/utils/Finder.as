package org.jbei.registry.utils
{
	import org.jbei.bio.sequence.common.Annotation;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FindUtils;
	import org.jbei.lib.mappers.AAMapper;

	public class Finder
	{
		public static const DATA_TYPE_DNA:String = "DataTypeDNA";
		public static const DATA_TYPE_AMINO_ACIDS:String = "DataTypeAA";
		
		public static const SEARCH_TYPE_LITTERAL:String = "SearchTypeLitteral";
		public static const SEARCH_TYPE_AMBIGUOUS:String = "SearchTypeAmbiguous";
		
		// Public Methods
		public static function find(featuredSequence:FeaturedSequence, expression:String, dataType:String = Finder.DATA_TYPE_DNA, searchType:String = Finder.SEARCH_TYPE_LITTERAL, start:int = 0):Annotation
		{
			if(!featuredSequence || featuredSequence.sequence.length == 0 || expression.length == 0) { return null; }
			
			var resultSegment:Annotation = null;
			
			expression = expression.toUpperCase();
			
			switch(dataType) {
				case DATA_TYPE_DNA:
					if(searchType == Finder.SEARCH_TYPE_AMBIGUOUS) {
						expression = makeAmbiguousDNAExpression(expression);
					}
					
					var sequenceSegments:Array = FindUtils.findAll(featuredSequence.sequence.seqString(), expression, featuredSequence.circular);
					var reverseComplementSegment:Array = FindUtils.findAll(featuredSequence.getReverseComplementSequence().seqString(), expression, featuredSequence.circular);
					
					for(var i1:int = 0; i1 < sequenceSegments.length; i1++) {
						var segment1:Annotation = sequenceSegments[i1] as Annotation;
						
						if(segment1.start >= start) {
							if(resultSegment == null) {
								resultSegment = segment1;
							} else {
								if(resultSegment.start > segment1.start) {
									resultSegment = segment1;
								}
							}
						}
					}
					
					var sequenceLength:int = featuredSequence.sequence.length;
					
					for(var i2:int = 0; i2 < reverseComplementSegment.length; i2++) {
						var segment2:Annotation = reverseComplementSegment[i2] as Annotation;
						
						var reverseStart:int = sequenceLength - segment2.end;
						var reverseEnd:int = sequenceLength - segment2.start;
						
						if(reverseStart >= start) {
							if(resultSegment == null) {
								resultSegment = new Annotation(reverseStart, reverseEnd);
							} else {
								if(resultSegment.start > reverseStart) {
									resultSegment = new Annotation(reverseStart, reverseEnd);
								}
							}
						}
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
					if(start == 0) {
						position2 = 0;
					} else {
						if(start % 3 == 0) {
							position2 = start + 3;
						} else if(start % 3 == 1) {
							position2 = start + 2;
						} else if(start % 3 == 2) {
							position2 = start + 1;
						}
					}
					
					var sequenceSegmentsFrame1:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame1, expression, false);
					var sequenceSegmentsFrame2:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame2, expression, false);
					var sequenceSegmentsFrame3:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame3, expression, false);
					
					var revComSegmentsFrame1:Array = FindUtils.findAll(aaMapper.revComAA1Frame1, expression, false);
					var revComSegmentsFrame2:Array = FindUtils.findAll(aaMapper.revComAA1Frame2, expression, false);
					var revComSegmentsFrame3:Array = FindUtils.findAll(aaMapper.revComAA1Frame3, expression, false);
					
					// sparse AA1 segments 
					for(var j1:int = 0; j1 < sequenceSegmentsFrame1.length; j1++) {
						var segmentAA1:Annotation = sequenceSegmentsFrame1[j1];
						
						if(position1 < segmentAA1.start) {
							if(resultSegment == null) {
								resultSegment = new Annotation(3 * segmentAA1.start, 3 * segmentAA1.end);
							} else if(resultSegment.start > 3 * segmentAA1.start) {
								resultSegment = new Annotation(3 * segmentAA1.start, 3 * segmentAA1.end);
							}
						}
					}
					
					for(var j2:int = 0; j2 < sequenceSegmentsFrame2.length; j2++) {
						var segmentAA2:Annotation = sequenceSegmentsFrame2[j2];
						
						if(position1 < segmentAA2.start) {
							if(resultSegment == null) {
								resultSegment = new Annotation(3 * segmentAA2.start + 1, 3 * segmentAA2.end + 1);
							} else if(resultSegment.start > 3 * segmentAA2.start + 1) {
								resultSegment = new Annotation(3 * segmentAA2.start + 1, 3 * segmentAA2.end + 1);
							}
						}
					}
					
					for(var j3:int = 0; j3 < sequenceSegmentsFrame3.length; j3++) {
						var segmentAA3:Annotation = sequenceSegmentsFrame3[j3];
						
						if(position1 < segmentAA3.start) {
							if(resultSegment == null) {
								resultSegment = new Annotation(3 * segmentAA3.start + 2, 3 * segmentAA3.end + 2);
							} else if(resultSegment.start > 3 * segmentAA3.start + 2) {
								resultSegment = new Annotation(3 * segmentAA3.start + 2, 3 * segmentAA3.end + 2);
							}
						}
					}
					
					for(var z1:int = 0; z1 < revComSegmentsFrame1.length; z1++) {
						var revSegmentAA1:Annotation = revComSegmentsFrame1[z1] as Annotation;
						var normalizedStart1:int = featuredSequence.sequence.length - 3 * revSegmentAA1.end;
						var normalizedEnd1:int = featuredSequence.sequence.length - 3 * revSegmentAA1.start;
						
						if(position2 < normalizedStart1) {
							if(resultSegment == null) {
								resultSegment = new Annotation(normalizedStart1, normalizedEnd1);
							} else if(resultSegment.start > normalizedStart1) {
								resultSegment = new Annotation(normalizedStart1, normalizedEnd1);
							}
						}
					}
					
					for(var z2:int = 0; z2 < revComSegmentsFrame2.length; z2++) {
						var revSegmentAA2:Annotation = revComSegmentsFrame2[z2] as Annotation;
						var normalizedStart2:int = featuredSequence.sequence.length - 3 * revSegmentAA2.end - 1;
						var normalizedEnd2:int = featuredSequence.sequence.length - 3 * revSegmentAA2.start - 1;
						
						if(position2 < normalizedStart2) {
							if(resultSegment == null) {
								resultSegment = new Annotation(normalizedStart2, normalizedEnd2);
							} else if(resultSegment.start > normalizedStart2) {
								resultSegment = new Annotation(normalizedStart2, normalizedEnd2);
							}
						}
					}
					
					for(var z3:int = 0; z3 < revComSegmentsFrame3.length; z3++) {
						var revSegmentAA3:Annotation = revComSegmentsFrame3[z3] as Annotation;
						var normalizedStart3:int = featuredSequence.sequence.length - 3 * revSegmentAA3.end - 2;
						var normalizedEnd3:int = featuredSequence.sequence.length - 3 * revSegmentAA3.start - 2;
						
						if(position2 < normalizedStart3) {
							if(resultSegment == null) {
								resultSegment = new Annotation(normalizedStart3, normalizedEnd3);
							} else if(resultSegment.start > normalizedStart3) {
								resultSegment = new Annotation(normalizedStart3, normalizedEnd3);
							}
						}
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
					
					var sequenceSegments:Array = FindUtils.findAll(featuredSequence.sequence.seqString(), expression, featuredSequence.circular);
					var reverseComplementSegments:Array = FindUtils.findAll(featuredSequence.getReverseComplementSequence().seqString(), expression, featuredSequence.circular);
					
					result = new Array();
					
					for(var k1:int = 0; k1 < sequenceSegments.length; k1++) {
						result.push(sequenceSegments[k1]);
					}
					
					for(var k2:int = 0; k2 < reverseComplementSegments.length; k2++) {
						result.push(new Annotation(featuredSequence.sequence.length - (reverseComplementSegments[k2] as Annotation).end, featuredSequence.sequence.length - (reverseComplementSegments[k2] as Annotation).start))
					}
					
					break;
				case DATA_TYPE_AMINO_ACIDS:
					var aaMapper:AAMapper = new AAMapper(featuredSequence);
					
					expression = expression.toUpperCase();
					
					var segments1:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame1, expression, featuredSequence.circular);
					var segments2:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame2, expression, featuredSequence.circular);
					var segments3:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame3, expression, featuredSequence.circular);
					var revComSegments1:Array = FindUtils.findAll(aaMapper.revComAA1Frame1, expression, featuredSequence.circular);
					var revComSegments2:Array = FindUtils.findAll(aaMapper.revComAA1Frame2, expression, featuredSequence.circular);
					var revComSegments3:Array = FindUtils.findAll(aaMapper.revComAA1Frame3, expression, featuredSequence.circular);
					
					result = new Array();
					
					for(var i1:int = 0; i1 < segments1.length; i1++) {
						(segments1[i1] as Annotation).start = 3 * (segments1[i1] as Annotation).start;
						(segments1[i1] as Annotation).end = 3 * (segments1[i1] as Annotation).end;
						
						result.push((segments1[i1] as Annotation));
					}
					
					for(var i2:int = 0; i2 < segments2.length; i2++) {
						(segments2[i2] as Annotation).start = 3 * (segments2[i2] as Annotation).start + 1;
						(segments2[i2] as Annotation).end = 3 * (segments2[i2] as Annotation).end + 1;
						
						result.push((segments2[i2] as Annotation));
					}
					
					for(var i3:int = 0; i3 < segments3.length; i3++) {
						(segments3[i3] as Annotation).start = 3 * (segments3[i3] as Annotation).start + 2;
						(segments3[i3] as Annotation).end = 3 * (segments3[i3] as Annotation).end + 2;
						
						result.push((segments3[i3] as Annotation));
					}
					
					for(var j1:int = 0; j1 < revComSegments1.length; j1++) {
						result.push(new Annotation(featuredSequence.sequence.length - 3 * (revComSegments1[j1] as Annotation).end, featuredSequence.sequence.length - 3 * (revComSegments1[j1] as Annotation).start));
					}
					
					for(var j2:int = 0; j2 < revComSegments2.length; j2++) {
						result.push(new Annotation(featuredSequence.sequence.length - 3 * (revComSegments2[j2] as Annotation).end - 1, featuredSequence.sequence.length - 3 * (revComSegments2[j2] as Annotation).start - 1));
					}
					
					for(var j3:int = 0; j3 < revComSegments3.length; j3++) {
						result.push(new Annotation(featuredSequence.sequence.length - 3 * (revComSegments3[j3] as Annotation).end - 2, featuredSequence.sequence.length - 3 * (revComSegments3[j3] as Annotation).start - 2));
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
