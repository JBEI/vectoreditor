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
        
        // Public Methods
        public function toString():String
        {
            return _sequence;
        }
        
        /*
        * @private
        * */
        public function clone():AssemblyItem
        {
            var clonedItem:AssemblyItem = new AssemblyItem(_sequence);
            
            return clonedItem;
        }
    }
}