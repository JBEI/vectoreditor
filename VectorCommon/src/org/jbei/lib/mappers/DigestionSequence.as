package org.jbei.lib.mappers
{
    import org.jbei.bio.enzymes.RestrictionEnzyme;
    import org.jbei.lib.FeaturedSequence;

    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.components.common.DigestionSequence")]
    public class DigestionSequence
    {
        private var _featuredSequence:FeaturedSequence;
        private var _startRestrictionEnzyme:RestrictionEnzyme;
        private var _endRestrictionEnzyme:RestrictionEnzyme;
        private var _startRelativePosition:int = 0;
        private var _endRelativePosition:int = 0;
        
        // Constructor
        public function DigestionSequence(featuredSequence:FeaturedSequence = null, startRestrictionEnzyme:RestrictionEnzyme = null, endRestrictionEnzyme:RestrictionEnzyme = null, startRelativePosition:int = 0, endRelativePosition:int = 0)
        {
            _featuredSequence = featuredSequence;
            _startRestrictionEnzyme = startRestrictionEnzyme;
            _endRestrictionEnzyme = endRestrictionEnzyme;
            _startRelativePosition = startRelativePosition;
            _endRelativePosition = endRelativePosition;
        }
        
        // Properties
        public function get featuredSequence():FeaturedSequence
        {
            return _featuredSequence;
        }
        
        public function set featuredSequence(value:FeaturedSequence):void
        {
            _featuredSequence = value;
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