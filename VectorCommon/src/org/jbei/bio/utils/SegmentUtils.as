package org.jbei.bio.utils
{
	import org.jbei.bio.data.Segment;

	public class SegmentUtils
	{
		/* Verifies if segment1 contains segment2 */
		public static function contains(segment1:Segment, segment2:Segment):Boolean
		{
			var result:Boolean = false;
			
			if(segment1.start <= segment1.end) { // segment1 non-circular
				if(segment2.start <= segment2.end) { // segment2 non-circular 
					result = ((segment1.start <= segment2.start) && (segment1.end >= segment2.end)); 
				}
			} else { // segment1 circular
				if(segment2.start <= segment2.end) { // segment2 non-circular
					result = ((segment2.end <= segment1.end) || (segment2.start >= segment1.start));
				} else { // segment1 circular
					result = ((segment1.start <= segment2.start) && (segment1.end >= segment2.end));
				}
			}
			
			return result;
		}
		
		public static function overlaps(segment1:Segment, segment2:Segment):Boolean
		{
			// Not implemented
			
			return false;
		}
	}
}
