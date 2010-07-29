package org.jbei.registry.components.assemblyTableClasses
{
    import flash.display.Graphics;
    
    import mx.controls.Label;
    import mx.core.UIComponent;
    
    import org.jbei.registry.models.AssemblyItem;
    import org.jbei.registry.utils.SystemUtils;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class DataCellRenderer extends CellRenderer
    {
        public static const CELL_BACKGROUND:uint = 0xFFFFA0;
        
        private var label:Label;
        
        // Contructor
        public function DataCellRenderer(dataCell:DataCell)
        {
            super(dataCell);
        }
        
        // Public Methods
        public override function update(width:Number):void
        {
            super.update(width);
            
            label.width = actualWidth - 3; // -3 to look pretty
        }
        
        // Protected Methods
        protected override function createChildren():void
        {
            super.createChildren();
            
            createLabel();
        }
        
        protected override function cellBackgroundColor():uint
        {
            return CELL_BACKGROUND;
        }
        
        // Private Methods
        private function createLabel():void
        {
            if(!label) {
                label = new Label();
                
                label.text = (cell as DataCell).assemblyItem.sequence;
                label.x = 3;
                label.y = 3;
                label.height = 30;
                label.truncateToFit = true;
                
                addChild(label);
            }
        }
    }
}