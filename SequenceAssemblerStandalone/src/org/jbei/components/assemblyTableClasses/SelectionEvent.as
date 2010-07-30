package org.jbei.components.assemblyTableClasses
{
    import flash.events.Event;
    
    import org.jbei.registry.models.AssemblyItem;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class SelectionEvent extends Event
    {
        public static const SELECTION_CHANGED:String = "selectionChanged";
        
        public var cells:Vector.<Cell>;
        
        // Constructor
        public function SelectionEvent(type:String, cells:Vector.<Cell>)
        {
            super(type, true, true);
            
            this.cells = cells;
        }
    }
}