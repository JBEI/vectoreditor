package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyMatrix
    {
        private var _bins:Vector.<Bin> = new Vector.<Bin>();
        
        // Constructor
        public function AssemblyMatrix()
        {
        }
        
        // Properties
        public function get bins():Vector.<Bin>
        {
            return _bins;
        }
        
        public function set bins(value:Vector.<Bin>):void
        {
            _bins = value;
        }
        
        // Public Methods
        public function addBin(bin:Bin):void
        {
            _bins.push(bin);
        }
    }
}