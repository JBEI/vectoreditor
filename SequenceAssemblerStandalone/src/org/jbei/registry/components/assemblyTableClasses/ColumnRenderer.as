package org.jbei.registry.components.assemblyTableClasses
{
    import flash.display.Graphics;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.core.UIComponent;
    
    import org.jbei.registry.utils.SystemUtils;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ColumnRenderer extends UIComponent
    {
        public static const MIN_COLUMN_WIDTH:int = 100;
        
        private var contentHolder:ContentHolder;
        private var cellRenderers:Vector.<CellRenderer> = new Vector.<CellRenderer>();
        
        private var _column:Column;
        
        private var needsRemeasurement:Boolean = true;
        
        // Constructor
        public function ColumnRenderer(contentHolder:ContentHolder, column:Column)
        {
            super();
            
            this.contentHolder = contentHolder;
                
            _column = column;
            
            createRenderers();
        }
        
        // Properties
        public function get column():Column
        {
            return _column;
        }
        
        // Public Methods
        public function update(width:Number):void
        {
            _column.metrics.width = width;
            
            needsRemeasurement = true;
            
            updateRenderers();
            
            invalidateDisplayList();
        }
        
        // Protected Methods
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                drawFrame();
            }
        }
        
        // Private Methods
        private function drawFrame():void
        {
            var g:Graphics = graphics;
            
            g.clear();
            /*g.lineStyle(1, 0xCCCCCC);
            g.moveTo(0, 0);
            g.lineTo(_column.metrics.width, 0);
            g.lineTo(_column.metrics.width, 400);
            g.lineTo(0, 400);
            g.lineTo(0, 0);*/
        }
        
        private function createRenderers():void
        {
            _column.metrics.height = 0;
            
            if(!_column || _column.cells.length == 0) {
                return;
            }
            
            for(var i:int = 0; i < _column.cells.length; i++) {
                var currentCell:Cell = _column.cells[i] as Cell;
                
                var cellRenderer:CellRenderer;
                
                if(currentCell is DataCell) {
                    cellRenderer = new DataCellRenderer(currentCell as DataCell);
                } else if(currentCell is NullCell) {
                    cellRenderer = new NullCellRenderer(currentCell as NullCell);
                }
                
                cellRenderer.x = 0;
                cellRenderer.y = CellRenderer.CELL_HEIGHT * i;
                
                cellRenderers.push(cellRenderer);
                
                _column.metrics.height += CellRenderer.CELL_HEIGHT;
                
                addChild(cellRenderer);
            }
        }
        
        private function removeRenderers():void
        {
            _column.metrics.height = 0;
            
            if(!cellRenderers || cellRenderers.length == 0) {
                return;
            }
            
            for(var i:int = 0; i < cellRenderers.length; i++) {
                var cellRenderer:CellRenderer = cellRenderers[i] as CellRenderer;
                
                removeChild(cellRenderer);
            }
            
            cellRenderers.splice(0, cellRenderers.length);
        }
        
        private function updateRenderers():void
        {
            if(!cellRenderers || cellRenderers.length == 0) {
                return;
            }
            
            for(var i:int = 0; i < _column.cells.length; i++) {
                var currentCell:Cell = _column.cells[i];
                
                var cellRenderer:CellRenderer = cellRenderers[i] as CellRenderer;
                
                currentCell.metrics.x = 0;
                currentCell.metrics.y = cellRenderer.y;
                currentCell.metrics.height = CellRenderer.CELL_HEIGHT;
                currentCell.metrics.width = _column.metrics.width;
                
                cellRenderer.update(_column.metrics.width);
            }
        }
    }
}