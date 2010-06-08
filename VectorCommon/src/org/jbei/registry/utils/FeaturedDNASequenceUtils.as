package org.jbei.registry.utils
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.sequence.DNATools;
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.bio.sequence.dna.Feature;
	import org.jbei.bio.sequence.dna.FeatureNote;
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
			var featuredDNASequence:FeaturedDNASequence = new FeaturedDNASequence(featuredSequence.sequence.seqString(), dnaSequenceFeatures);
			
			for(var i:int = 0; i < featuredSequence.features.length; i++) {
				var feature:Feature = featuredSequence.features[i];
				
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
		
		public static function featuredDNASequenceToFeaturedSequence(featuredDNASequence:FeaturedDNASequence, name:String, isCircular:Boolean):FeaturedSequence
		{
			if(featuredDNASequence == null) {
				return null;
			}
			
			var dnaSequence:DNASequence = DNATools.createDNASequence("", featuredDNASequence.sequence);
			
			var featuredSequence:FeaturedSequence = new FeaturedSequence(name, isCircular, dnaSequence);
			
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
					
					features.addItem(new Feature(dnaFeature.name, dnaFeature.start - 1, dnaFeature.end - 1, dnaFeature.type, dnaFeature.strand, featureNotes));
				}
			}
			
			featuredSequence.features = features;
			
			return featuredSequence;
		}
	}
}
