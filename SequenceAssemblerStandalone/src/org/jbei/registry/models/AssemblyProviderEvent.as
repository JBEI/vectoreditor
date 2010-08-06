package org.jbei.registry.models
{
    import flash.events.Event;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyProviderEvent extends Event
    {
        public static const ASSEMBLY_PROVIDER_CHANGING:String = "assemblyProviderChanging";
        public static const ASSEMBLY_PROVIDER_CHANGED:String = "assemblyProviderChanged";
        
        public static const KIND_BIN_ADD:String = "assemblyProviderKindBinAdd";
        public static const KIND_BIN_REMOVE:String = "assemblyProviderKindBinRemove";
        public static const KIND_BIN_UPDATE:String = "assemblyProviderKindBinUpdate";
        public static const KIND_BIN_MOVED:String = "assemblyProviderKindBinMoved";
        public static const KIND_BIN_CHANGE_TYPE:String = "assemblyProviderKindBinChangeType";
        
        public static const KIND_MANUAL_UPDATE:String = "AssemblyProviderKindManualUpdate";
        public static const KIND_SET_MEMENTO:String = "AssemblyProviderKindSetMemento";
        
        public static const KIND_ITEM_UPDATE:String = "AssemblyProviderKindItemUpdate";
        public static const KIND_ITEM_ADD:String = "AssemblyProviderKindItemAdd";
        
        private var _kind:String;
        private var _data:Object;
        
        // Constructor
        public function AssemblyProviderEvent(type:String, kind:String, data:Object = null)
        {
            super(type, true, true);
            
            _kind = kind;
            _data = data;
        }
        
        // Properties
        public function get kind():String
        {
            return _kind;
        }
        
        public function get data():Object
        {
            return _data;
        }
    }
}