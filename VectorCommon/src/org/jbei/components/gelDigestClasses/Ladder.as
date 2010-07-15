package org.jbei.components.gelDigestClasses
{
    public class Ladder
    {
        private var _bandSizes:Vector.<int>;
        private var _name:String;
        
        // Constructor
        public function Ladder(name:String, bandSizes:Vector.<int>)
        {
            _bandSizes = bandSizes;
            _name = name;
        }
        
        // Properties
        public function get bandSizes():Vector.<int>
        {
            return _bandSizes;
        }
        
        public function get name():String
        {
            return _name;
        }
    }
}