package org.jbei.bio.utils
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.CutSite;
	import org.jbei.bio.data.DNASequence;
	import org.jbei.registry.model.vo.RestrictionEnzyme;
	
	public class RestrictionEnzymesUtils
	{
		public static function cutByRestrictionEnzymesGroup(restrictionEnzymeGroup:ArrayCollection, sequence:DNASequence, reverseComplement:DNASequence, circular:Boolean, forwardOnly:Boolean = false):Dictionary /* [RestrictionEnzyme] = Array(CutSite) */
		{
			var reCuts:Dictionary = new Dictionary();
			
			for(var i:int = 0; i < restrictionEnzymeGroup.length; i++) {
				var re:RestrictionEnzyme = restrictionEnzymeGroup[i] as RestrictionEnzyme;
				
				reCuts[re] = cutByRestrictionEnzyme(re, sequence, reverseComplement, circular, forwardOnly);
			}
			
			return reCuts;
		}
		
		public static function cutByRestrictionEnzyme(restrictionEnzyme:RestrictionEnzyme, sequence:DNASequence, reverseComplement:DNASequence, circular:Boolean, forwardOnly:Boolean = false):Array /* of CutSite */
		{
			var cutSites:Array = new Array();
			
			var forwardRegExpPattern:RegExp = new RegExp(restrictionEnzyme.forwardRegex, "g");
			var reverseRegExpPattern:RegExp = new RegExp(restrictionEnzyme.reverseRegex, "g");
			
			var dnaSequence:String = sequence.sequence;
			
			if(circular) { // make twice bigger to handle over zero cases 
				dnaSequence += dnaSequence;
			}
			
			var numCuts:int = 0;
			
			var reLength:int = restrictionEnzyme.site.length;
			if(restrictionEnzyme.site.length != restrictionEnzyme.dsForward + restrictionEnzyme.dsReverse) {
				reLength = restrictionEnzyme.dsForward;
			}
			
			var match:Object = forwardRegExpPattern.exec(dnaSequence);
			while (match != null) {
				if(match.index >= sequence.length) { break; } // break when cutsite start is more then seq length, because it means it's duplicate
				
				if(sequence.length <= match.index + reLength - 1) { break; } // sequence is too short
				
				var cutSite:CutSite = new CutSite(restrictionEnzyme, match.index, match.index + reLength - 1, true);
				
				cutSites.push(cutSite);
				
				match = forwardRegExpPattern.exec(dnaSequence);
				
				numCuts++;
			}
			
			if(!forwardOnly && !restrictionEnzyme.isPalindromic()) {
				var complementSequence:String = reverseComplement.sequence;
				
				if(circular) { // make twice bigger to handle over zero cases 
					complementSequence += complementSequence;
				}
				
				var reReverseLength:int = restrictionEnzyme.site.length;
				if(restrictionEnzyme.site.length != restrictionEnzyme.dsForward + restrictionEnzyme.dsReverse) {
					reReverseLength = restrictionEnzyme.dsReverse;
				}
				
				var reverseMatch:Object = reverseRegExpPattern.exec(complementSequence);
				while (reverseMatch != null) {
					if(reverseMatch.index >= sequence.length) { break; } // break when cutsite start is more then seq length, because it means it's duplicate
					
					if((!circular && sequence.length < reReverseLength) || (!circular && sequence.length - reverseMatch.index - reReverseLength < 0)) { break; } // re is too short
					
					var isDuplicate:Boolean = false;
					for(var i:int = 0; i < cutSites.length; i++) {
						if((cutSites[i] as CutSite).start + restrictionEnzyme.site.length == sequence.length - reverseMatch.index) {
							isDuplicate = true;
							break;
						}
					}
					
					if(isDuplicate) { break; }
					
					var reverseCutSite:CutSite = new CutSite(restrictionEnzyme, sequence.length - reverseMatch.index - reReverseLength, sequence.length - reverseMatch.index - 1, false);
					
					cutSites.push(reverseCutSite);
					
					reverseMatch = reverseRegExpPattern.exec(complementSequence);
					
					numCuts++;
				}
			}
			
			for(var j:int = 0; j < cutSites.length; j++) {
				(cutSites[j] as CutSite).numCuts = numCuts;
			}
			
			return cutSites;
		}
	}
}
