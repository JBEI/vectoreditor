package org.jbei.registry.models
{
    import mx.collections.ArrayCollection;
    
    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.AssemblyItem")]
    public class AssemblyItem
    {
        private var _name:String;
        private var _original:String;
        private var _sequence:FeaturedDNASequence;
        private var _meta:String;
        
        // Constructor
        public function AssemblyItem(name:String = "", sequence:FeaturedDNASequence = null, original:String = "", meta:String = "")
        {
            _name = name;
            _original = original;
            _sequence = sequence;
            _meta = meta;
        }
        
        // Properties
        public function get name():String
        {
            return _name;
        }
        
        public function set name(value:String):void
        {
            _name = value;
        }
        
        public function get original():String
        {
            return _original;
        }
        
        public function set original(value:String):void
        {
            _original = value;
        }
        
        public function get sequence():FeaturedDNASequence
        {
            return _sequence;
        }
        
        public function set sequence(value:FeaturedDNASequence):void
        {
            _sequence = value;
        }
        
        public function get meta():String
        {
            return _meta;
        }
        
        public function set meta(value:String):void
        {
            _meta = value;
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
            return new AssemblyItem(_name, _sequence, _original, _meta);
        }
    }
}