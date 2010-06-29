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
        
        public function removeBin(bin:Bin):void
        {
            var index:int = _bins.indexOf(bin);
            
            if(index >= 0) {
                _bins.splice(index, 1);
            }
        }
        
        public function getBinByUUID(uuid:String):Bin
        {
            var resultBin:Bin = null;
            
            for(var i:int = 0; i < _bins.length; i++) {
                var currentBin:Bin = _bins[i] as Bin;
                
                if(currentBin.uuid == uuid) {
                    resultBin = currentBin;
                    
                    break;
                }
            }
            
            return resultBin;
        }
        
        public function swapBins(index1:int, index2:int):void
        {
            var tmpBin:Bin = _bins[index1];
            _bins[index1] = _bins[index2];
            _bins[index2] = tmpBin;
        }
    }
}