package org.jbei.registry.components.assemblyTableClasses
{
    import flash.display.Graphics;
    
    import mx.core.UIComponent;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class Caret extends UIComponent
    {
        public static const CARET_COLOR:uint = 0xE0E0E0;
        public static const CARET_FRAME_COLOR:uint = 0x969DAB;
        
        private var contentHolder:ContentHolder;
        
        private var needsRemeasurement:Boolean = true;
        
        // Contructor
        public function Caret(contentHolder:ContentHolder)
        {
            super();
            
            this.contentHolder = contentHolder;
        }
        
        public function update():void
        {
            needsRemeasurement = true;
            
            invalidateDisplayList();
        }
        
        public function hide():void
        {
            visible = false;
        }
        
        public function show():void
        {
            visible = true;
        }
        
        // Protected Methods
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                render();
            }
        }
        
        protected function render():void
        {
            var g:Graphics = graphics;
            
            g.clear();
            
            var cell:Cell = contentHolder.activeCell;
            
            if(!cell) {
                return;
            }
            
            g.lineStyle(2, CARET_FRAME_COLOR);
            g.beginFill(CARET_COLOR, 0.35);
            g.drawRoundRect(cell.column.metrics.x, cell.metrics.y, cell.metrics.width, CellRenderer.CELL_HEIGHT, CellRenderer.CELL_CORNER_RADIUS, CellRenderer.CELL_CORNER_RADIUS);
            g.endFill();
        }
    }
}