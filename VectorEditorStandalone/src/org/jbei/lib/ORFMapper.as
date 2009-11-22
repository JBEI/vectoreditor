package org.jbei.lib
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.utils.ORFUtils;
	import org.jbei.bio.utils.SequenceUtils;
	
	public class ORFMapper extends EventDispatcher
	{
		private var dirty:Boolean = true;
		private var _orfs:ArrayCollection /* of ORF */;
		private var _minORFSize:int = 300;
		private var _featuredSequence:FeaturedSequence;
		
		// Constructor
		public function ORFMapper(featuredSequence:FeaturedSequence)
		{
			super();
			
			_featuredSequence = featuredSequence;
			_featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
		}
		
		// Properties
		public function get orfs():ArrayCollection /* of ORF */
		{
			if(dirty) {
				recalculate();
				
				CONFIG::debugging {
					trace("ORF REQUESTED AND RECALCULATED!");
				}
				
				dirty = false;
			}
			
			return _orfs;
		}
		
		public function get minORFSize():int
		{
			return _minORFSize
		}
		
		public function set minORFSize(value:int):void
		{
			if(_minORFSize != value) {
				_minORFSize = value;
				
				dirty = true;
			}
		}
		
		// Private Methods
		private function recalculate():void
		{
			if(_featuredSequence) {
				var orfsSequence:Array = ORFUtils.calculateORFs(_featuredSequence.sequence, _minORFSize);
				var reverseComplementSequence:DNASequence = SequenceUtils.reverseSequence(_featuredSequence.oppositeSequence);
				
				var orfsComplimentary:Array = ORFUtils.calculateReverseComplementaryORFs(reverseComplementSequence, _minORFSize);
				
				_orfs = new ArrayCollection();
				for(var i:int = 0; i < orfsSequence.length; i++) {
					_orfs.addItem(orfsSequence[i]);
				}
				
				for(var j:int = 0; j < orfsComplimentary.length; j++) {
					_orfs.addItem(orfsComplimentary[j]);
				}
			} else {
				_orfs = null;
			}
			
			dispatchEvent(new ORFMapperEvent(ORFMapperEvent.ORF_MAPPER_UPDATED));
		}
		
		private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
		{
			dirty = true;
		}
	}
}
