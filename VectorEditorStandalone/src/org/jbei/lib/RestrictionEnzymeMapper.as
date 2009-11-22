package org.jbei.lib
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.utils.RestrictionEnzymesUtils;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.registry.model.vo.RestrictionEnzymeGroup;

	public class RestrictionEnzymeMapper extends EventDispatcher
	{
		private var dirty:Boolean = true;
		private var _cutSites:ArrayCollection /* of CutSite */;
		private var _cutSitesMap:Dictionary /* [RestrictionEnzyme] = Array(CutSite) */;
		private var _maxRestrictionEnzymeCuts:int = -1;
		private var _restrictionEnzymeGroup:RestrictionEnzymeGroup;
		private var _featuredSequence:FeaturedSequence;
		
		// Constructor
		public function RestrictionEnzymeMapper(featuredSequence:FeaturedSequence, restrictionEnzymeGroup:RestrictionEnzymeGroup)
		{
			super();
			
			_featuredSequence = featuredSequence;
			_restrictionEnzymeGroup = restrictionEnzymeGroup;
			_featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
		}
		
		// Properties
		public function get cutSites():ArrayCollection /* of CutSite */
		{
			if(dirty) {
				recalculate();
				
				CONFIG::debugging {
					trace("RE MAP REQUESTED AND RECALCULATED!");
				}
				
				dirty = false;
			}
			
			return _cutSites;
		}
		
		public function get cutSitesMap():Dictionary /* [RestrictionEnzyme] = Array(CutSite) */
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _cutSitesMap;
		}
		
		public function get maxRestrictionEnzymeCuts():int
		{
			return _maxRestrictionEnzymeCuts;
		}
		
		public function set maxRestrictionEnzymeCuts(value:int):void
		{
			if(value != _maxRestrictionEnzymeCuts) {
				if(value <= 0) value = -1;
				
				_maxRestrictionEnzymeCuts = value;
				
				dirty = true;
			}
		}
		
		// Public Methods
		public function markAsDirty():void
		{
			dirty = true;
		}
		
		// Private Methods
		private function recalculate():void
		{
			if(_featuredSequence && _restrictionEnzymeGroup && _restrictionEnzymeGroup.enzymes.length > 0) {
				_cutSitesMap = RestrictionEnzymesUtils.cutByRestrictionEnzymesGroup(_restrictionEnzymeGroup.enzymes, _featuredSequence.sequence, SequenceUtils.reverseSequence(_featuredSequence.oppositeSequence), _featuredSequence.circular);
				
				_cutSites = new ArrayCollection();
				for(var restrictionEnzyme:Object in _cutSitesMap) {
					var tmpArray:Array = _cutSitesMap[restrictionEnzyme];
					
					if(tmpArray && tmpArray.length > 0) {
						for(var i:int = 0; i < tmpArray.length; i++) {
							_cutSites.addItem(tmpArray[i]);
						}
					}
				}
			} else {
				_cutSites = null;
				_cutSitesMap = null;
			}
			
			dispatchEvent(new RestrictionEnzymeMapperEvent(RestrictionEnzymeMapperEvent.RESTRICTION_ENZYME_MAPPER_UPDATED));
		}
		
		private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
		{
			dirty = true;
		}
	}
}
