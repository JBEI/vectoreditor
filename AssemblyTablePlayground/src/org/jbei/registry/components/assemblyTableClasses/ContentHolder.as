package org.jbei.registry.components.assemblyTableClasses
{
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Keyboard;
    
    import mx.core.UIComponent;
    
    import org.jbei.registry.components.AssemblyTable;
    import org.jbei.registry.models.AssemblyItem;
    import org.jbei.registry.models.AssemblyProvider;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ContentHolder extends UIComponent
    {
        private var assemblyTable:AssemblyTable;
        private var columns:Vector.<ColumnRenderer>;
        private var dataMapper:DataMapper;
        private var caret:Caret;
        
        private var assemblyProviderChanged:Boolean = false;
        private var needsRemeasurement:Boolean = true;
        
        private var _activeCell:Cell = null;
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
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            assemblyTable.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
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
            
            updateActiveCell(null);
        }
        
        public function get totalHeight():Number
        {
            return _totalHeight;
        }
        
        public function get totalWidth():Number
        {
            return _totalWidth;
        }
        
        public function get activeCell():Cell
        {
            return _activeCell;
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
        protected override function createChildren():void
        {
            super.createChildren();
            
            createCaret();
        }
        
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
                
                caret.update();
                
                if(numChildren > 0) { // swap children to make caret on very top
                    swapChildren(caret, getChildAt(numChildren - 1));
                }
            }
        }
        
        // Event Handlers
        private function onMouseDown(event:MouseEvent):void
        {
            var clickPoint:Point = globalToLocal(new Point(event.stageX, event.stageY));
            
            var mouseActiveCell:Cell = null;
            
            for(var i:int = 0; i < columns.length; i++) {
                var currentColumn:Column = columns[i].column;
                
                if(currentColumn.metrics.x > clickPoint.x || currentColumn.metrics.x + currentColumn.metrics.width < clickPoint.x) {
                    continue;
                }
                
                for(var j:int = 0; j < currentColumn.cells.length; j++) {
                    var currentCell:Cell = currentColumn.cells[j] as Cell;
                    
                    if(currentCell.metrics.y < clickPoint.y && currentCell.metrics.y + currentCell.metrics.height > clickPoint.y) {
                        mouseActiveCell = currentCell;
                        
                        break;
                    }
                }
                
                if(mouseActiveCell) {
                    break;
                }
            }
            
            if(!mouseActiveCell && activeCell) {
                return;
            }
            
            updateActiveCell(mouseActiveCell);
        }
        
        private function onKeyDown(event:KeyboardEvent):void
        {
            if(activeCell == null) {
                return;
            }
            
            if(event.keyCode == Keyboard.LEFT) {
                tryToMoveCaretLeft();
            } else if(event.keyCode == Keyboard.RIGHT) {
                tryToMoveCaretRight();
            } else if(event.keyCode == Keyboard.UP) {
                tryToMoveCaretUp();
            } else if(event.keyCode == Keyboard.DOWN) {
                tryToMoveCaretDown();
            }
        }
        
        // Private Methods
        private function createCaret():void
        {
            if(!caret) {
                caret = new Caret(this);
                
                caret.x = 0;
                caret.y = 0;
                caret.show();
                caret.includeInLayout = false;
                
                addChild(caret);
            }
        }
        
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
        
        private function updateActiveCell(cell:Cell):void
        {
            var assemblyItem:AssemblyItem = null;
            
            if(cell is DataCell) {
                assemblyItem = assemblyProvider.bins[cell.column.index].items[cell.index];
            }
            
            if(_activeCell != cell) {
                dispatchEvent(new CaretEvent(CaretEvent.CARET_CHANGED, assemblyItem, cell));
                
                _activeCell = cell;
                
                caret.update();
            }
        }
        
        private function tryToMoveCaretLeft():void
        {
            if(activeCell.column.index > 0) {
                updateActiveCell(columns[activeCell.column.index - 1].column.cells[activeCell.index]);
            }
        }
        
        private function tryToMoveCaretRight():void
        {
            if(columns.length > activeCell.column.index + 1) {
                updateActiveCell(columns[activeCell.column.index + 1].column.cells[activeCell.index]);
            }
        }
        
        private function tryToMoveCaretDown():void
        {
            if(activeCell.column.cells.length > activeCell.index + 1) {
                updateActiveCell(columns[activeCell.column.index].column.cells[activeCell.index + 1]);
            }
        }
        
        private function tryToMoveCaretUp():void
        {
            if(activeCell.index > 0) {
                updateActiveCell(columns[activeCell.column.index].column.cells[activeCell.index - 1]);
            }
        }
    }
}