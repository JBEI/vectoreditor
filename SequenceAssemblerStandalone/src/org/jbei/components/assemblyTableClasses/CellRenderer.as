package org.jbei.components.assemblyTableClasses
{
    import flash.display.Graphics;
    
    import mx.core.UIComponent;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class CellRenderer extends UIComponent
    {
        public static const CELL_HEIGHT:Number = 30;
        public static const CELL_FRAME_COLOR:uint = 0xCCCCCC;
        public static const CELL_CORNER_RADIUS:Number = 8;
        
        private var _cell:Cell;
        
        private var needsRemeasurement:Boolean = true;
        
        private var _actualWidth:Number;
        
        // Contructor
        public function CellRenderer(cell:Cell)
        {
            super();
            
            _cell = cell;
        }
        
        // Properties
        public function get cell():Cell
        {
            return _cell;
        }
        
        public function get actualWidth():Number
        {
            return _actualWidth;
        }
        
        // Public Methods
        public function update(width:Number):void
        {
            _actualWidth = width;
            
            needsRemeasurement = true;
            
            invalidateDisplayList();
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
            g.lineStyle(1, CELL_FRAME_COLOR);
            g.beginFill(cellBackgroundColor());
            g.drawRoundRect(0, 0, _actualWidth, CELL_HEIGHT, CELL_CORNER_RADIUS, CELL_CORNER_RADIUS);
            g.endFill();
        }
        
        protected function cellBackgroundColor():uint
        {
            return 0xFFFFFF;
        }
    }
}