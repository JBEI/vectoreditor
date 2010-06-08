package org.jbei.lib.mappers
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.RestrictionEnzymeGroup;
	import org.jbei.bio.enzymes.RestrictionCutSite;
	import org.jbei.bio.enzymes.RestrictionEnzyme;
	import org.jbei.bio.enzymes.RestrictionEnzymeMapper;
	import org.jbei.bio.sequence.DNATools;
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;

	public class RestrictionEnzymeMapper extends EventDispatcher
	{
		private var dirty:Boolean = true;
		private var _cutSites:ArrayCollection /* of CutSite */;
		private var _cutSitesMap:Dictionary /* [RestrictionEnzyme] = Array(CutSite) */;
		private var _allCutSites:ArrayCollection /* of CutSite */;
		private var _allCutSitesMap:Dictionary /* [RestrictionEnzyme] = Array(CutSite) */;
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
		public function get allCutSites():ArrayCollection /* of CutSite */
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _allCutSites;
		}
		
		public function get cutSites():ArrayCollection /* of CutSite */
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _cutSites;
		}
		
		public function get allCutSitesMap():Dictionary /* [RestrictionEnzyme] = Array(CutSite) */
		{
			if(dirty) {
				recalculate();
				
				dirty = false;
			}
			
			return _allCutSitesMap;
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
				if(_featuredSequence.circular) {
					recalculateCircular();
				} else {
					recalculateNonCircular();
				}
			} else {
				_cutSites = null;
				_cutSitesMap = null;
			}
			
			dispatchEvent(new RestrictionEnzymeMapperEvent(RestrictionEnzymeMapperEvent.RESTRICTION_ENZYME_MAPPER_UPDATED));
		}
		
		private function recalculateNonCircular():void
		{
			var cutSites:Dictionary = org.jbei.bio.enzymes.RestrictionEnzymeMapper.cutSequence(_restrictionEnzymeGroup.enzymes, _featuredSequence.sequence);
			
			eliminateDuplicates(cutSites, new Dictionary());
		}
		
		// TODO: Optimize this
		private function recalculateCircular():void
		{
			var normalCutSites:Dictionary = org.jbei.bio.enzymes.RestrictionEnzymeMapper.cutSequence(_restrictionEnzymeGroup.enzymes, DNATools.createDNA(_featuredSequence.sequence.seqString() + _featuredSequence.sequence.seqString()));
			//var reverseCutSites:Dictionary = org.jbei.bio.enzymes.RestrictionEnzymeMapper.cutReverseComplementary(_restrictionEnzymeGroup.enzymes, DNATools.createDNA(_featuredSequence.getReverseComplementSequence().seqString() + _featuredSequence.getReverseComplementSequence().seqString()));
			
			var sequenceLength:int = _featuredSequence.sequence.length;
			for(var restrictionEnzyme:Object in normalCutSites) {
				var normalCutSitesList:Vector.<RestrictionCutSite> = normalCutSites[restrictionEnzyme];
				//var reverseCutSitesList:Array = reverseCutSites[restrictionEnzyme];
				
				// emiminating cut sites that are over sequence length
				normalCutSites[restrictionEnzyme] = new Vector.<RestrictionCutSite>();
				for(var k1:int = 0; k1 < normalCutSitesList.length; k1++) {
					var cutSite1:RestrictionCutSite = normalCutSitesList[k1] as RestrictionCutSite;
					
					if(cutSite1.start >= sequenceLength) {
					} else if(cutSite1.end < sequenceLength) {
						(normalCutSites[restrictionEnzyme] as Vector.<RestrictionCutSite>).push(cutSite1);
					} else {
						cutSite1.end -= sequenceLength;
						(normalCutSites[restrictionEnzyme] as Vector.<RestrictionCutSite>).push(cutSite1);
					}
				}
				
				/*reverseCutSites[restrictionEnzyme] = new Array();
				for(var k2:int = 0; k2 < reverseCutSitesList.length; k2++) {
					var cutSite2:RestrictionCutSite = reverseCutSitesList[k2] as RestrictionCutSite;
					
					if(cutSite2.start >= sequenceLength) {
					} else if(cutSite2.end < sequenceLength) {
						(reverseCutSites[restrictionEnzyme] as Array).push(cutSite2);
					} else {
						cutSite2.end -= sequenceLength;
						(reverseCutSites[restrictionEnzyme] as Array).push(cutSite2);
					}
				}*/
			}
			
			eliminateDuplicates(normalCutSites, new Dictionary());
		}
		
		private function eliminateDuplicates(normalCutSites:Dictionary, reverseCutSites:Dictionary):void
		{
			_cutSites = new ArrayCollection();
			_cutSitesMap = new Dictionary();
			_allCutSites = new ArrayCollection();
			_allCutSitesMap = new Dictionary();
			
			for(var restrictionEnzyme:Object in normalCutSites) {
				var tmpArray1:Vector.<RestrictionCutSite> = normalCutSites[restrictionEnzyme];
				var tmpArray2:Vector.<RestrictionCutSite> = reverseCutSites[restrictionEnzyme];
				
				_allCutSitesMap[restrictionEnzyme] = new Array();
				
				var numCuts:int = 0;
				var csMap:Array = _allCutSitesMap[restrictionEnzyme];
				
				for(var k:int = 0; k < tmpArray1.length; k++) {
					_allCutSites.addItem(tmpArray1[k]);
					csMap.push(tmpArray1[k]);
					numCuts++;
				}
				
                if(tmpArray2) {
    				for(var i:int = 0; i < tmpArray2.length; i++) {
    					var cutSite2:RestrictionCutSite = tmpArray2[i] as RestrictionCutSite;
    					
    					var skip:Boolean = false;
    					for(var j:int = 0; j < tmpArray1.length; j++) {
    						var cutSite1:RestrictionCutSite = tmpArray1[j] as RestrictionCutSite;
    						
    						if(cutSite1.start == cutSite2.start && cutSite1.end == cutSite2.end) {
    							skip = true;
    							break;
    						}
    					}
    					
    					if(! skip) {
    						_allCutSites.addItem(cutSite2);
    						csMap.push(cutSite2);
    						numCuts++;
    					}
    				}
                }
				
				for(var l:int = 0; l < csMap.length; l++) {
					(csMap[l] as RestrictionCutSite).numCuts = numCuts;
				}
			}
			
			if(_maxRestrictionEnzymeCuts > 0 && _allCutSites.length > 0) {
				for(var c1:int = 0; c1 < _allCutSites.length; c1++) {
					if((_allCutSites[c1] as RestrictionCutSite).numCuts <= maxRestrictionEnzymeCuts) {
						_cutSites.addItem(_allCutSites[c1]);
					}
				}
				
				for(var re:Object in _allCutSitesMap) {
					var cuts:Array = _allCutSitesMap[re] as Array;
					
					_cutSitesMap[re] = new Array();
					
					if(cuts.length > 0 && (cuts[0] as RestrictionCutSite).numCuts <= maxRestrictionEnzymeCuts) {
						for(var c2:int = 0; c2 < cuts.length; c2++) {
							(_cutSitesMap[re] as Array).push(cuts[c2]);
						}
					}
				}
			} else {
				_cutSites = _allCutSites;
				_cutSitesMap = _allCutSitesMap;
			}
		}
		
		private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
		{
			dirty = true;
		}
	}
}
