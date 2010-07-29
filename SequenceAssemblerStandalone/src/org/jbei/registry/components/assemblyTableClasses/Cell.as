package org.jbei.registry.components.assemblyTableClasses
{
    import flash.geom.Rectangle;

    /**
     * @author Zinovii Dmytriv
     */
    public class Cell
    {
        private var _column:Column;
        private var _index:uint;
        private var _metrics:Rectangle = null;
        
        // Constructor
        public function Cell(column:Column, index:uint)
        {
            _column = column;
            _index = index;
            _metrics = new Rectangle();
        }
        
        // Properties
        public function get column():Column
        {
            return _column;
        }
        
        public function get index():uint
        {
            return _index;
        }
        
        public function get metrics():Rectangle
        {
            return _metrics;
        }
        
        public function set metrics(value:Rectangle):void
        {
            _metrics = value;
        }
    }
}