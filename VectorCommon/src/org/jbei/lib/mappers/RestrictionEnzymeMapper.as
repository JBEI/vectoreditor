package org.jbei.lib.mappers
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.enzymes.RestrictionCutSite;
	import org.jbei.bio.enzymes.RestrictionEnzyme;
	import org.jbei.bio.enzymes.RestrictionEnzymeMapper;
	import org.jbei.bio.sequence.DNATools;
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.lib.SequenceProviderEvent;
	import org.jbei.lib.data.RestrictionEnzymeGroup;

    /**
     * @author Zinovii Dmytriv
     */
	public class RestrictionEnzymeMapper extends EventDispatcher
	{
		private var dirty:Boolean = true;
		private var _cutSites:ArrayCollection /* of CutSite */;
		private var _cutSitesMap:Dictionary /* [RestrictionEnzyme] = Array(CutSite) */;
		private var _allCutSites:ArrayCollection /* of CutSite */;
		private var _allCutSitesMap:Dictionary /* [RestrictionEnzyme] = Array(CutSite) */;
		private var _maxRestrictionEnzymeCuts:int = -1;
		private var _restrictionEnzymeGroup:RestrictionEnzymeGroup;
		private var _sequenceProvider:SequenceProvider;
		
		// Constructor
		public function RestrictionEnzymeMapper(sequenceProvider:SequenceProvider, restrictionEnzymeGroup:RestrictionEnzymeGroup)
		{
			super();
			
			_sequenceProvider = sequenceProvider;
			_restrictionEnzymeGroup = restrictionEnzymeGroup;
			_sequenceProvider.addEventListener(SequenceProviderEvent.SEQUENCE_CHANGED, onSequenceProviderChanged);
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
			if(_sequenceProvider && _restrictionEnzymeGroup && _restrictionEnzymeGroup.enzymes.length > 0) {
				if(_sequenceProvider.circular) {
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
			var cutSites:Dictionary = org.jbei.bio.enzymes.RestrictionEnzymeMapper.cutSequence(_restrictionEnzymeGroup.enzymes, _sequenceProvider.sequence);
			
			eliminateDuplicates(cutSites);
		}
		
		private function recalculateCircular():void
		{
            var sequenceLength:int = _sequenceProvider.sequence.length;
            var cutSites:Dictionary = org.jbei.bio.enzymes.RestrictionEnzymeMapper.cutSequence(_restrictionEnzymeGroup.enzymes, DNATools.createDNA(_sequenceProvider.sequence.seqString() + _sequenceProvider.sequence.seqString()));
			
            var newCutSites:Dictionary = new Dictionary();
            
			for(var restrictionEnzyme:Object in cutSites) {
				var cutSitesList:Vector.<RestrictionCutSite> = cutSites[restrictionEnzyme];
				
				// emiminating cut sites that are over sequence length
                newCutSites[restrictionEnzyme] = new Vector.<RestrictionCutSite>();
				for(var k1:int = 0; k1 < cutSitesList.length; k1++) {
					var cutSite1:RestrictionCutSite = cutSitesList[k1] as RestrictionCutSite;
					
					if(cutSite1.start >= sequenceLength) {
					} else if(cutSite1.end < sequenceLength) {
						(newCutSites[restrictionEnzyme] as Vector.<RestrictionCutSite>).push(cutSite1);
					} else {
						cutSite1.end -= sequenceLength;
						(newCutSites[restrictionEnzyme] as Vector.<RestrictionCutSite>).push(cutSite1);
					}
				}
			}
			
			eliminateDuplicates(newCutSites);
		}
		
		private function eliminateDuplicates(normalCutSites:Dictionary):void
		{
			_cutSites = new ArrayCollection();
			_cutSitesMap = new Dictionary();
			_allCutSites = new ArrayCollection();
			_allCutSitesMap = new Dictionary();
			
			for(var restrictionEnzyme:Object in normalCutSites) {
				var tmpArray1:Vector.<RestrictionCutSite> = normalCutSites[restrictionEnzyme];
				
				_allCutSitesMap[restrictionEnzyme] = new Array();
				
				var numCuts:int = 0;
				var csMap:Array = _allCutSitesMap[restrictionEnzyme];
				
				for(var k:int = 0; k < tmpArray1.length; k++) {
					_allCutSites.addItem(tmpArray1[k]);
					csMap.push(tmpArray1[k]);
					numCuts++;
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
		
		private function onSequenceProviderChanged(event:SequenceProviderEvent):void
		{
			dirty = true;
		}
	}
}
