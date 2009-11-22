package org.jbei.components.common
{
	import org.jbei.bio.data.IAnnotation;
	import org.jbei.lib.FeaturedSequence;
	
	public class Alignment
	{
		private var _rows:Array = new Array() /* of Array of IAnnotation */;
		private var _numberOfRows:uint = 0;
		private var annotations:Array /* of IAnnotation */;
		private var featuredSequence:FeaturedSequence;
		
		// Constructor
		public function Alignment(annotations:Array /* of IAnnotation */, featuredSequence:FeaturedSequence)
		{
			super();
			
			this.annotations = annotations;
			this.featuredSequence = featuredSequence;
			
			if(annotations != null) {
				buildAnnotation();
			}
		}
		
		// Properties
		public function get rows():Array
		{
			return _rows;
		}
		
		public function get numberOfRows():uint
		{
			return _numberOfRows;
		}
		
		// Private Methods
		private function buildAnnotation():void 
		{
			annotations.sort(sortAnnotationsByLength);
			
			var numberOfAnnotations:uint = annotations.length;
			for(var i:uint = 0; i < numberOfAnnotations; i++) {
				fit(annotations[i]);
			}
		}
		
		private function sortAnnotationsByLength(annotation1:IAnnotation, annotation2:IAnnotation):int
		{
			var annotation1Length:int = (annotation1.start > annotation1.end) ? (annotation1.end + featuredSequence.sequence.length - annotation1.start + 1) : (annotation1.end - annotation1.start + 1);
			var annotation2Length:int = (annotation2.start > annotation2.end) ? (annotation2.end + featuredSequence.sequence.length - annotation2.start + 1) : (annotation2.end - annotation2.start + 1);
			
		    if(annotation1Length < annotation2Length) {
		        return 1;
		    } else if(annotation1Length > annotation2Length) {
		        return -1;
		    } else  {
		        return 0;
		    }
		}
		
		private function sortAnnotationsByStartPosition(annotation1:IAnnotation, annotation2:IAnnotation):int
		{
			var annotation1Start:int = annotation1.start;
			var annotation2Start:int = annotation2.start;
			
			if(annotation1Start > annotation2Start) {
				return 1;
			} else if(annotation1Start < annotation2Start) {
				return -1;
			} else  {
				return 0;
			}
		}
		
		private function doesFitInRow(row:Array /* of IAnnotation */, annotation:IAnnotation):Boolean
		{
			var length:uint = row.length;
			
			var fits:Boolean = true;
			for(var i:uint = 0; i < length; i++) {
				if(annotationsOverlaps(row[i] as IAnnotation, annotation)) {
					fits = false;
					break;
				}
			}
			
			return fits;
		}
		
		private function fit(annotation:IAnnotation):void
		{
			// Trying to fit in existing rows
			var doesFitInRows:Boolean = false;
			for(var i:uint = 0; i < _numberOfRows; i++) {
				if(doesFitInRow(_rows[i], annotation)) {
					doesFitInRows = true;
					
					_rows[i].push(annotation);
					
					break;
				}
			}
			
			// If doesn't fit in existing rows create new row for annotation
			if(! doesFitInRows) {
				_rows.push(new Array());
				_rows[_numberOfRows].push(annotation);
				_numberOfRows++;
			}
		}
		
		private function annotationsOverlaps(annotation1:IAnnotation, annotation2:IAnnotation):Boolean
		{
			var result:Boolean = false;
			
			/* |-------------------------------------------------------------------------------------------------|
			*   AAAAAAAAAAAAAAAAAAA|                                                    |AAAAAAAAAAAAAAAAAAAAAAAA                                  
			*   BBBBBBBBBBBBBBBBBBBBBBBBBBBB|                                                 |BBBBBBBBBBBBBBBBBB  */
			if(annotation1.start > annotation1.end && annotation2.start > annotation2.end) {
				result = doOverlaps(annotation1.start, featuredSequence.sequence.length - 1, annotation2.start, featuredSequence.sequence.length - 1) || doOverlaps(0, annotation1.start, 0, annotation2.end);
			}
			/* |-------------------------------------------------------------------------------------------------|
			*   AAAAAAAAAAAAAAAAAAAAAAAAAAA|                                                 |AAAAAAAAAAAAAAAAAAA
			*                          |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB|                                   */
			else if(annotation1.start > annotation1.end && annotation2.start <= annotation2.end) {
				result = doOverlaps(annotation1.start, featuredSequence.sequence.length - 1, annotation2.start, annotation2.end) || doOverlaps(0, annotation1.end, annotation2.start, annotation2.end);
			}
			/* |-------------------------------------------------------------------------------------------------|
			*                          |AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|                                  
			*   BBBBBBBBBBBBBBBBBBBBBBBBBBBB|                                                 |BBBBBBBBBBBBBBBBBB  */
			else if(annotation1.start <= annotation1.end && annotation2.start > annotation2.end) {
				result = doOverlaps(annotation1.start, annotation1.end, annotation2.start, featuredSequence.sequence.length - 1) || doOverlaps(annotation1.start, annotation1.end, 0, annotation2.end);
			}
			/* |-------------------------------------------------------------------------------------------------|
			*        |AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|
			*                                       |BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB|                      */
			else {
				result = doOverlaps(annotation1.start, annotation1.end, annotation2.start, annotation2.end);
			}
			
			return result;
		}
		
		private function doOverlaps(start1:int, end1:int, start2:int, end2:int):Boolean
		{
			return ((start2 < start1) && (start1 < end2)) || ((start2 >= start1) && (start2 <= end1));
		}
	}
}
