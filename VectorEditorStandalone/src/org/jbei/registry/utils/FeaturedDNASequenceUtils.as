package org.jbei.registry.utils
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.Feature;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.registry.models.DNAFeature;
	import org.jbei.registry.models.FeaturedDNASequence;

	public class FeaturedDNASequenceUtils
	{
		public static function featuredSequenceToFeaturedDNASequence(featuredSequence:FeaturedSequence):FeaturedDNASequence
		{
			if(featuredSequence == null) {
				return null;
			}
			
			var dnaSequenceFeatures:ArrayCollection = new ArrayCollection();
			var featuredDNASequence:FeaturedDNASequence = new FeaturedDNASequence(featuredSequence.sequence.sequence, dnaSequenceFeatures);
			
			for(var i:int = 0; i < featuredSequence.features.length; i++) {
				var feature:Feature = featuredSequence.features[i];
				
				dnaSequenceFeatures.addItem(new DNAFeature(feature.start + 1, feature.end + 1, feature.strand, feature.label, "", feature.type));
			}
			
			return featuredDNASequence;
		}
	}
}
