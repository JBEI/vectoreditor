package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    public class TraceGridDataItem
    {
        private var _selected:Boolean = true;
        private var _traceData:TraceSequence;
        
        // Constructor
        public function TraceGridDataItem(traceData:TraceSequence = null, selected:Boolean = true)
        {
            _selected = selected;
            _traceData = traceData;
        }
        
        // Properties
        [Bindable]
        public function get selected():Boolean
        {
            return _selected;
        }
        
        public function set selected(value:Boolean):void
        {
            _selected = value;
        }
        
        public function get traceData():TraceSequence
        {
            return _traceData;
        }
        
        public function set traceData(value:TraceSequence):void
        {
            _traceData = value;
        }
    }
}