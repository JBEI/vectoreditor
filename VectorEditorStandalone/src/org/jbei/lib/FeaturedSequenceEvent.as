package org.jbei.lib
{
	import flash.events.Event;
	
	public class FeaturedSequenceEvent extends Event
	{
		public static const SEQUENCE_CHANGING:String = "SequenceChanging";
		public static const SEQUENCE_CHANGED:String = "SequenceChanged";
		
		public static const KIND_FEATURE_ADD:String = "FeatureAddFeaturedSequenceEvent";
		public static const KIND_FEATURE_REMOVE:String = "FeatureRemoveFeaturedSequenceEvent";
		public static const KIND_FEATURES_ADD:String = "FeaturesAddFeaturedSequenceEvent";
		public static const KIND_FEATURES_REMOVE:String = "FeaturesRemoveFeaturedSequenceEvent";
		public static const KIND_SEQUENCE_INSERT:String = "SequenceInsertFeaturedSequenceEvent";
		public static const KIND_SEQUENCE_REMOVE:String = "SequenceRemoveFeaturedSequenceEvent";
		
		public static const KIND_MANUAL_UPDATE:String = "ManualUpdate";
		public static const KIND_SET_MEMENTO:String = "SetMemento";
		
		public static const KIND_INITIALIZED:String = "SequenceInitialized";
		
		public var kind:String;
		public var data:Object;
		
		// Contructor
		public function FeaturedSequenceEvent(type:String, kind:String, data:Object = null)
		{
			super(type);
			
			this.kind = kind;
			this.data = data;
		}
	}
}
