package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    public class FeatureType
    {
        private var _name:String = "";
        private var _key:String = "";
        
        // Constructor
        public function FeatureType(name:String = "", key:String = "")
        {
            _name = name;
            _key = key;
        }
        
        // Properties
        public function get name():String
        {
            return _name;
        }
        
        public function set name(value:String):void
        {
            _name = value
        }
        
        public function get key():String
        {
            return _key;
        }
        
        public function set key(value:String):void
        {
            _key = value
        }
    }
}