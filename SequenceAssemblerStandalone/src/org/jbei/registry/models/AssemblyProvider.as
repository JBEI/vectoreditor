package org.jbei.registry.models
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import org.jbei.registry.lib.IMemento;
    import org.jbei.registry.lib.IOriginator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyProvider implements IOriginator
    {
        private var _bins:Vector.<AssemblyBin>;
        
        private var _manualUpdateStarted:Boolean = false;
        
        private var dispatcher:EventDispatcher = new EventDispatcher();
        
        // Constructor
        public function AssemblyProvider()
        {
            _bins = new Vector.<AssemblyBin>();
        }
        
        // Properties
        public final function get bins():Vector.<AssemblyBin>
        {
            return _bins;
        }
        
        public function get manualUpdateStarted():Boolean
        {
            return _manualUpdateStarted;
        }
        
        // Public Methods: IOriginator implementation
        public function createMemento():IMemento
        {
            var clonedBins:Vector.<AssemblyBin> = new Vector.<AssemblyBin>();
            
            if(_bins && _bins.length > 0) {
                for(var i:int = 0; i < _bins.length; i++) {
                    clonedBins.push((_bins[i] as AssemblyBin).clone());
                }
            }
            
            return new AssemblyProviderMemento(clonedBins);
        }
        
        public function setMemento(memento:IMemento):void
        {
            var assemblyProviderMemento:AssemblyProviderMemento = memento as AssemblyProviderMemento;
            
            _bins = assemblyProviderMemento.bins;
            
            dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_SET_MEMENTO));
        }
        
        // Public Methods: EventDispatcher wrapped
        public function addEventListener(type:String, listener:Function):void
        {
            dispatcher.addEventListener(type, listener);
        }
        
        public function removeEventListener(type:String, listener:Function):void
        {
            dispatcher.removeEventListener(type, listener);
        }
        
        public function dispatchEvent(event:Event):void
        {
            dispatcher.dispatchEvent(event);
        }
        
        // Public Methods
        public function manualUpdateStart():void
        {
            if(!_manualUpdateStarted) {
                _manualUpdateStarted = true;
                
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_MANUAL_UPDATE, createMemento()));
            }
        }
        
        public function manualUpdateEnd():void
        {
            if(_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_MANUAL_UPDATE));
                
                _manualUpdateStarted = false;
            }
        }
        
        public function addBin(bin:AssemblyBin, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_BIN_ADD, createMemento()));
            }
            
            _bins.push(bin);
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_BIN_ADD));
            }
        }
        
        public function insertBin(bin:AssemblyBin, position:int, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_BIN_ADD, createMemento()));
            }
            
            _bins.splice(position, 0, bin);
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_BIN_ADD));
            }
        }
        
        public function removeBin(bin:AssemblyBin, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_BIN_REMOVE, createMemento()));
            }
            
            var index:int = _bins.indexOf(bin);
            
            if(index >= 0) {
                _bins.splice(index, 1);
            }
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_BIN_REMOVE));
            }
        }
        
        public function moveBin(bin:AssemblyBin, newPosition:int, quiet:Boolean = false):void
        {
            if(bin == null) {
                return;
            }
            
            var currentBinPosition:int = _bins.indexOf(bin);
            
            if(currentBinPosition == -1) {
                return;
            }
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_BIN_MOVED, createMemento()));
            }
            
            _bins.splice(currentBinPosition, 1);
            _bins.splice(newPosition, 0, bin);
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_BIN_MOVED));
            }
        }
        
        public function changeBinType(bin:AssemblyBin, newType:String, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_BIN_CHANGE_TYPE, createMemento()));
            }
            
            bin.type = newType;
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_BIN_CHANGE_TYPE));
            }
        }
        
        public function deleteAssemblyItem(bin:AssemblyBin, assemblyItem:AssemblyItem, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_BIN_CHANGE_TYPE, createMemento()));
            }
            
            bin.deleteItem(assemblyItem);
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_BIN_CHANGE_TYPE));
            }
        }
        
        public function updateAssemblyItem(assemblyItem:AssemblyItem, sequence:String, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_ITEM_UPDATE, createMemento()));
            }
            
            assemblyItem.sequence = new FeaturedDNASequence("", sequence);
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_ITEM_UPDATE));
            }
        }
        
        public function addAssemblyItem(bin:AssemblyBin, assemblyItem:AssemblyItem, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, AssemblyProviderEvent.KIND_ITEM_UPDATE, createMemento()));
            }
            
            bin.items.addItem(assemblyItem);
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new AssemblyProviderEvent(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, AssemblyProviderEvent.KIND_ITEM_UPDATE));
            }
        }
        
        public function clone():AssemblyProvider
        {
            var clonedAssemblyProvider:AssemblyProvider = new AssemblyProvider();
            
            if(_bins && _bins.length > 0) {
                for(var i:int = 0; i < _bins.length; i++) {
                    clonedAssemblyProvider.addBin(_bins[i].clone());
                }
            }
            
            return clonedAssemblyProvider;
        }
    }
}