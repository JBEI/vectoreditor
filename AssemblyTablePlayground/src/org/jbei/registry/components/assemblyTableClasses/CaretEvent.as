package org.jbei.registry.components.assemblyTableClasses
{
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    import org.jbei.registry.models.AssemblyItem;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class CaretEvent extends Event
    {
        public static const CARET_CHANGED:String = "caretChanged";
        
        public var cell:Cell;
        
        // Contructor
        public function CaretEvent(type:String, cell:Cell)
        {
            super(type, true, true);
            
            this.cell = cell;
        }
    }
}