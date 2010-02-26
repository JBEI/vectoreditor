package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;

	[RemoteClass(alias="org.jbei.ice.services.blazeds.VectorEditor.vo.LightSequence")]
	public class LightSequence
	{
		private var _sequence:String;
		private var _features:ArrayCollection; /* of LightFeature */
		
		// Constructor
		public function LightSequence(sequence:String, features:ArrayCollection /* of LightFeature */)
		{
			_sequence = sequence;
			_features = features;
		}
		
		// Properties
		public function get sequence():String
		{
			return _sequence;
		}
		
		public function set sequence(value:String):void
		{
			_sequence = value;
		}
		
		public function get features():ArrayCollection /* of LightFeature */
		{
			return _features;
		}
		
		public function set features(value:ArrayCollection /* of LightFeature */):void
		{
			_features = value;
		}
	}
}
