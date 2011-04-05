package org.jbei.registry.utils
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.sequence.DNATools;
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.bio.sequence.dna.Feature;
	import org.jbei.bio.sequence.dna.FeatureNote;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.registry.models.DNAFeature;
	import org.jbei.registry.models.DNAFeatureNote;
	import org.jbei.registry.models.FeaturedDNASequence;

    /**
     * @author Zinovii Dmytriv
     */
	public class FeaturedDNASequenceUtils
	{
		public static function sequenceProviderToFeaturedDNASequence(sequenceProvider:SequenceProvider):FeaturedDNASequence
		{
			if(sequenceProvider == null) {
				return null;
			}
			
			var dnaSequenceFeatures:ArrayCollection = new ArrayCollection();
			var featuredDNASequence:FeaturedDNASequence = new FeaturedDNASequence(sequenceProvider.name, sequenceProvider.sequence.seqString(), sequenceProvider.circular, dnaSequenceFeatures);
			
			for(var i:int = 0; i < sequenceProvider.features.length; i++) {
				var feature:Feature = sequenceProvider.features[i];
				
				var descriptionNotes:ArrayCollection = new ArrayCollection() /* of DNAFeatureNote */;
				
				if(feature.notes != null && feature.notes.length > 0) {
					for(var j:int = 0; j < feature.notes.length; j++) {
						var featureNote:FeatureNote = feature.notes[j];
						
						descriptionNotes.addItem(new DNAFeatureNote(featureNote.name, featureNote.value));
					}
				}
				
				dnaSequenceFeatures.addItem(new DNAFeature(feature.start + 1, feature.end + 1, feature.strand, feature.name, descriptionNotes, feature.type));
			}
			
			return featuredDNASequence;
		}
		
		public static function featuredDNASequenceToSequenceProvider(featuredDNASequence:FeaturedDNASequence):SequenceProvider
		{
			if(featuredDNASequence == null) {
				return null;
			}
			
			var dnaSequence:DNASequence = DNATools.createDNASequence("", featuredDNASequence.sequence);
			
			var sequenceProvider:SequenceProvider = new SequenceProvider(featuredDNASequence.name, featuredDNASequence.isCircular, dnaSequence);
			
			var features:ArrayCollection = new ArrayCollection();
			if(featuredDNASequence.features != null && featuredDNASequence.features.length > 0) {
				for(var i:int = 0; i < featuredDNASequence.features.length; i++) {
					var dnaFeature:DNAFeature = featuredDNASequence.features[i];
					
					var featureNotes:Vector.<FeatureNote> = new Vector.<FeatureNote>(); // of FeatureNote;
					
					if(dnaFeature.notes != null && dnaFeature.notes.length > 0) {
						for(var j:int = 0; j < dnaFeature.notes.length; j++) {
							var dnaFeatureNote:DNAFeatureNote = dnaFeature.notes[j];
							
							featureNotes.push(new FeatureNote(dnaFeatureNote.name, dnaFeatureNote.value));
						}
					}
					
					features.addItem(new Feature(dnaFeature.name, dnaFeature.genbankStart - 1, dnaFeature.end, dnaFeature.type, dnaFeature.strand, featureNotes));
				}
			}
			
            sequenceProvider.features = features;
			
			return sequenceProvider;
		}
	}
}
