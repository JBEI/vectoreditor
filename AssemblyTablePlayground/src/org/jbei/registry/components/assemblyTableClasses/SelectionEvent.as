package org.jbei.registry.components.assemblyTableClasses
{
    import flash.events.Event;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class SelectionEvent extends Event
    {
        public var cells:Vector.<Cell>;
        
        // Constructor
        public function SelectionEvent(type:String, cells:Vector.<Cell>)
        {
            super(type, true, true);
            
            this.cells = cells;
        }
    }
}