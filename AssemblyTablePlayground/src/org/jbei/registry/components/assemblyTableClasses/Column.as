package org.jbei.registry.components.assemblyTableClasses
{
    import flash.geom.Rectangle;

    /**
     * @author Zinovii Dmytriv
     */
    public class Column
    {
        private var _metrics:Rectangle;
        private var _index:int;
        private var _cells:Vector.<Cell>;
        
        // Constructor
        public function Column(index:int)
        {
            _index = index;
            _cells = new Vector.<Cell>();
            _metrics = new Rectangle();
        }
        
        // Properties
        public function get metrics():Rectangle
        {
            return _metrics;
        }
        
        public function set metrics(value:Rectangle):void
        {
            _metrics = value;
        }
        
        public function get index():int
        {
            return _index;
        }
        
        public function get cells():Vector.<Cell>
        {
            return _cells;
        }
        
        // Public Methods
        public function addCell(cell:Cell):void
        {
            _cells.push(cell);
        }
    }
}