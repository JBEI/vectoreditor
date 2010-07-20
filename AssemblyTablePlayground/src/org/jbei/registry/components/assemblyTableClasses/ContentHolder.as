package org.jbei.registry.components.assemblyTableClasses
{
    import flash.display.Graphics;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.core.UIComponent;
    
    import org.jbei.registry.components.AssemblyTable;
    import org.jbei.registry.models.AssemblyProvider;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ContentHolder extends UIComponent
    {
        private var assemblyTable:AssemblyTable;
        private var columns:Vector.<ColumnRenderer>;
        private var dataMapper:DataMapper;
        
        private var assemblyProviderChanged:Boolean = false;
        private var needsRemeasurement:Boolean = true;
        
        private var _assemblyProvider:AssemblyProvider;
        private var _totalHeight:int = 0;
        private var _totalWidth:int = 0;
        
        private var assemblyTableWidth:Number = 0;
        private var assemblyTableHeight:Number = 0;
        
        // Constructor
        public function ContentHolder(assemblyTable:AssemblyTable)
        {
            super();
            
            this.assemblyTable = assemblyTable;
            
            dataMapper = new DataMapper();
            
            addEventListener(MouseEvent.CLICK, onMouseClick);
        }
        
        // Properties
        public function get assemblyProvider():AssemblyProvider
        {
            return _assemblyProvider;
        }
        
        public function set assemblyProvider(value:AssemblyProvider):void
        {
            _assemblyProvider = value;
            
            assemblyProviderChanged = true;
            
            invalidateProperties();
            
            dataMapper.loadAssemblyProvider(_assemblyProvider);
        }
        
        public function get totalHeight():Number
        {
            return _totalHeight;
        }
        
        public function get totalWidth():Number
        {
            return _totalWidth;
        }
        
        // Public Methods
        public function updateMetrics(assemblyTableWidth:Number, assemblyTableHeight:Number):void
        {
            needsRemeasurement = true;
            
            invalidateDisplayList();
            
            this.assemblyTableWidth = assemblyTableWidth
            this.assemblyTableHeight = assemblyTableHeight
        }
        
        // Protected Methods
        protected override function commitProperties():void
        {
            super.commitProperties();
            
            if(assemblyProviderChanged) {
                assemblyProviderChanged = false;
                
                removeColumns();
                createColumns();
                
                needsRemeasurement = true;
            }
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                _totalWidth = assemblyTableWidth;
                _totalHeight = assemblyTableHeight;
                
                updateColumnsMetrics();
                
                drawBackground();
            }
        }
        
        // Event Handlers
        private function onMouseClick(event:MouseEvent):void
        {
            var cellRenderer:CellRenderer = lookupRenderer(event.target);
            
            if(!cellRenderer) {
                return;
            }
            
            trace("Select: ", cellRenderer.cell.column.metrics.x, cellRenderer.cell.metrics.y, cellRenderer.cell.metrics.width, cellRenderer.cell.metrics.height)
            
            //trace(cellRenderer.cell.data);
        }
        
        // Private Methods
        private function createColumns():void
        {
            if(!columns) {
                columns = new Vector.<ColumnRenderer>();
            }
            
            for(var i:int = 0; i < dataMapper.columns.length; i++) {
                var assemblyTableColumn:ColumnRenderer = new ColumnRenderer(this, dataMapper.columns[i] as Column);
                
                columns.push(assemblyTableColumn);
                
                addChild(assemblyTableColumn);
            }
            
            updateColumnsMetrics();
        }
        
        private function removeColumns():void
        {
            if(columns && columns.length > 0) {
                for(var i:int = 0; i < columns.length; i++) {
                    removeChild(columns[i] as ColumnRenderer);
                }
                
                columns.splice(0, columns.length);
            }
        }
        
        private function updateColumnsMetrics():void
        {
            if(!columns || columns.length == 0) {
                return;
            }
            
            var totalColumnsWidth:Number = 0;
            var maxColumnHeight:Number = assemblyTableHeight;
            
            var columnWidth:Number = calculateColumnWidth();
            
            for(var i:int = 0; i < columns.length; i++) {
                var assemblyColumn:ColumnRenderer = columns[i] as ColumnRenderer;
                
                var xPosition:Number = columnWidth * i;
                var yPosition:Number = 0;
                
                assemblyColumn.x = xPosition;
                assemblyColumn.y = yPosition;
                
                assemblyColumn.column.metrics.x = xPosition;
                assemblyColumn.column.metrics.y = yPosition;
                
                totalColumnsWidth += columnWidth;
                if(maxColumnHeight < assemblyColumn.column.metrics.height) {
                    maxColumnHeight = assemblyColumn.column.metrics.height;
                }
                
                assemblyColumn.update(columnWidth);
            }
            
            _totalHeight = maxColumnHeight;
            _totalWidth = totalColumnsWidth;
        }
        
        private function calculateColumnWidth():Number
        {
            if(!columns || columns.length == 0 || (assemblyTable.width == 0 && assemblyTable.height == 0)) {
                return 0;
            }
            
            var numberOfColumns:int = columns.length;
            var potentialColumnWidth:int = (assemblyTable.width - 20) / numberOfColumns; // -20 for scrollbar
            
            if(potentialColumnWidth < ColumnRenderer.MIN_COLUMN_WIDTH) {
                potentialColumnWidth = ColumnRenderer.MIN_COLUMN_WIDTH;
            }
            
            return potentialColumnWidth;
        }
        
        private function drawBackground():void
        {
            var g:Graphics = graphics;
            
            g.clear();
            g.beginFill(AssemblyTable.BACKGROUND_COLOR);
            g.drawRect(0, 0, _totalWidth + 20, _totalHeight); // +20 for scrollbar
            g.endFill();
        }
        
        private function lookupRenderer(target:Object):CellRenderer
        {
            var cellRenderer:CellRenderer = null;
            
            var index:int = 0;
            while(target && !(target is Stage) && index < 100) {
                index++;
                
                if(target is CellRenderer) {
                    cellRenderer = target as CellRenderer;
                    
                    break;
                } else {
                    target = target.parent;
                }
            }
            
            return cellRenderer;
        }
    }
}