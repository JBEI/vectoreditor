package org.jbei.components.assemblyTableClasses
{
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
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
        
        protected override function render():void
        {
            super.render();
            
            drawLabel();
        }
        
        // Private Methods
        private function createLabel():void
        {
            if(!label) {
                label = new Label();
                
                var dataCell:DataCell = cell as DataCell;
                
                var itemName:String = dataCell.assemblyItem.name;
                var itemSequence:String = dataCell.assemblyItem.sequence.sequence;
                
                if(itemName != null && itemName != "") {
                    label.text = itemName;
                    
                    label.setStyle("fontWeight", "bold");
                } else {
                    label.text = (itemSequence.length > 100) ? (itemSequence.substr(0, 100) + "...") : itemSequence;
                    
                    label.setStyle("fontWeight", "normal");
                }
                
                label.x = 3;
                label.y = 3;
                label.height = 30;
                label.truncateToFit = true;
                label.visible = false;
                label.includeInLayout = false;
                
                addChild(label);
            }
        }
        
        private function drawLabel():void
        {
            label.validateNow();
            
            var bitmapData:BitmapData = new BitmapData(label.width, label.height, true, 0x00FFFFFF);
            
            var matrix:Matrix = new Matrix();
            matrix.tx = 3;
            matrix.ty = 3;
            
            bitmapData.draw(label, matrix, null, null, new Rectangle(0, 0, label.width, label.height));
            
            var g:Graphics = graphics;
            g.lineStyle(0, 0xffffff, 0);
            g.beginBitmapFill(bitmapData);
            g.drawRect(0, 0, label.width, label.height);
            g.endFill();
        }
    }
}