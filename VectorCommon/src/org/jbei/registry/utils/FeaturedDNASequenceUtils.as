package org.jbei.registry.utils
{
	import mx.collections.ArrayCollection;
    import mx.controls.Alert;

    import org.jbei.bio.sequence.DNATools;
	import org.jbei.bio.sequence.common.Location;
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.bio.sequence.dna.Feature;
	import org.jbei.bio.sequence.dna.FeatureNote;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.registry.models.DNAFeature;
	import org.jbei.registry.models.DNAFeatureLocation;
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
						
						descriptionNotes.addItem(new DNAFeatureNote(featureNote.name, featureNote.value, featureNote.quoted));
					}
				}
				
				var locations:ArrayCollection = new ArrayCollection(); /* of DNAFeatureLocation */
				if (feature.locations != null && feature.locations.length > 0) {
					for (var k:int = 0; k < feature.locations.length; k++) {
						var location:Location = feature.locations[k];
						
						locations.addItem(new DNAFeatureLocation(location.start + 1, location.end));
					}
				}
				var newDNAFeature:DNAFeature = new DNAFeature(feature.start + 1, feature.end, feature.strand, feature.name, descriptionNotes, feature.type);
				newDNAFeature.locations = locations;
				
				dnaSequenceFeatures.addItem(newDNAFeature);
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
							
							featureNotes.push(new FeatureNote(dnaFeatureNote.name, dnaFeatureNote.value, dnaFeatureNote.quoted));
						}
					}
					
					var newFeature:Feature = new Feature(dnaFeature.name, 0, 0, dnaFeature.type, dnaFeature.strand, featureNotes);
					newFeature.locations = new Vector.<Location>();
					for (var k:int = 0; k < dnaFeature.locations.length; k++) {
						var featureLocation:DNAFeatureLocation = dnaFeature.locations[k];
						newFeature.locations.push(new Location(featureLocation.genbankStart - 1, featureLocation.end));
					}
					features.addItem(newFeature);
				}
			}
			
            sequenceProvider.features = features;
			
			return sequenceProvider;
		}

        /**
         * features []:
         *          notes []
         *          locations []
         *
         * @param object
         * @return
         */
        public static function fromObject(object:Object ) : FeaturedDNASequence {
            var features:Array = object.features as Array;
            var featureCollection:ArrayCollection = new ArrayCollection();

            for(var i:int=0; i<features.length; i += 1) {
                var featureObj:Object = features[i];

                // convert DNAFeatureLocations
                var locations:ArrayCollection = new ArrayCollection();
                var featuresLocationsJSON:Array = featureObj.locations as Array;
                for(var j:int=0; j<featuresLocationsJSON.length; j+=1) {
                    var locationObj:Object = featuresLocationsJSON[j];
                    var featureLocation:DNAFeatureLocation = ObjectTranslator.objectToInstance(locationObj, DNAFeatureLocation);
                    locations.addItem(featureLocation);
                }

                // convert DNAFeatureNotes
                var notes:ArrayCollection = new ArrayCollection();
                var featuresNotesJSON:Array = featureObj.notes as Array;
                for (var k:int=0; k<featuresNotesJSON.length; k+=1) {
                    var noteObj:Object = featuresNotesJSON[k];
                    var featuresNote:DNAFeatureNote = ObjectTranslator.objectToInstance(noteObj, DNAFeatureNote);
                    notes.addItem(featuresNote);
                }

                var feature:DNAFeature = ObjectTranslator.objectToInstance(featureObj, DNAFeature);
                feature.locations = locations;
                feature.notes = notes;
                featureCollection.addItem(feature);
            }

            var sequence:FeaturedDNASequence = ObjectTranslator.objectToInstance(object, FeaturedDNASequence);
            sequence.features = featureCollection;
            return sequence;
        }
	}
}
