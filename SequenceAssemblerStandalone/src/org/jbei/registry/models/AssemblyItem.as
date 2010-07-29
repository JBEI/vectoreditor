package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyItem
    {
        private var _sequence:String;
        
        // Constructor
        public function AssemblyItem(sequence:String = "")
        {
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
        
        public function toString():String
        {
            return _sequence;
        }
    }
}