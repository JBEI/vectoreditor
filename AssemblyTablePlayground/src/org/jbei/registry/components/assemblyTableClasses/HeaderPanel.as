package org.jbei.registry.components.assemblyTableClasses
{
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.utils.flash_proxy;
    
    import mx.core.UIComponent;
    import mx.styles.StyleManager;
    
    import org.jbei.registry.models.Bin;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class HeaderPanel extends UIComponent
    {
        public static const HEADER_HEIGHT:Number = 25;
        public static const DRAGGING_COLUMN_CARET_COLOR:uint = 0x666666;
        
        private var contentHolder:ContentHolder;
        private var columnHeaders:Vector.<ColumnHeader>;
        private var draggingHeader:UIComponent;
        private var draggingCaret:UIComponent;
        
        private var dragging:Boolean = false;
        private var clickPoint:Point;
        private var draggingColumn:Column = null;
        
        private var actualWidth:Number = 0;
        private var actualHeight:Number = 0;
        
        private var needsRemeasurement:Boolean = true;
        
        // Constructor
        public function HeaderPanel(contentHolder:ContentHolder)
        {
            super();
            
            this.contentHolder = contentHolder;
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
        
        // Public Methods
        public function updateMetrics():void
        {
            needsRemeasurement = true;
            
            invalidateDisplayList();
            
            updateColumnHeadersMetrics();
        }
        
        public function updateColumns(columns:Vector.<Column>):void
        {
            removeColumnHeaders();
            
            createColumnHeaders(columns);
        }
        
        // Protected Methods
        protected override function createChildren():void
        {
            super.createChildren();
            
            createDraggingHeader();
            
            createDraggingCaret();
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                renderBottomLine();
                
                actualWidth = unscaledWidth;
                actualHeight = unscaledHeight;
                
                if(draggingHeader) { // make draggingHeader above all children
                    swapChildren(draggingHeader, getChildAt(numChildren - 2));
                    
                    swapChildren(draggingCaret, getChildAt(numChildren - 1));
                }
            }
        }
        
        // Event Handlers
        private function onColumnHeaderStartDragging(event:ColumnHeaderDragEvent):void
        {
            dragging = true;
            draggingColumn = event.columnHeader.column;
            
            showDraggingHeader(event.columnHeader);
            showDraggingCaret(event.columnHeader);
        }
        
        private function onColumnHeaderStopDragging(event:ColumnHeaderDragEvent):void
        {
            hideDraggingHeader();
            hideDraggingCaret();
        }
        
        private function onMouseDown(event:MouseEvent):void
        {
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            
            clickPoint = globalToLocal(new Point(event.stageX, event.stageY));
        }
        
        private function onMouseMove(event:MouseEvent):void
        {
            if(dragging) {
                var currentPoint:Point = globalToLocal(new Point(event.stageX, event.stageY));
                
                if(currentPoint.x > draggingHeader.width / 2) {
                    draggingHeader.x = currentPoint.x - draggingHeader.width / 2;
                } else {
                    draggingHeader.x = 0;
                }
                
                if(currentPoint.x + draggingHeader.width / 2 > actualWidth) {
                    draggingHeader.x = actualWidth - draggingHeader.width;
                }
                
                var dropIndex:int = getDropColumnIndex(currentPoint);
                
                if(columnHeaders && columnHeaders.length > 0) {
                    var columnWidth:Number = columnHeaders[0].column.metrics.width;
                    
                    if(dropIndex >= columnHeaders.length) {
                        draggingCaret.x = columnHeaders.length * columnWidth;
                        
                        dispatchEvent(new ColumnHeaderDragEvent(ColumnHeaderDragEvent.HEADER_DRAGGING, columnHeaders[columnHeaders.length - 1]));
                    } else if(dropIndex <= 0) {
                        draggingCaret.x = 3; // to look pretty
                        
                        dispatchEvent(new ColumnHeaderDragEvent(ColumnHeaderDragEvent.HEADER_DRAGGING, columnHeaders[0]));
                    } else {
                        draggingCaret.x = columnWidth * dropIndex;
                        
                        dispatchEvent(new ColumnHeaderDragEvent(ColumnHeaderDragEvent.HEADER_DRAGGING, columnHeaders[dropIndex]));
                    }
                }
            }
        }
        
        private function onMouseUp(event:MouseEvent):void
        {
            if(dragging) {
                var currentPoint:Point = globalToLocal(new Point(event.stageX, event.stageY));
                
                var dropIndex:int = getDropColumnIndex(currentPoint);
                
                if(dropIndex >= 0 && draggingColumn) {
                    var dragIndex:int = draggingColumn.index;
                    
                    if(dragIndex != dropIndex) {
                        if(dropIndex > dragIndex) {
                            dropIndex -= 1;
                        }
                        
                        if(dropIndex >= columnHeaders.length) {
                            dropIndex = columnHeaders.length - 1; // last
                        }
                        
                        var dropBin:Bin = contentHolder.assemblyProvider.bins[dropIndex];
                        var dragBin:Bin = contentHolder.assemblyProvider.bins[dragIndex];
                        
                        contentHolder.assemblyProvider.swapBins(dropBin, dragBin);
                    }
                }
            }
            
            dragging = false;
            draggingColumn = null;
            
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
        
        // Private Methods
        private function createDraggingHeader():void
        {
            if(!draggingHeader) {
                draggingHeader = new UIComponent();
                
                draggingHeader.x = 0;
                draggingHeader.y = 0;
                
                draggingHeader.includeInLayout = false;
                draggingHeader.visible = false;
                
                addChild(draggingHeader);
            }
        }
        
        private function createDraggingCaret():void
        {
            if(!draggingCaret) {
                draggingCaret = new UIComponent();
                
                draggingCaret.x = 0;
                draggingCaret.y = 0;
                
                draggingCaret.includeInLayout = false;
                draggingCaret.visible = false;
                
                addChild(draggingCaret);
            }
        }
        
        private function renderBottomLine():void
        {
            var g:Graphics = graphics;
            g.clear();
            
            g.lineStyle(2, 0x999999, 0.5);
        }
        
        private function createColumnHeaders(columns:Vector.<Column>):void
        {
            columnHeaders = new Vector.<ColumnHeader>();
            
            for(var i:int = 0; i < columns.length; i++) {
                var column:Column = columns[i];
                
                var columnHeader:ColumnHeader = new ColumnHeader(column, contentHolder);
                
                columnHeader.x = column.metrics.x;
                columnHeader.y = 0;
                columnHeader.updateMetrics(column.metrics.width, HeaderPanel.HEADER_HEIGHT);
                columnHeader.addEventListener(ColumnHeaderDragEvent.START_HEADER_DRAGGING, onColumnHeaderStartDragging);
                columnHeader.addEventListener(ColumnHeaderDragEvent.STOP_HEADER_DRAGGING, onColumnHeaderStopDragging);
                
                columnHeaders.push(columnHeader);
                
                addChild(columnHeader);
            }
        }
        
        private function removeColumnHeaders():void
        {
            if(!columnHeaders) {
                return;
            }
            
            for(var i:int = 0; i < columnHeaders.length; i++) {
                removeChild(columnHeaders[i]);
            }
            
            columnHeaders = null;
        }
        
        private function updateColumnHeadersMetrics():void
        {
            if(columnHeaders) {
                for(var i:int = 0; i < columnHeaders.length; i++) {
                    var columnHeader:ColumnHeader = columnHeaders[i];
                    
                    columnHeader.x = columnHeader.column.metrics.x;
                    
                    columnHeader.updateMetrics(columnHeader.column.metrics.width, HeaderPanel.HEADER_HEIGHT);
                }
            }
        }
        
        private function showDraggingHeader(columnHeader:ColumnHeader):void
        {
            var headerBitmapData:BitmapData = columnHeader.headerBitmapData();
            
            draggingHeader.visible = true;
            draggingHeader.width = columnHeader.column.metrics.width;
            draggingHeader.height = HEADER_HEIGHT;
            
            draggingHeader.graphics.clear();
            draggingHeader.graphics.beginBitmapFill(headerBitmapData);
            draggingHeader.graphics.drawRect(0, 0, columnHeader.column.metrics.width - 19, HEADER_HEIGHT); // -20 to remove drop down button 
            draggingHeader.graphics.endFill();
        }
        
        private function hideDraggingHeader():void
        {
            draggingHeader.visible = false;
        }
        
        private function showDraggingCaret(columnHeader:ColumnHeader):void
        {
            draggingCaret.visible = true;
            draggingCaret.width = 2;
            draggingCaret.height = HEADER_HEIGHT + columnHeader.column.metrics.height + columnHeader.column.metrics.y;
            
            draggingCaret.graphics.clear();
            draggingCaret.graphics.lineStyle(2, DRAGGING_COLUMN_CARET_COLOR);
            draggingCaret.graphics.moveTo(0, 0);
            draggingCaret.graphics.lineTo(0, columnHeader.column.metrics.height + columnHeader.column.metrics.y);
        }
        
        private function hideDraggingCaret():void
        {
            draggingCaret.visible = false;
        }
        
        private function getDropColumnIndex(point:Point):int
        {
            var result:int = -1;
            
            if(!columnHeaders || columnHeaders.length == 0) {
                return result;
            }
            
            var columnWidth:Number = columnHeaders[0].column.metrics.width;
            
            if(point.x <= columnWidth / 2) {
                return 0;
            } else if(columnWidth * columnHeaders.length - columnWidth / 2 <= point.x) {
                return columnHeaders.length;
            }
            
            for(var i:int = 1; i < columnHeaders.length; i++) {
                var column:Column = columnHeaders[i].column;
                
                if((point.x <= column.metrics.x + columnWidth / 2) && (point.x >= column.metrics.x - columnWidth / 2)) {
                    result = i;
                    
                    break;
                } 
            }
            
            return result;
        }
    }
}