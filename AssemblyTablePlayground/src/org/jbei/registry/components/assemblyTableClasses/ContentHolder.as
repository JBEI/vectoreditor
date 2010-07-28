package org.jbei.registry.components.assemblyTableClasses
{
    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.ContextMenu;
    import flash.ui.Keyboard;
    
    import mx.controls.Alert;
    import mx.core.UIComponent;
    import mx.events.CloseEvent;
    import mx.events.ScrollEvent;
    
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
        private var selectionLayer:SelectionLayer;
        private var headerPanel:HeaderPanel;
        
        private var assemblyProviderChanged:Boolean = false;
        private var needsRemeasurement:Boolean = true;
        
        private var _activeCell:Cell = null;
        private var _selectedCells:Vector.<Vector.<Cell>> = null;
        private var _selectedDataCells:Vector.<Vector.<DataCell>> = null;
        private var _assemblyProvider:AssemblyProvider;
        private var _totalHeight:int = 0;
        private var _totalWidth:int = 0;
        
        private var assemblyTableWidth:Number = 0;
        private var assemblyTableHeight:Number = 0;
        private var mouseIsDown:Boolean = false;
        private var previousMouseOverCell:Cell = null;
        private var mouseSelectionStartCell:Cell = null;
        private var shiftPressed:Boolean = false;
        private var shiftSelectionStartCell:Cell = null;
        private var previousHeaderYPosition:Number = 0;
        
        // Constructor
        public function ContentHolder(assemblyTable:AssemblyTable)
        {
            super();
            
            this.assemblyTable = assemblyTable;
            
            dataMapper = new DataMapper();
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            assemblyTable.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            assemblyTable.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
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
            
            headerPanel.y = 0;
            headerPanel.updateMetrics();
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
        
        public function get selectedCells():Vector.<Vector.<Cell>>
        {
            return _selectedCells;
        }
        
        public function get selectedDataCells():Vector.<Vector.<DataCell>>
        {
            return _selectedDataCells;
        }
        
        // Public Methods
        public function updateMetrics(assemblyTableWidth:Number, assemblyTableHeight:Number):void
        {
            needsRemeasurement = true;
            
            invalidateDisplayList();
            
            this.assemblyTableWidth = assemblyTableWidth
            this.assemblyTableHeight = assemblyTableHeight
        }
        
        public function updateHeaderPosition(position:Number):void
        {
            if(position != previousHeaderYPosition) {
                previousHeaderYPosition = position;
                
                headerPanel.y = position;
            }
        }
        
        public function select(cells:Vector.<Cell>):void
        {
            selectionLayer.select(cells);
            
            _selectedCells = Vector.<Vector.<Cell>>([cells]);
            _selectedDataCells = getSelectedDataCells();
        }
        
        public function deselect():void
        {
            selectionLayer.deselect();
            
            _selectedCells = null;
            _selectedDataCells = null;
        }
        
        // Protected Methods
        protected override function createChildren():void
        {
            super.createChildren();
            
            createContextMenu();
            
            createSelectionLayer();
            
            createCaret();
            
            createHeaderPanel();
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
                
                deselect();
                
                headerPanel.width = _totalWidth;
                headerPanel.updateMetrics();
                
                if(numChildren > 0) {
                    swapChildren(selectionLayer, getChildAt(numChildren - 3));
                    
                    swapChildren(caret, getChildAt(numChildren - 2));
                    
                    swapChildren(headerPanel, getChildAt(numChildren - 1));
                }
            }
        }
        
        // Event Handlers
        private function onMouseDown(event:MouseEvent):void
        {
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            
            var clickPoint:Point = globalToLocal(new Point(event.stageX, event.stageY));
            
            var mouseActiveCell:Cell = getCellByPoint(clickPoint);
            
            if(!mouseActiveCell && activeCell) {
                return;
            }
            
            mouseIsDown = true;
            
            deselect();
            
            mouseSelectionStartCell = mouseActiveCell;
            
            updateActiveCell(mouseActiveCell);
        }
        
        private function onMouseMove(event:MouseEvent):void
        {
            if(!mouseIsDown) {
                return;
            }
            
            if(!activeCell) {
                return;
            }
            
            var mousePoint:Point = globalToLocal(new Point(event.stageX, event.stageY));
            
            var currentCell:Cell = getCellByPoint(mousePoint);
            
            if(!currentCell) {
                return;
            }
            
            if(currentCell == previousMouseOverCell) {
                return;
            }
            
            previousMouseOverCell = currentCell;
            
            selectCellsInRange(mouseSelectionStartCell, currentCell);
            
            updateActiveCell(currentCell);
        }
        
        private function onMouseUp(event:MouseEvent):void
        {
            mouseIsDown = false;
            previousMouseOverCell = null;
            mouseSelectionStartCell = null;
            
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }
        
        private function onKeyDown(event:KeyboardEvent):void
        {
            if(event.ctrlKey || event.altKey) {
                return;
            }
            
            if(event.keyCode == Keyboard.DELETE) {
                deleteSelectedCells();
                
                return;
            }
            
            if(activeCell == null) {
                return;
            }
            
            if(!event.shiftKey) {
                deselect();
            }
            
            if(event.shiftKey && !shiftPressed) {
                shiftPressed = true;
                
                shiftSelectionStartCell = activeCell;
            }
            
            if(event.keyCode == Keyboard.LEFT) {
                tryToMoveCaretLeft();
            } else if(event.keyCode == Keyboard.RIGHT) {
                tryToMoveCaretRight();
            } else if(event.keyCode == Keyboard.UP) {
                tryToMoveCaretUp();
            } else if(event.keyCode == Keyboard.DOWN) {
                tryToMoveCaretDown();
            } else if(event.keyCode == Keyboard.PAGE_DOWN) {
                tryToMoveCaretPageDown();
            } else if(event.keyCode == Keyboard.PAGE_UP) {
                tryToMoveCaretPageUp();
            }
            
            selectCellsInRange(shiftSelectionStartCell, activeCell);
        }
        
        private function onKeyUp(event:KeyboardEvent):void
        {
            if(!event.shiftKey && shiftPressed) {
                shiftPressed = false;
                
                shiftSelectionStartCell = null;
            }
        }
        
        private function onCopy(event:Event):void
        {
            if(!_selectedCells || _selectedCells.length == 0) {
                if(activeCell && activeCell is DataCell) {
                    _selectedDataCells = new Vector.<Vector.<DataCell>>();
                    _selectedDataCells.push(new Vector.<DataCell>);
                    _selectedDataCells[0].push(activeCell);
                } else {
                    return;
                }
            }
            
            copyToClipboard();
        }
        
        private function onCut(event:Event):void
        {
            if(!_selectedCells || _selectedCells.length == 0) {
                if(activeCell && activeCell is DataCell) {
                    _selectedDataCells = new Vector.<Vector.<DataCell>>();
                    _selectedDataCells.push(new Vector.<DataCell>);
                    _selectedDataCells[0].push(activeCell);
                } else {
                    return;
                }
            }
            
            cutToClipboard();
        }
        
        private function onPaste(event:Event):void
        {
            trace("paste");
        }
        
        private function onSelectAll(event:Event):void
        {
            trace("select all");
        }
        
        // Private Methods
        private function createContextMenu():void
        {
            if(!contextMenu) {
                contextMenu = new ContextMenu();
                
                contextMenu.hideBuiltInItems();
                
                contextMenu.clipboardMenu = true;
                contextMenu.clipboardItems.copy = true;
                contextMenu.clipboardItems.paste = true;
                contextMenu.clipboardItems.cut = true;
                contextMenu.clipboardItems.clear = false;
                contextMenu.clipboardItems.selectAll = true;
                
                assemblyTable.addEventListener(Event.COPY, onCopy);
                assemblyTable.addEventListener(Event.CUT, onCut);
                assemblyTable.addEventListener(Event.PASTE, onPaste);
                assemblyTable.addEventListener(Event.SELECT_ALL, onSelectAll);
            }
        }
        
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
        
        private function createSelectionLayer():void
        {
            if(!selectionLayer) {
                selectionLayer = new SelectionLayer(this);
                selectionLayer.x = 0;
                selectionLayer.y = 0;
                
                selectionLayer.includeInLayout = false;
                
                addChild(selectionLayer);
            }
        }
        
        private function createHeaderPanel():void
        {
            if(!headerPanel) {
                headerPanel = new HeaderPanel(this);
                
                headerPanel.x = 0;
                headerPanel.y = 0;
                headerPanel.height = HeaderPanel.HEADER_HEIGHT;
                
                headerPanel.includeInLayout = false;
                
                addChild(headerPanel);
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
            
            headerPanel.updateColumns(dataMapper.columns);
            
            headerPanel.updateMetrics();
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
            
            var hScrollBarSpace:Number = 20;
            var totalColumnsWidth:Number = 0;
            var maxColumnHeight:Number = assemblyTableHeight - HeaderPanel.HEADER_HEIGHT - hScrollBarSpace;
            
            var columnWidth:Number = calculateColumnWidth();
            
            for(var i:int = 0; i < columns.length; i++) {
                var assemblyColumn:ColumnRenderer = columns[i] as ColumnRenderer;
                
                var xPosition:Number = columnWidth * i;
                var yPosition:Number = HeaderPanel.HEADER_HEIGHT;
                
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
            
            _totalWidth = totalColumnsWidth;
            
            if(_totalWidth < assemblyTableWidth) {
                hScrollBarSpace = 5;
            }
            
            _totalHeight = maxColumnHeight + HeaderPanel.HEADER_HEIGHT + hScrollBarSpace;
        }
        
        private function calculateColumnWidth():Number
        {
            if(!columns || columns.length == 0 || (assemblyTable.width == 0 && assemblyTable.height == 0)) {
                return 0;
            }
            
            var maxColumnHeight:Number = 0;
            for(var i:int = 0; i < columns.length; i++) {
                var assemblyColumn:ColumnRenderer = columns[i] as ColumnRenderer;
                
                if(maxColumnHeight < assemblyColumn.column.metrics.height) {
                    maxColumnHeight = assemblyColumn.column.metrics.height;
                }
            }
            
            maxColumnHeight += HeaderPanel.HEADER_HEIGHT;
            
            var vScrollbarSpace:Number = 2; // to look pretty
            
            if(_totalHeight > assemblyTableWidth) {
                maxColumnHeight += 20; // space for horizontal scrollbar;
            }
            
            if(maxColumnHeight > assemblyTableHeight) {
                vScrollbarSpace = 20; // space for vertical scrollbar;
            }
            
            var numberOfColumns:int = columns.length;
            var potentialColumnWidth:int = (assemblyTable.width - vScrollbarSpace) / numberOfColumns; // -20 for scrollbar
            
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
            g.drawRect(0, 0, _totalWidth, _totalHeight); // +20 for scrollbar
            g.endFill();
        }
        
        private function updateActiveCell(cell:Cell):void
        {
            var assemblyItem:AssemblyItem = null;
            
            if(cell is DataCell) {
                assemblyItem = assemblyProvider.bins[cell.column.index].items[cell.index];
            }
            
            if(_activeCell != cell) {
                dispatchEvent(new CaretEvent(CaretEvent.CARET_CHANGED, cell));
                
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
        
        private function tryToMoveCaretPageDown():void
        {
            var numberOfCellsPerPage:int = calculateCellsPerPage();
            
            if(activeCell.column.cells.length == activeCell.index + numberOfCellsPerPage) {
                return; // already at last cell
            }
            
            if(activeCell.index + numberOfCellsPerPage >= activeCell.column.cells.length) {
                updateActiveCell(columns[activeCell.column.index].column.cells[activeCell.column.cells.length - 1]);
            } else {
                updateActiveCell(columns[activeCell.column.index].column.cells[activeCell.index + numberOfCellsPerPage]);
            }
        }
        
        private function tryToMoveCaretPageUp():void
        {
            var numberOfCellsPerPage:int = calculateCellsPerPage();
            
            if(activeCell.index == 0) {
                return; // nothing to scroll up
            }
            
            if(activeCell.index - numberOfCellsPerPage <= 0) {
                updateActiveCell(columns[activeCell.column.index].column.cells[0]);
            } else {
                updateActiveCell(columns[activeCell.column.index].column.cells[activeCell.index - numberOfCellsPerPage]);
            }
        }
        
        private function getCellByPoint(point:Point):Cell
        {
            var resultCell:Cell = null;
            
            for(var i:int = 0; i < columns.length; i++) {
                var currentColumn:Column = columns[i].column;
                
                if(currentColumn.metrics.x > point.x || currentColumn.metrics.x + currentColumn.metrics.width < point.x) {
                    continue;
                }
                
                for(var j:int = 0; j < currentColumn.cells.length; j++) {
                    var currentCell:Cell = currentColumn.cells[j] as Cell;
                    
                    if(currentCell.metrics.y + currentCell.column.metrics.y < point.y && currentCell.metrics.y + currentCell.column.metrics.y + currentCell.metrics.height > point.y) {
                        resultCell = currentCell;
                        
                        break;
                    }
                }
                
                if(resultCell) {
                    break;
                }
            }
            
            return resultCell
        }
        
        private function selectCellsInRange(startCell:Cell, endCell:Cell):void
        {
            if(!startCell || !endCell || startCell == endCell) {
                deselect();
                
                return;
            }
            
            var startColumnIndex:int = startCell.column.index < endCell.column.index ? startCell.column.index : endCell.column.index;
            var endColumnIndex:int = startCell.column.index < endCell.column.index ? endCell.column.index : startCell.column.index;
            var startRowIndex:int = startCell.index < endCell.index ? startCell.index : endCell.index;
            var endRowIndex:int = startCell.index < endCell.index ? endCell.index : startCell.index;
            
            _selectedCells = new Vector.<Vector.<Cell>>();
            var selectedCellsList:Vector.<Cell> = new Vector.<Cell>();
            
            var index:int = 0;
            for(var c:int = startColumnIndex; c <= endColumnIndex; c++) {
                _selectedCells.push(new Vector.<Cell>());
                
                for(var r:int = startRowIndex; r <= endRowIndex; r++) {
                    _selectedCells[index].push(columns[c].column.cells[r]);
                    
                    selectedCellsList.push(columns[c].column.cells[r]);
                }
                
                index++;
            }
            
            _selectedDataCells = getSelectedDataCells();
            
            selectionLayer.select(selectedCellsList);
        }
        
        private function calculateCellsPerPage():Number
        {
            var result:int = int(Math.floor(assemblyTableHeight / CellRenderer.CELL_HEIGHT));
            
            result = (result <= 1) ? 1 : (result - 1);
            
            return result;
        }
        
        private function getSelectedDataCells():Vector.<Vector.<DataCell>>
        {
            var dataCells:Vector.<Vector.<DataCell>> = new Vector.<Vector.<DataCell>>();
            
            var index:int = 0;
            var nonEmptyColumn:Boolean = false;
            for(var i:int = 0; i < _selectedCells.length; i++) {
                nonEmptyColumn = false;
                
                for(var j:int = 0; j < _selectedCells[i].length; j++) {
                    if(_selectedCells[i][j] is DataCell) {
                        var dataCell:DataCell = _selectedCells[i][j] as DataCell;
                        
                        if(!nonEmptyColumn) {
                            nonEmptyColumn = true;
                            
                            dataCells.push(new Vector.<DataCell>());
                            dataCells[index].push(dataCell);
                        } else {
                            dataCells[index].push(dataCell);
                        }
                    }
                }
                
                if(nonEmptyColumn) {
                    index++;
                }
            }
            
            return dataCells;
        }
        
        private function copyToClipboard():void
        {
            if(!_selectedDataCells || _selectedDataCells.length == 0) {
                return;
            }
            
            var dataItems:Vector.<Vector.<AssemblyItem>> = new Vector.<Vector.<AssemblyItem>>();
            
            for(var i:int = 0; i < _selectedDataCells.length; i++) {
                dataItems.push(new Vector.<AssemblyItem>());
                
                for(var j:int = 0; j < _selectedDataCells[i].length; j++) {
                    dataItems[i].push(_selectedDataCells[i][j].assemblyItem);
                }
            }
            
            var dataAsString:String = "";
            var flag:Boolean = true;
            var currentRowIndex:int = 0;
            var emptyCells:int = 0;
            var rowDataAsString:String = "";
            
            while(flag) {
                flag = false;
                emptyCells = 0;
                rowDataAsString = "";
                
                for(var k:int = 0; k < dataItems.length; k++) {
                    if(dataItems[k].length - 1 >= currentRowIndex) {
                        flag = true;
                        
                        var parsedData:String = dataItems[k][currentRowIndex].toString();
                        
                        if(parsedData.indexOf("\t") >=0 || parsedData.indexOf("\n") >=0 || parsedData.indexOf("\r") >=0) {
                            parsedData = "\"" + parsedData.replace("\"", "\\\"") + "\"";
                        }
                        
                        rowDataAsString += parsedData;
                        
                        if(k < dataItems.length - 1) {
                            rowDataAsString += ",";
                        }
                    } else {
                        emptyCells++;
                        
                        if(k < dataItems.length - 1) {
                            rowDataAsString += ",";
                        }
                    }
                }
                
                if(emptyCells == dataItems.length) {
                    break;
                }
                
                dataAsString += rowDataAsString + "\n";
                currentRowIndex++;
            }
            
            Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(Constants.ASSEMBLY_TABLE_CELLS_COPY_CLIPBOARD_KEY, dataItems, true);
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, dataAsString, true);
        }
        
        private function cutToClipboard():void
        {
            copyToClipboard();
            
            doDeleteSelectedCells();
        }
        
        private function deleteSelectedCells():void
        {
            if(!_selectedDataCells || _selectedDataCells.length == 0) {
                if(activeCell && activeCell is DataCell) {
                    _selectedDataCells = new Vector.<Vector.<DataCell>>();
                    _selectedDataCells.push(new Vector.<DataCell>);
                    _selectedDataCells[0].push(activeCell);
                } else {
                    return;
                }
            }
            
            Alert.show("Are you sure you want to delete selected items?", "Delete items", Alert.YES | Alert.NO, this.parent as Sprite, onAlertDeleteItemsClose, null, Alert.NO);            
        }
        
        private function onAlertDeleteItemsClose(event:CloseEvent):void
        {
            if(event.detail == 1) {
                doDeleteSelectedCells();
            }
        }
        
        private function doDeleteSelectedCells():void
        {
            _assemblyProvider.manualUpdateStart();
            
            try {
                for(var i:int = 0; i < _selectedDataCells.length; i++) {
                    for(var j:int = 0; j < _selectedDataCells[i].length; j++) {
                        var dataCell:DataCell = _selectedDataCells[i][j];
                        
                        _assemblyProvider.deleteAssemblyItem(_assemblyProvider.bins[dataCell.column.index], dataCell.assemblyItem);
                    }
                }
            } finally {
                _assemblyProvider.manualUpdateEnd();
            }
        }
    }
}