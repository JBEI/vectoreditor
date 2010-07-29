package org.jbei.registry.components.assemblyTableClasses
{
    import flash.events.Event;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ColumnHeaderDragEvent extends Event
    {
        public static const START_HEADER_DRAGGING:String = "startHeaderDragging";
        public static const STOP_HEADER_DRAGGING:String = "stopHeaderDragging";
        public static const HEADER_DRAGGING:String = "headerDragging";
        
        private var _columnHeader:ColumnHeader;
        
        // Constructor
        public function ColumnHeaderDragEvent(type:String, columnHeader:ColumnHeader)
        {
            super(type, true, true);
            
            _columnHeader = columnHeader;
        }
        
        // Properties
        public final function get columnHeader():ColumnHeader
        {
            return _columnHeader;
        }
    }
}