package org.jbei.registry.models
{
    import flash.events.EventDispatcher;

    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyProvider extends EventDispatcher
    {
        private var _bins:Vector.<Bin>;
        
        private var _manualUpdateStarted:Boolean = false;
        
        // Constructor
        public function AssemblyProvider()
        {
            _bins = new Vector.<Bin>();
        }
        
        // Properties
        public final function get bins():Vector.<Bin>
        {
            return _bins;
        }
        
        public function get manualUpdateStarted():Boolean
        {
            return _manualUpdateStarted;
        }
        
        // Public Methods
        public function manualUpdateStart():void
        {
            if(!_manualUpdateStarted) {
                _manualUpdateStarted = true;
                
                dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_MANUAL_UPDATE));
            }
        }
        
        public function manualUpdateEnd():void
        {
            if(_manualUpdateStarted) {
                dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_MANUAL_UPDATE));
                
                _manualUpdateStarted = false;
            }
        }
        
        public function addBin(bin:Bin, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_BIN_ADD));
            }
            
            _bins.push(bin);
            
            if(!quiet && !_manualUpdateStarted) {
                dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_BIN_ADD));
            }
        }
        
        public function removeBin(bin:Bin, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_BIN_REMOVE));
            }
            
            var index:int = _bins.indexOf(bin);
            
            if(index >= 0) {
                _bins.splice(index, 1);
            }
            
            if(!quiet && !_manualUpdateStarted) {
                dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_BIN_REMOVE));
            }
        }
    }
}