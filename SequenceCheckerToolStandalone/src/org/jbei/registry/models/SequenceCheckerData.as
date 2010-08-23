package org.jbei.registry.models
{
    import mx.collections.ArrayCollection;

    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.SequenceCheckerData")]
    public class SequenceCheckerData
    {
        private var _sequence:FeaturedDNASequence;
        private var _traces:ArrayCollection; /* of TraceData */
        
        // Contructor
        public function SequenceCheckerData(sequence:FeaturedDNASequence = null, traces:ArrayCollection /* of TraceData */ = null)
        {
            _sequence = sequence;
            _traces = traces;
        }
        
        // Properties
        public function get sequence():FeaturedDNASequence
        {
            return _sequence;
        }
        
        public function set sequence(value:FeaturedDNASequence):void
        {
            _sequence = value;
        }
        
        public function get traces():ArrayCollection /* TraceData */
        {
            return _traces;
        }
        
        public function set traces(value:ArrayCollection /* TraceData */):void
        {
            _traces = value;
        }
    }
}