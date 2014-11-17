package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    public class TraceGridDataItem
    {
        private var _selected:Boolean = true;
        private var _traceData:TraceSequenceAnalysis;
        
        // Constructor
        public function TraceGridDataItem(traceData:TraceSequenceAnalysis = null, selected:Boolean = true)
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
        
        public function get traceData():TraceSequenceAnalysis
        {
            return _traceData;
        }
        
        public function set traceData(value:TraceSequenceAnalysis):void
        {
            _traceData = value;
        }
    }
}