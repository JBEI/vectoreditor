package org.jbei.lib
{
    import flash.events.Event;
    
    /**
     * Sequence provider event class
     * @author Zinovii Dmytrivs
     */
    public class SequenceProviderEvent extends Event
    {
        public static const SEQUENCE_CHANGING:String = "SequenceChanging";
        public static const SEQUENCE_CHANGED:String = "SequenceChanged";
        
        public static const KIND_FEATURE_ADD:String = "FeatureAddSequenceProviderEvent";
        public static const KIND_FEATURE_REMOVE:String = "FeatureRemoveSequenceProviderEvent";
        public static const KIND_FEATURES_ADD:String = "FeaturesAddSequenceProviderEvent";
        public static const KIND_FEATURES_REMOVE:String = "FeaturesRemoveSequenceProviderEvent";
        public static const KIND_SEQUENCE_INSERT:String = "SequenceInsertSequenceProviderEvent";
        public static const KIND_SEQUENCE_REMOVE:String = "SequenceRemoveSequenceProviderEvent";
        
        public static const KIND_MANUAL_UPDATE:String = "ManualUpdate";
        public static const KIND_SET_MEMENTO:String = "SetMemento";
        
        public static const KIND_INITIALIZED:String = "SequenceInitialized";
        
        public var kind:String;
        public var data:Object;
        
        // Contructor
        /**
        * Contructor
        */
        public function SequenceProviderEvent(type:String, kind:String, data:Object = null)
        {
            super(type);
            
            this.kind = kind;
            this.data = data;
        }
    }
}
