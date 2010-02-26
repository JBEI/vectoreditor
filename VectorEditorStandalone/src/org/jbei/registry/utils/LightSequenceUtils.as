package org.jbei.registry.utils
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.Feature;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.registry.models.LightFeature;
	import org.jbei.registry.models.LightSequence;

	public class LightSequenceUtils
	{
		public static function featuredSequenceToLightSequence(featuredSequence:FeaturedSequence):LightSequence
		{
			if(featuredSequence == null) {
				return null;
			}
			
			var lightFeatures:ArrayCollection = new ArrayCollection();
			var lightSequence:LightSequence = new LightSequence(featuredSequence.sequence.sequence, lightFeatures);
			
			for(var i:int = 0; i < featuredSequence.features.length; i++) {
				var feature:Feature = featuredSequence.features[i];
				
				lightFeatures.addItem(new LightFeature(feature.start, feature.end, feature.strand, feature.label, "", feature.type));
			}
			
			return lightSequence;
		}
	}
}
