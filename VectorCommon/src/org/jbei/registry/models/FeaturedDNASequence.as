package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;

	[RemoteClass(alias="org.jbei.ice.lib.vo.FeaturedDNASequence")]
    /**
     * @author Zinovii Dmytriv
     */
	public class FeaturedDNASequence
	{
		private var _sequence:String;
		private var _features:ArrayCollection; /* of DNAFeature */
		private var _accessionNumber:String = "";
		private var _identifier:String = "";
		
		// Constructor
		public function FeaturedDNASequence(sequence:String = "", features:ArrayCollection /* of DNAFeature */ = null)
		{
			super();
			
			_features = features;
			_sequence = sequence;
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
		
		public function get features():ArrayCollection /* of DNAFeature */
		{
			return _features;
		}
		
		public function set features(value:ArrayCollection /* of DNAFeature */):void
		{
			_features = value;
		}
		
		public function get accessionNumber():String
		{
			return _accessionNumber;
		}
		
		public function set accessionNumber(value:String):void
		{
			_accessionNumber = value;
		}
		
		public function get identifier():String
		{
			return _identifier;
		}
		
		public function set identifier(value:String):void
		{
			_identifier = value;
		}
	}
}
