package org.jbei.bio.utils
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.CutSite;
	import org.jbei.bio.data.DNASequence;
	import org.jbei.registry.model.vo.RestrictionEnzyme;
	
	public class RestrictionEnzymesUtils
	{
		public static function cutSequence(restrictionEnzymeGroup:ArrayCollection, sequence:DNASequence):Dictionary /* [RestrictionEnzyme] = Array(CutSite) */
		{
			var reCuts:Dictionary = new Dictionary();
			
			for(var i:int = 0; i < restrictionEnzymeGroup.length; i++) {
				var re:RestrictionEnzyme = restrictionEnzymeGroup[i] as RestrictionEnzyme;
				
				reCuts[re] = cutByRestrictionEnzyme(re, sequence);
			}
			
			return reCuts;
		}
		
		public static function cutReverseComplementary(restrictionEnzymeGroup:ArrayCollection, reverseComplement:DNASequence):Dictionary /* [RestrictionEnzyme] = Array(CutSite) */
		{
			var reCuts:Dictionary = new Dictionary();
			
			for(var i:int = 0; i < restrictionEnzymeGroup.length; i++) {
				var re:RestrictionEnzyme = restrictionEnzymeGroup[i] as RestrictionEnzyme;
				
				reCuts[re] = cutReverseComplementByRestrictionEnzyme(re, reverseComplement);
			}
			
			return reCuts;
		}
		
		public static function cutByRestrictionEnzyme(restrictionEnzyme:RestrictionEnzyme, sequence:DNASequence):Array /* of CutSite */
		{
			var cutSites:Array = new Array();
			
			var forwardRegExpPattern:RegExp = new RegExp(restrictionEnzyme.forwardRegex, "g");
			
			var numCuts:int = 0;
			
			var reLength:int = restrictionEnzyme.site.length;
			if(restrictionEnzyme.site.length != restrictionEnzyme.dsForward + restrictionEnzyme.dsReverse) {
				reLength = restrictionEnzyme.dsForward;
			}
			
			var match:Object = forwardRegExpPattern.exec(sequence.sequence);
			while (match != null) {
				if(match.index >= sequence.length) { break; } // break when cutsite start is more then seq length, because it means it's duplicate
				
				if(sequence.length <= match.index + reLength - 1) { break; } // sequence is too short
				
				var cutSite:CutSite = new CutSite(restrictionEnzyme, match.index, match.index + reLength - 1, true);
				
				cutSites.push(cutSite);
				
				match = forwardRegExpPattern.exec(sequence.sequence);
				
				numCuts++;
			}
			
			return cutSites;
		}
		
		public static function cutReverseComplementByRestrictionEnzyme(restrictionEnzyme:RestrictionEnzyme, sequence:DNASequence):Array /* of CutSite */
		{
			var cutSites:Array = new Array();
			
			var forwardRegExpPattern:RegExp = new RegExp(restrictionEnzyme.forwardRegex, "g");
			
			var numCuts:int = 0;
			
			var reLength:int = restrictionEnzyme.site.length;
			if(restrictionEnzyme.site.length != restrictionEnzyme.dsForward + restrictionEnzyme.dsReverse) {
				reLength = restrictionEnzyme.dsForward;
			}
			
			var match:Object = forwardRegExpPattern.exec(sequence.sequence);
			while (match != null) {
				if(match.index >= sequence.length) { break; } // break when cutsite start is more then seq length, because it means it's duplicate
				
				if(sequence.length <= match.index + reLength - 1) { break; } // sequence is too short
				
				var cutSite:CutSite = new CutSite(restrictionEnzyme, sequence.length - match.index - reLength, sequence.length - match.index - 1, false);
				
				cutSites.push(cutSite);
				
				match = forwardRegExpPattern.exec(sequence.sequence);
				
				numCuts++;
			}
			
			return cutSites;
		}
	}
}
