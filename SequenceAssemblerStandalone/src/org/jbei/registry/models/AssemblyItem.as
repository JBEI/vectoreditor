package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.AssemblyItem")]
    public class AssemblyItem
    {
        private var _sequence:FeaturedDNASequence;
        private var _originalSequence:String;
        
        // Constructor
        public function AssemblyItem(sequence:FeaturedDNASequence = null, originalSequence:String = "")
        {
            _originalSequence = originalSequence;
            _sequence = sequence;
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
        
        public function get originalSequence():String
        {
            return _originalSequence;
        }
        
        public function set originalSequence(value:String):void
        {
            _originalSequence = value;
        }
        
        // Public Methods
        public function toString():String
        {
            return _sequence.sequence;
        }
        
        /*
        * @private
        * */
        public function clone():AssemblyItem
        {
            return new AssemblyItem(_sequence, _originalSequence);
        }
    }
}