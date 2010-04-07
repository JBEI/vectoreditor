package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;

	[RemoteClass(alias="org.jbei.ice.lib.vo.FeaturedDNASequence")]
	public class FeaturedDNASequence extends DNASequence
	{
		private var _sequence:String;
		private var _features:ArrayCollection; /* of DNAFeature */
		
		// Constructor
		public function FeaturedDNASequence(sequence:String, features:ArrayCollection /* of DNAFeature */)
		{
			super(sequence);
			
			_features = features;
		}
		
		// Properties
		public function get features():ArrayCollection /* of DNAFeature */
		{
			return _features;
		}
		
		public function set features(value:ArrayCollection /* of DNAFeature */):void
		{
			_features = value;
		}
	}
}
