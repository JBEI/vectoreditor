package org.jbei.registry.utils
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.FeatureNote;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.registry.models.DNAFeature;
	import org.jbei.registry.models.DNAFeatureNote;
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
				
				var descriptionNotes:ArrayCollection = new ArrayCollection() /* of DNAFeatureNote */;
				
				if(feature.notes != null && feature.notes.length > 0) {
					for(var j:int = 0; j < feature.notes.length; j++) {
						var featureNote:FeatureNote = feature.notes[j];
						
						descriptionNotes.addItem(new DNAFeatureNote(featureNote.name, featureNote.value));
					}
				}
				
				dnaSequenceFeatures.addItem(new DNAFeature(feature.start + 1, feature.end + 1, feature.strand, feature.label, descriptionNotes, feature.type));
			}
			
			return featuredDNASequence;
		}
	}
}
