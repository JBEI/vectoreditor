package org.jbei.registry.utils
{
	import org.jbei.bio.sequence.common.Annotation;
	import org.jbei.lib.FindUtils;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.lib.mappers.AAMapper;

    /**
     * @author Zinovii Dmytriv
     */
	public class Finder
	{
		public static const DATA_TYPE_DNA:String = "DataTypeDNA";
		public static const DATA_TYPE_AMINO_ACIDS:String = "DataTypeAA";
		
		public static const SEARCH_TYPE_LITTERAL:String = "SearchTypeLitteral";
		public static const SEARCH_TYPE_AMBIGUOUS:String = "SearchTypeAmbiguous";
		
		// Public Methods
		public static function find(sequenceProvider:SequenceProvider, expression:String, dataType:String = Finder.DATA_TYPE_DNA, searchType:String = Finder.SEARCH_TYPE_LITTERAL, start:int = 0):Annotation
		{
			if(!sequenceProvider || sequenceProvider.sequence.length == 0 || expression.length == 0) { return null; }
			
			var resultAnnotation:Annotation = null;
			
			expression = expression.toUpperCase();
			
			switch(dataType) {
				case DATA_TYPE_DNA:
					if(searchType == Finder.SEARCH_TYPE_AMBIGUOUS) {
						expression = makeAmbiguousDNAExpression(expression);
					}
					
					var sequenceAnnotations:Array = FindUtils.findAll(sequenceProvider.sequence.seqString(), expression, sequenceProvider.circular);
					var reverseComplementAnnotation:Array = FindUtils.findAll(sequenceProvider.getReverseComplementSequence().seqString(), expression, sequenceProvider.circular);
					
					for(var i1:int = 0; i1 < sequenceAnnotations.length; i1++) {
						var annotation1:Annotation = sequenceAnnotations[i1] as Annotation;
						
						if(annotation1.start >= start) {
							if(resultAnnotation == null) {
								resultAnnotation = annotation1;
							} else {
								if(resultAnnotation.start > annotation1.start) {
									resultAnnotation = annotation1;
								}
							}
						}
					}
					
					var sequenceLength:int = sequenceProvider.sequence.length;
					
					for(var i2:int = 0; i2 < reverseComplementAnnotation.length; i2++) {
						var annotation2:Annotation = reverseComplementAnnotation[i2] as Annotation;
						
						var reverseStart:int = sequenceLength - annotation2.end;
						var reverseEnd:int = sequenceLength - annotation2.start;
						
						if(reverseStart >= start) {
							if(resultAnnotation == null) {
								resultAnnotation = new Annotation(reverseStart, reverseEnd);
							} else {
								if(resultAnnotation.start > reverseStart) {
									resultAnnotation = new Annotation(reverseStart, reverseEnd);
								}
							}
						}
					}
					
					break;
				case DATA_TYPE_AMINO_ACIDS:
					var aaMapper:AAMapper = new AAMapper(sequenceProvider);
					
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
					
					var sequenceAnnotationsFrame1:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame1, expression, false);
					var sequenceAnnotationsFrame2:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame2, expression, false);
					var sequenceAnnotationsFrame3:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame3, expression, false);
					
					var revComAnnotationsFrame1:Array = FindUtils.findAll(aaMapper.revComAA1Frame1, expression, false);
					var revComAnnotationsFrame2:Array = FindUtils.findAll(aaMapper.revComAA1Frame2, expression, false);
					var revComAnnotationsFrame3:Array = FindUtils.findAll(aaMapper.revComAA1Frame3, expression, false);
					
					// sparse AA1 annotations 
					for(var j1:int = 0; j1 < sequenceAnnotationsFrame1.length; j1++) {
						var annotationAA1:Annotation = sequenceAnnotationsFrame1[j1];
						
						if(position1 < annotationAA1.start) {
							if(resultAnnotation == null) {
								resultAnnotation = new Annotation(3 * annotationAA1.start, 3 * annotationAA1.end);
							} else if(resultAnnotation.start > 3 * annotationAA1.start) {
								resultAnnotation = new Annotation(3 * annotationAA1.start, 3 * annotationAA1.end);
							}
						}
					}
					
					for(var j2:int = 0; j2 < sequenceAnnotationsFrame2.length; j2++) {
						var annotationAA2:Annotation = sequenceAnnotationsFrame2[j2];
						
						if(position1 < annotationAA2.start) {
							if(resultAnnotation == null) {
								resultAnnotation = new Annotation(3 * annotationAA2.start + 1, 3 * annotationAA2.end + 1);
							} else if(resultAnnotation.start > 3 * annotationAA2.start + 1) {
								resultAnnotation = new Annotation(3 * annotationAA2.start + 1, 3 * annotationAA2.end + 1);
							}
						}
					}
					
					for(var j3:int = 0; j3 < sequenceAnnotationsFrame3.length; j3++) {
						var annotationAA3:Annotation = sequenceAnnotationsFrame3[j3];
						
						if(position1 < annotationAA3.start) {
							if(resultAnnotation == null) {
								resultAnnotation = new Annotation(3 * annotationAA3.start + 2, 3 * annotationAA3.end + 2);
							} else if(resultAnnotation.start > 3 * annotationAA3.start + 2) {
								resultAnnotation = new Annotation(3 * annotationAA3.start + 2, 3 * annotationAA3.end + 2);
							}
						}
					}
					
					for(var z1:int = 0; z1 < revComAnnotationsFrame1.length; z1++) {
						var revAnnotationAA1:Annotation = revComAnnotationsFrame1[z1] as Annotation;
						var normalizedStart1:int = sequenceProvider.sequence.length - 3 * revAnnotationAA1.end;
						var normalizedEnd1:int = sequenceProvider.sequence.length - 3 * revAnnotationAA1.start;
						
						if(position2 < normalizedStart1) {
							if(resultAnnotation == null) {
								resultAnnotation = new Annotation(normalizedStart1, normalizedEnd1);
							} else if(resultAnnotation.start > normalizedStart1) {
								resultAnnotation = new Annotation(normalizedStart1, normalizedEnd1);
							}
						}
					}
					
					for(var z2:int = 0; z2 < revComAnnotationsFrame2.length; z2++) {
						var revAnnotationAA2:Annotation = revComAnnotationsFrame2[z2] as Annotation;
						var normalizedStart2:int = sequenceProvider.sequence.length - 3 * revAnnotationAA2.end - 1;
						var normalizedEnd2:int = sequenceProvider.sequence.length - 3 * revAnnotationAA2.start - 1;
						
						if(position2 < normalizedStart2) {
							if(resultAnnotation == null) {
								resultAnnotation = new Annotation(normalizedStart2, normalizedEnd2);
							} else if(resultAnnotation.start > normalizedStart2) {
								resultAnnotation = new Annotation(normalizedStart2, normalizedEnd2);
							}
						}
					}
					
					for(var z3:int = 0; z3 < revComAnnotationsFrame3.length; z3++) {
						var revAnnotationAA3:Annotation = revComAnnotationsFrame3[z3] as Annotation;
						var normalizedStart3:int = sequenceProvider.sequence.length - 3 * revAnnotationAA3.end - 2;
						var normalizedEnd3:int = sequenceProvider.sequence.length - 3 * revAnnotationAA3.start - 2;
						
						if(position2 < normalizedStart3) {
							if(resultAnnotation == null) {
								resultAnnotation = new Annotation(normalizedStart3, normalizedEnd3);
							} else if(resultAnnotation.start > normalizedStart3) {
								resultAnnotation = new Annotation(normalizedStart3, normalizedEnd3);
							}
						}
					}
					
					break;
			}
			
			return resultAnnotation;
		}
		
		public static function findAll(sequenceProvider:SequenceProvider, expression:String, dataType:String = Finder.DATA_TYPE_DNA, searchType:String = Finder.SEARCH_TYPE_LITTERAL):Array /* of Annotation */
		{
			var result:Array; 
			
			switch(dataType) {
				case DATA_TYPE_DNA:
					if(searchType == Finder.SEARCH_TYPE_AMBIGUOUS) {
						expression = makeAmbiguousDNAExpression(expression);
					}
					
					var sequenceAnnotations:Array = FindUtils.findAll(sequenceProvider.sequence.seqString(), expression, sequenceProvider.circular);
					var reverseComplementAnnotations:Array = FindUtils.findAll(sequenceProvider.getReverseComplementSequence().seqString(), expression, sequenceProvider.circular);
					
					result = new Array();
					
					for(var k1:int = 0; k1 < sequenceAnnotations.length; k1++) {
						result.push(sequenceAnnotations[k1]);
					}
					
					for(var k2:int = 0; k2 < reverseComplementAnnotations.length; k2++) {
						result.push(new Annotation(sequenceProvider.sequence.length - (reverseComplementAnnotations[k2] as Annotation).end, sequenceProvider.sequence.length - (reverseComplementAnnotations[k2] as Annotation).start))
					}
					
					break;
				case DATA_TYPE_AMINO_ACIDS:
					var aaMapper:AAMapper = new AAMapper(sequenceProvider);
					
					expression = expression.toUpperCase();
					
					var annotations1:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame1, expression, sequenceProvider.circular);
					var annotations2:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame2, expression, sequenceProvider.circular);
					var annotations3:Array = FindUtils.findAll(aaMapper.sequenceAA1Frame3, expression, sequenceProvider.circular);
					var revComAnnotations1:Array = FindUtils.findAll(aaMapper.revComAA1Frame1, expression, sequenceProvider.circular);
					var revComAnnotations2:Array = FindUtils.findAll(aaMapper.revComAA1Frame2, expression, sequenceProvider.circular);
					var revComAnnotations3:Array = FindUtils.findAll(aaMapper.revComAA1Frame3, expression, sequenceProvider.circular);
					
					result = new Array();
					
					for(var i1:int = 0; i1 < annotations1.length; i1++) {
						(annotations1[i1] as Annotation).start = 3 * (annotations1[i1] as Annotation).start;
						(annotations1[i1] as Annotation).end = 3 * (annotations1[i1] as Annotation).end;
						
						result.push((annotations1[i1] as Annotation));
					}
					
					for(var i2:int = 0; i2 < annotations2.length; i2++) {
						(annotations2[i2] as Annotation).start = 3 * (annotations2[i2] as Annotation).start + 1;
						(annotations2[i2] as Annotation).end = 3 * (annotations2[i2] as Annotation).end + 1;
						
						result.push((annotations2[i2] as Annotation));
					}
					
					for(var i3:int = 0; i3 < annotations3.length; i3++) {
						(annotations3[i3] as Annotation).start = 3 * (annotations3[i3] as Annotation).start + 2;
						(annotations3[i3] as Annotation).end = 3 * (annotations3[i3] as Annotation).end + 2;
						
						result.push((annotations3[i3] as Annotation));
					}
					
					for(var j1:int = 0; j1 < revComAnnotations1.length; j1++) {
						result.push(new Annotation(sequenceProvider.sequence.length - 3 * (revComAnnotations1[j1] as Annotation).end, sequenceProvider.sequence.length - 3 * (revComAnnotations1[j1] as Annotation).start));
					}
					
					for(var j2:int = 0; j2 < revComAnnotations2.length; j2++) {
						result.push(new Annotation(sequenceProvider.sequence.length - 3 * (revComAnnotations2[j2] as Annotation).end - 1, sequenceProvider.sequence.length - 3 * (revComAnnotations2[j2] as Annotation).start - 1));
					}
					
					for(var j3:int = 0; j3 < revComAnnotations3.length; j3++) {
						result.push(new Annotation(sequenceProvider.sequence.length - 3 * (revComAnnotations3[j3] as Annotation).end - 2, sequenceProvider.sequence.length - 3 * (revComAnnotations3[j3] as Annotation).start - 2));
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
