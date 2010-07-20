package org.jbei.registry.models
{
    import flash.events.Event;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyProviderEvent extends Event
    {
        public static const ASSEMBLY_PROVIDER_CHANGING:String = "AssemblyProviderChanging";
        public static const ASSEMBLY_PROVIDER_CHANGED:String = "AssemblyProviderChanged";
        
        public static const KIND_BIN_ADD:String = "AssemblyProviderKindBinAdd";
        public static const KIND_BIN_REMOVE:String = "AssemblyProviderKindBinRemove";
        public static const KIND_BIN_UPDATE:String = "AssemblyProviderKindBinUpdate";
        
        public static const KIND_MANUAL_UPDATE:String = "AssemblyProviderKindManualUpdate";
        
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