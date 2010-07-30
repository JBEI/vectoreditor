package org.jbei.components.assemblyTableClasses
{
    import flash.display.Graphics;
    
    import mx.core.UIComponent;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class NullCellRenderer extends CellRenderer
    {
        public static const CELL_BACKGROUND:uint = 0xFFFFFF;
        
        // Contructor
        public function NullCellRenderer(nullCell:NullCell)
        {
            super(nullCell);
        }
        
        // Protected Methods
        protected override function cellBackgroundColor():uint
        {
            return CELL_BACKGROUND;
        }
    }
}