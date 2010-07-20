package org.jbei.registry.components.assemblyTableClasses
{
    import flash.events.Event;
    
    import org.jbei.registry.models.AssemblyItem;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class CaretEvent extends Event
    {
        public static const CARET_CHANGED:String = "caretChanged";
        
        private var _assemblyItem:AssemblyItem;
        
        // Contructor
        public function CaretEvent(type:String, assemblyItem:AssemblyItem)
        {
            super(type, true, true);
            
            _assemblyItem = assemblyItem;
        }
        
        // Properties
        public function get assemblyItem():AssemblyItem
        {
            return _assemblyItem;
        }
    }
}