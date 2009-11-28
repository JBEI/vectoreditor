package org.jbei.registry.utils
{
	import org.jbei.bio.data.Segment;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.utils.FindUtils;

	public class Finder
	{
		public static const TYPE_BOTH:String = "TypeBoth";
		public static const TYPE_SEQUENCE_ONLY:String = "TypeSequenceOnly";
		public static const TYPE_REVERSE_COMPLEMENT_ONLY:String = "TypeReverseComplementOnly";
		
		// Public Methods
		public static function find(featuredSequence:FeaturedSequence, expression:String, type:String = Finder.TYPE_SEQUENCE_ONLY, start:int = 0):Segment
		{
			if(!featuredSequence || featuredSequence.sequence.length == 0 || expression.length == 0) { return null; }
			
			var resultSegment:Segment = null;
			
			switch(type) {
				case TYPE_SEQUENCE_ONLY:
					resultSegment = FindUtils.find(featuredSequence.sequence.sequence, expression, start);
					
					break;
				case TYPE_REVERSE_COMPLEMENT_ONLY:
					resultSegment = FindUtils.findLast(SequenceUtils.reverseSequence(featuredSequence.oppositeSequence).sequence, expression, featuredSequence.sequence.length - start);
					
					break;
				case TYPE_BOTH:
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
			}
			
			return resultSegment;
		}
		
		public static function findAll(featuredSequence:FeaturedSequence, expression:String, type:String = Finder.TYPE_SEQUENCE_ONLY):Array /* of Segment */
		{
			var result:Array; 
			
			switch(type) {
				case TYPE_SEQUENCE_ONLY:
					result = FindUtils.findAll(featuredSequence.sequence.sequence, expression);
					
					break;
				case TYPE_REVERSE_COMPLEMENT_ONLY:
					var reverseSegments:Array = FindUtils.findAll(SequenceUtils.reverseSequence(featuredSequence.oppositeSequence).sequence, expression);
					
					result = new Array();
					
					for(var i:int = 0; i < reverseSegments.length; i++) {
						result.push(new Segment(featuredSequence.sequence.length - (reverseSegments[i] as Segment).end, featuredSequence.sequence.length - (reverseSegments[i] as Segment).start))
					}
					
					break;
				case TYPE_BOTH:
					var sequenceSegments:Array = FindUtils.findAll(featuredSequence.sequence.sequence, expression);
					var reverseComplementSegments:Array = FindUtils.findAll(SequenceUtils.reverseSequence(featuredSequence.oppositeSequence).sequence, expression);
					
					result = new Array();
					
					for(var j1:int = 0; j1 < sequenceSegments.length; j1++) {
						result.push(sequenceSegments[j1]);
					}
					
					for(var j2:int = 0; j2 < reverseComplementSegments.length; j2++) {
						result.push(new Segment(featuredSequence.sequence.length - (reverseComplementSegments[j2] as Segment).end, featuredSequence.sequence.length - (reverseComplementSegments[j2] as Segment).start))
					}
					
					break;
			}
			
			return result;
		}
	}
}
