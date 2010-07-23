package org.jbei.registry.components.assemblyTableClasses
{
    import flash.display.Graphics;
    
    import mx.core.UIComponent;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class SelectionLayer extends UIComponent
    {
        public static const SELECTION_COLOR:uint = 0x0099FF;
        
        private var contentHolder:ContentHolder;
        
        private var _selected:Boolean = false;
        
        // Constructor
        public function SelectionLayer(contentHolder:ContentHolder)
        {
            super();
            
            this.contentHolder = contentHolder;
        }
        
        // Properties
        public function get selected():Boolean
        {
            return _selected;
        }
        
        // Public Methods
        public function deselect():void
        {
            doDeselect();
        }
        
        public function select(cells:Vector.<Cell>):void
        {
            doDeselect();
            
            if(!cells || cells.length == 0) {
                return;
            }
            
            doSelect(cells);
        }
        
        // Private Methods
        private function doDeselect():void
        {
            var g:Graphics = graphics;
            
            g.clear();
            
            _selected = false;
        }
        
        private function doSelect(cells:Vector.<Cell>):void
        {
            var g:Graphics = graphics;
            
            g.clear();
            
            for(var i:int = 0; i < cells.length; i++) {
                highlightCell(cells[i]);
            }
            
            _selected = true;
        }
        
        private function highlightCell(cell:Cell):void
        {
            var g:Graphics = graphics;
            
            g.beginFill(SELECTION_COLOR, 0.2);
            g.drawRoundRect(cell.column.metrics.x, cell.column.metrics.y + cell.metrics.y, cell.metrics.width, cell.metrics.height, CellRenderer.CELL_CORNER_RADIUS, CellRenderer.CELL_CORNER_RADIUS);
            g.endFill();
        }
    }
}