package org.jbei.lib.mappers
{
    import org.jbei.bio.enzymes.RestrictionEnzyme;
    import org.jbei.lib.SequenceProvider;

    [RemoteClass(alias="org.jbei.components.common.DigestionSequence")]
    /**
     * @author Zinovii Dmytriv
     */
    public class DigestionSequence
    {
        private var _sequenceProvider:SequenceProvider;
        private var _startRestrictionEnzyme:RestrictionEnzyme;
        private var _endRestrictionEnzyme:RestrictionEnzyme;
        private var _startRelativePosition:int = 0;
        private var _endRelativePosition:int = 0;
        
        // Constructor
        public function DigestionSequence(sequenceProvider:SequenceProvider = null, startRestrictionEnzyme:RestrictionEnzyme = null, endRestrictionEnzyme:RestrictionEnzyme = null, startRelativePosition:int = 0, endRelativePosition:int = 0)
        {
            _sequenceProvider = sequenceProvider;
            _startRestrictionEnzyme = startRestrictionEnzyme;
            _endRestrictionEnzyme = endRestrictionEnzyme;
            _startRelativePosition = startRelativePosition;
            _endRelativePosition = endRelativePosition;
        }
        
        // Properties
        public function get sequenceProvider():SequenceProvider
        {
            return _sequenceProvider;
        }
        
        public function set sequenceProvider(value:SequenceProvider):void
        {
            _sequenceProvider = value;
        }
        
        public function get startRestrictionEnzyme():RestrictionEnzyme
        {
            return _startRestrictionEnzyme;
        }
        
        public function set startRestrictionEnzyme(value:RestrictionEnzyme):void
        {
            _startRestrictionEnzyme = value;
        }
        
        public function get endRestrictionEnzyme():RestrictionEnzyme
        {
            return _endRestrictionEnzyme;
        }
        
        public function set endRestrictionEnzyme(value:RestrictionEnzyme):void
        {
            _endRestrictionEnzyme = value;
        }
        
        public function get startRelativePosition():int
        {
            return _startRelativePosition;
        }
        
        public function set startRelativePosition(value:int):void
        {
            _startRelativePosition = value;
        }
        
        public function get endRelativePosition():int
        {
            return _endRelativePosition;
        }
        
        public function set endRelativePosition(value:int):void
        {
            _endRelativePosition = value;
        }
    }
}