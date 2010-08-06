package org.jbei.components.assemblyTableClasses
{
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.utils.flash_proxy;
    
    import mx.core.BitmapAsset;
    import mx.core.UIComponent;
    import mx.events.IndexChangedEvent;
    import mx.styles.StyleManager;
    
    import org.jbei.registry.models.Bin;
    import org.jbei.registry.models.FeatureTypeManager;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class HeaderPanel extends UIComponent
    {
        public static const HEADER_HEIGHT:Number = 25;
        public static const HEADER_PLUS_BUTTON_WIDTH:Number = 25;
        public static const DRAGGING_COLUMN_CARET_COLOR:uint = 0x000000;
        public static const DRAGGING_DIMMED_COLUMN_COLOR:uint = 0x888888;
        public static const DRAGGING_COLUMN_FRAME_COLOR:uint = 0xAAAAAA;
        
        [Embed(source="assets/plus.png")]
        private var plusIcon:Class;
        
        private var contentHolder:ContentHolder;
        private var columnHeaders:Vector.<ColumnHeader>;
        //private var draggingHeader:UIComponent;
        private var draggingCaret:UIComponent;
        private var draggingDimColumn:UIComponent;
        private var draggingColumn:UIComponent;
        private var headerPlusButton:UIComponent;
        
        private var dragging:Boolean = false;
        private var clickPoint:Point;
        private var dragColumn:Column = null;
        
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
            
            createHeaderPlusButton();
            
            //createDraggingHeader();
            
            createDraggingCaret();
            
            createDraggingDimColumn();
            
            createDraggingColumn();
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                actualWidth = unscaledWidth;
                actualHeight = unscaledHeight;
                
                //swapChildren(draggingHeader, getChildAt(numChildren - 4));
                
                swapChildren(draggingDimColumn, getChildAt(numChildren - 3));
                
                swapChildren(draggingColumn, getChildAt(numChildren - 2));
                
                swapChildren(draggingCaret, getChildAt(numChildren - 1));
            }
        }
        
        // Event Handlers
        private function onColumnHeaderStartDragging(event:ColumnHeaderDragEvent):void
        {
            dragging = true;
            dragColumn = event.columnHeader.column;
            
            //showDraggingHeader(event.columnHeader);
            showDraggingCaret(event.columnHeader);
            showDraggingDimColumn(event.columnHeader);
            showDraggingColumn(contentHolder.getColumnRendererByIndex(event.columnHeader.column.index), event.columnHeader);
        }
        
        private function onColumnHeaderStopDragging(event:ColumnHeaderDragEvent):void
        {
            //hideDraggingHeader();
            hideDraggingCaret();
            hideDraggingDimColumn();
            hideDraggingColumn();
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
                
                if(currentPoint.x > draggingColumn.width / 2) {
                    draggingColumn.x = currentPoint.x - draggingColumn.width / 2;
                } else {
                    draggingColumn.x = 0;
                }
                
                if(currentPoint.x + draggingColumn.width / 2 > actualWidth) {
                    draggingColumn.x = actualWidth - draggingColumn.width;
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
                
                if(dropIndex >= 0 && dragColumn) {
                    var dragIndex:int = dragColumn.index;
                    
                    if(dragIndex != dropIndex) {
                        if(dropIndex > dragIndex) {
                            dropIndex -= 1;
                        }
                        
                        if(dropIndex >= columnHeaders.length) {
                            dropIndex = columnHeaders.length - 1; // last
                        }
                        
                        var dragBin:Bin = contentHolder.assemblyProvider.bins[dragIndex];
                        
                        contentHolder.assemblyProvider.moveBin(dragBin, dropIndex);
                    }
                }
            }
            
            dragging = false;
            dragColumn = null;
            
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
        
        private function onHeaderPlusButtonMouseOver(event:MouseEvent):void
        {
            drawSelectedHeaderPlusButton();
        }
        
        private function onHeaderPlusButtonMouseOut(event:MouseEvent):void
        {
            drawHeaderPlusButton();
        }
        
        private function onHeaderPlusButtonMouseClick(event:MouseEvent):void
        {
            var newBin:Bin = new Bin(FeatureTypeManager.instance.getTypeByValue("general"));
            
            contentHolder.assemblyProvider.addBin(newBin);
        }
        
        // Private Methods
        /*private function createDraggingHeader():void
        {
            if(!draggingHeader) {
                draggingHeader = new UIComponent();
                
                draggingHeader.x = 0;
                draggingHeader.y = 0;
                
                draggingHeader.includeInLayout = false;
                draggingHeader.visible = false;
                
                addChild(draggingHeader);
            }
        }*/
        
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
        
        private function createDraggingDimColumn():void
        {
            if(!draggingDimColumn) {
                draggingDimColumn = new UIComponent();
                
                draggingDimColumn.x = 0;
                draggingDimColumn.y = 0;
                
                draggingDimColumn.includeInLayout = false;
                draggingDimColumn.visible = false;
                
                addChild(draggingDimColumn);
            }
        }
        
        private function createDraggingColumn():void
        {
            if(!draggingColumn) {
                draggingColumn = new UIComponent();
                
                draggingColumn.x = 0;
                draggingColumn.y = 0;
                
                draggingColumn.includeInLayout = false;
                draggingColumn.visible = false;
                
                addChild(draggingColumn);
            }
        }
        
        private function createHeaderPlusButton():void
        {
            if(!headerPlusButton) {
                headerPlusButton = new UIComponent;
                
                headerPlusButton.x = 0;
                headerPlusButton.y = 0;
                
                drawHeaderPlusButton();
                
                headerPlusButton.addEventListener(MouseEvent.CLICK, onHeaderPlusButtonMouseClick);
                headerPlusButton.addEventListener(MouseEvent.ROLL_OVER, onHeaderPlusButtonMouseOver);
                headerPlusButton.addEventListener(MouseEvent.ROLL_OUT, onHeaderPlusButtonMouseOut);
                
                headerPlusButton.toolTip = "Add column";
                
                addChild(headerPlusButton);
            }
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
            headerPlusButton.x = 0;
            
            if(columnHeaders) {
                for(var i:int = 0; i < columnHeaders.length; i++) {
                    var columnHeader:ColumnHeader = columnHeaders[i];
                    
                    columnHeader.x = columnHeader.column.metrics.x;
                    
                    columnHeader.updateMetrics(columnHeader.column.metrics.width, HeaderPanel.HEADER_HEIGHT);
                    
                    headerPlusButton.x = columnHeader.x + columnHeader.column.metrics.width;
                }
            }
        }
        
        /*private function showDraggingHeader(columnHeader:ColumnHeader):void
        {
            var headerBitmapData:BitmapData = columnHeader.headerBitmapData();
            
            draggingHeader.visible = true;
            draggingHeader.width = columnHeader.column.metrics.width;
            draggingHeader.height = HEADER_HEIGHT;
            
            draggingHeader.graphics.clear();
            draggingHeader.graphics.beginBitmapFill(headerBitmapData);
            draggingHeader.graphics.drawRect(0, 0, columnHeader.column.metrics.width + 1, HEADER_HEIGHT); // -20 to remove drop down button 
            draggingHeader.graphics.endFill();
        }
        
        private function hideDraggingHeader():void
        {
            draggingHeader.visible = false;
        }*/
        
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
        
        private function showDraggingDimColumn(columnHeader:ColumnHeader):void
        {
            var g:Graphics = draggingDimColumn.graphics;
            
            g.clear();
            g.beginFill(DRAGGING_DIMMED_COLUMN_COLOR, 0.5);
            g.drawRect(columnHeader.column.metrics.x, columnHeader.column.metrics.y, columnHeader.column.metrics.width, columnHeader.column.metrics.height);
            g.endFill();
            
            //draggingDimColumn.visible = true;
        }
        
        private function hideDraggingDimColumn():void
        {
            draggingDimColumn.visible = false;
        }
        
        private function showDraggingColumn(columnRenderer:ColumnRenderer, columnHeader:ColumnHeader):void
        {
            var columnBitmapData:BitmapData = columnRenderer.bitmapData();
            
            draggingColumn.visible = true;
            draggingColumn.width = columnBitmapData.width;
            draggingColumn.height = columnBitmapData.height + HEADER_HEIGHT;
            
            var g:Graphics = draggingColumn.graphics;
            
            g.clear();
            
            var headerBitmapData:BitmapData = columnHeader.headerBitmapData();
            g.beginBitmapFill(headerBitmapData);
            g.drawRect(0, 0, headerBitmapData.width, headerBitmapData.height); 
            g.endFill();
            
            var matrix:Matrix = new Matrix();
            matrix.ty = HEADER_HEIGHT;
            
            g.beginBitmapFill(columnBitmapData, matrix);
            g.drawRect(0, HEADER_HEIGHT, columnBitmapData.width, columnBitmapData.height); 
            g.endFill();
            
            g.lineStyle(2, DRAGGING_COLUMN_FRAME_COLOR);
            g.drawRect(0, 2, draggingColumn.width, draggingColumn.height);
        }
        
        private function hideDraggingColumn():void
        {
            draggingColumn.visible = false;
        }
        
        private function drawHeaderPlusButton():void
        {
            var g:Graphics = headerPlusButton.graphics;
            
            g.lineStyle(1, 0xBFBFBF); 
            
            var hh:Number = HeaderPanel.HEADER_HEIGHT;
            var ww:Number = HEADER_PLUS_BUTTON_WIDTH;
            
            var colors:Array = [ 0xFFFFFF, 0xFFFFFF, 0xE6E6E6 ];
            
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(ww, hh, Math.PI/2, 0, 0);
            
            var ratios:Array = [ 0, 60, 255 ];
            var alphas:Array = [ 1.0, 1.0, 1.0 ];
            
            g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
            
            g.moveTo(0, 0);
            g.lineTo(ww, 0);
            g.lineTo(ww, hh);
            g.lineTo(0, hh);
            
            g.endFill();
            
            g.lineStyle(0, 0x000000, 0);
            
            var shiftMatrix:Matrix = new Matrix();
            shiftMatrix.tx = 5;
            shiftMatrix.ty = 5;
            
            var iconBitmapAsset:BitmapAsset = new plusIcon() as BitmapAsset;
            g.beginBitmapFill(iconBitmapAsset.bitmapData, shiftMatrix);
            g.drawRect(5, 5, 16, 16);
            g.endFill();
        }
        
        private function drawSelectedHeaderPlusButton():void
        {
            var g:Graphics = headerPlusButton.graphics;
            
            g.lineStyle(1, 0xBFBFBF); 
            
            var hh:Number = HeaderPanel.HEADER_HEIGHT;
            var ww:Number = HEADER_PLUS_BUTTON_WIDTH;
            
            var colors:Array = [ 0xE6E6E6, 0xE6E6E6, 0xBBBBBB ];
            
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(ww, hh, Math.PI/2, 0, 0);
            
            var ratios:Array = [ 0, 60, 255 ];
            var alphas:Array = [ 1.0, 1.0, 1.0 ];
            
            g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
            
            g.moveTo(0, 0);
            g.lineTo(ww, 0);
            g.lineTo(ww, hh);
            g.lineTo(0, hh);
            
            g.endFill();
            
            g.lineStyle(0, 0x000000, 0);
            
            var shiftMatrix:Matrix = new Matrix();
            shiftMatrix.tx = 5;
            shiftMatrix.ty = 5;
            
            var iconBitmapAsset:BitmapAsset = new plusIcon() as BitmapAsset;
            g.beginBitmapFill(iconBitmapAsset.bitmapData, shiftMatrix);
            g.drawRect(5, 5, 16, 16);
            g.endFill();
        }
    }
}