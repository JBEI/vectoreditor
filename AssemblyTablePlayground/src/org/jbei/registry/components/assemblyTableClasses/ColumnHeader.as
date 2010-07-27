package org.jbei.registry.components.assemblyTableClasses
{
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    
    import mx.controls.Alert;
    import mx.controls.Label;
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.events.CloseEvent;
    import mx.events.FlexMouseEvent;
    import mx.events.SandboxMouseEvent;
    import mx.managers.ISystemManager;
    import mx.managers.PopUpManager;
    
    import org.jbei.registry.models.Bin;
    import org.jbei.registry.models.FeatureTypeManager;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ColumnHeader extends UIComponent
    {
        private static const DRAGGING_THRESHOLD:Number = 5;
        
        private var label:Label;
        private var contentHolder:ContentHolder;
        private var dropDownMenuButton:UIComponent;
        private var dropDownList:ColumnHeaderDropDownList;
        
        private var _column:Column;
        
        private var needsRemeasurement:Boolean = true;
        private var actualWidth:Number = 0;
        private var actualHeight:Number = 0;
        
        private var mouseIsDown:Boolean = false;
        private var dragging:Boolean = false;
        private var clickPoint:Point;
        
        // Contructor
        public function ColumnHeader(column:Column, contentHolder:ContentHolder)
        {
            super();
            
            _column = column;
            
            this.contentHolder = contentHolder;
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
        
        // Properties
        public function get column():Column
        {
            return _column;
        }
        
        // Public Methods
        public function updateMetrics(width:Number, height:Number):void
        {
            needsRemeasurement = true;
            
            invalidateDisplayList();
            
            actualWidth = width;
            actualHeight = height;
        }
        
        /*
        * @private
        */
        public function headerBitmapData():BitmapData
        {
            var bitmapData:BitmapData = new BitmapData(actualWidth, actualHeight);
            
            bitmapData.draw(this, new Matrix(), null, null, new Rectangle(0, 0, actualWidth, actualHeight));
            
            return makeBitmapTrasparent(bitmapData, actualWidth, actualHeight, 0.7)
        }
        
        /*
        * @private
        */
        public function changeColumnType(newType:String):void
        {
            contentHolder.assemblyProvider.changeBinType(contentHolder.assemblyProvider.bins[column.index], FeatureTypeManager.instance.getTypeByValue(newType));
        }
        
        // Protected Methods
        protected override function createChildren():void
        {
            super.createChildren();
            
            createContextMenu();
            
            createLabel();
            
            createDropDownMenuButton();
            
            createDropDownList();
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                label.width = column.metrics.width;
                
                drawBackground();
                drawLabel();
                
                dropDownMenuButton.x = column.metrics.width - 20;
            }
        }
        
        // Event Handlers
        private function onMouseDown(event:MouseEvent):void
        {
            if(event.target == dropDownMenuButton) {
                return;
            }
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            
            mouseIsDown = true;
            
            clickPoint = globalToLocal(new Point(event.stageX, event.stageY));
            
            drawSelectedBackground();
            drawDropDownMenuSelectedBackground();
            drawLabel();
        }
        
        private function onMouseMove(event:MouseEvent):void
        {
            var currentPoint:Point = globalToLocal(new Point(event.stageX, event.stageY));
            
            if(!dragging) {
                var distance:Number = Point.distance(clickPoint, currentPoint);
                
                if(distance > DRAGGING_THRESHOLD) {
                    dispatchEvent(new ColumnHeaderDragEvent(ColumnHeaderDragEvent.START_HEADER_DRAGGING, this));
                    
                    dragging = true;
                }
            }
        }
        
        private function onMouseUp(event:MouseEvent):void
        {
            if(event.target == dropDownMenuButton) {
                return;
            }
            
            if(mouseIsDown && !dragging) {
                contentHolder.select(column.cells);
            }
            
            if(mouseIsDown && dragging) {
                dispatchEvent(new ColumnHeaderDragEvent(ColumnHeaderDragEvent.STOP_HEADER_DRAGGING, this));
            }
            
            mouseIsDown = false;
            dragging = false;
            
            drawBackground();
            drawDropDownMenuBackground();
            drawLabel();
            
            if(stage) {
                stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            }
        }
        
        private function onDropDownMenuButtonClick(event:MouseEvent):void
        {
            openDropDownList();
        }
        
        private function onDropDownMenuButtonRollOver(event:MouseEvent):void
        {
            drawDropDownMenuSelectedBackground();
        }
        
        private function onDropDownMenuButtonRollOut(event:MouseEvent):void
        {
            drawDropDownMenuBackground();
        }
        
        private function onMouseDownOutside(event:FlexMouseEvent):void
        {
            closeDropDownList();
        }
        
        private function onMouseWheelOutside(event:FlexMouseEvent):void
        {
            closeDropDownList();
        }
        
        private function onSandboxMouseDownOutside(event:FlexMouseEvent):void
        {
            closeDropDownList();
        }
        
        private function onSandboxMouseWheelOutside(event:FlexMouseEvent):void
        {
            closeDropDownList();
        }
        
        private function onStageResize(event:Event):void 
        {
            closeDropDownList();
        }
        
        private function onContextMenuSelect(event:ContextMenuEvent):void
        {
            contentHolder.select(column.cells);
        }
        
        private function onInsertOneLeftContextMenuItemClick(event:ContextMenuEvent):void
        {
            var newBin:Bin = new Bin(FeatureTypeManager.instance.getTypeByValue("general"));
            
            contentHolder.assemblyProvider.insertBin(newBin, column.index == 0 ? 0 : column.index);
        }
        
        private function onInsertOneRightContextMenuItemClick(event:ContextMenuEvent):void
        {
            var newBin:Bin = new Bin(FeatureTypeManager.instance.getTypeByValue("general"));
            
            contentHolder.assemblyProvider.insertBin(newBin, column.index + 1);
        }
        
        private function onDeleteColumnContextMenuItemClick(event:ContextMenuEvent):void
        {
            Alert.show("Are you sure you want to delete column?", "Delete column", Alert.YES | Alert.NO, contentHolder.parent as Sprite, onAlertDeleteColumnClose, null, Alert.NO);
        }
        
        private function onAlertDeleteColumnClose(event:CloseEvent):void
        {
            if(event.detail == Alert.YES) {
                contentHolder.assemblyProvider.removeBin(contentHolder.assemblyProvider.bins[column.index]);
            }
        }
        
        // Private Methods
        private function createLabel():void
        {
            if(!label) {
                label = new Label();
                label.x = 4;
                label.y = 4;
                label.height = 23;
                label.includeInLayout = false;
                label.visible = false;
                
                label.text = column.title;
                
                addChild(label);
            }
        }
        
        private function createDropDownMenuButton():void
        {
            if(!dropDownMenuButton) {
                dropDownMenuButton = new UIComponent();
                
                dropDownMenuButton.width = 20;
                dropDownMenuButton.height = HeaderPanel.HEADER_HEIGHT;
                dropDownMenuButton.y = 0;
                dropDownMenuButton.includeInLayout = false;
                dropDownMenuButton.visible = true;
                
                dropDownMenuButton.addEventListener(MouseEvent.CLICK, onDropDownMenuButtonClick);
                dropDownMenuButton.addEventListener(MouseEvent.ROLL_OVER, onDropDownMenuButtonRollOver);
                dropDownMenuButton.addEventListener(MouseEvent.ROLL_OUT, onDropDownMenuButtonRollOut);
                
                drawDropDownMenuBackground();
                
                addChild(dropDownMenuButton);
            }
        }
        
        private function createDropDownList():void
        {
            if(!dropDownList) {
                dropDownList = new ColumnHeaderDropDownList(this);
                
                dropDownList.visible = false;
                dropDownList.includeInLayout = false;
                dropDownList.x = column.metrics.width - ColumnHeaderDropDownList.DEFAULT_LIST_WIDTH;
                dropDownList.y = HeaderPanel.HEADER_HEIGHT;
                
                dropDownList.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onMouseDownOutside);
                dropDownList.addEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE, onMouseWheelOutside);
                dropDownList.addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, onSandboxMouseDownOutside);
                dropDownList.addEventListener(SandboxMouseEvent.MOUSE_WHEEL_SOMEWHERE, onSandboxMouseWheelOutside);
                
                //weak reference to stage
                var sm:ISystemManager = systemManager.topLevelSystemManager;
                sm.getSandboxRoot().addEventListener(Event.RESIZE, onStageResize, false, 0, true);
                
                dropDownList.owner = this;
            }
        }
        
        private function createContextMenu():void
        {
            if(!contextMenu) {
                contextMenu = new ContextMenu();
                
                contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onContextMenuSelect);
                
                contextMenu.hideBuiltInItems();
                
                contextMenu.customItems = new Array();
                
                contextMenu.clipboardMenu = true;
                contextMenu.clipboardItems.copy = true;
                contextMenu.clipboardItems.paste = true;
                contextMenu.clipboardItems.cut = true;
                contextMenu.clipboardItems.clear = false;
                contextMenu.clipboardItems.selectAll = true;
                
                var insertOneLeftContextMenuItem:ContextMenuItem = new ContextMenuItem("Insert 1 left");
                insertOneLeftContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onInsertOneLeftContextMenuItemClick);
                contextMenu.customItems.push(insertOneLeftContextMenuItem);
                
                var insertOneRightContextMenuItem:ContextMenuItem = new ContextMenuItem("Insert 1 right");
                insertOneRightContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onInsertOneRightContextMenuItemClick);
                contextMenu.customItems.push(insertOneRightContextMenuItem);
                
                var deleteColumnContextMenuItem:ContextMenuItem = new ContextMenuItem("Delete column");
                deleteColumnContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onDeleteColumnContextMenuItemClick);
                contextMenu.customItems.push(deleteColumnContextMenuItem);
            }
        }
        
        private function drawLabel():void
        {
            label.validateNow();
            
            var bitmapData:BitmapData = new BitmapData(label.width, label.height, true, 0x00FFFFFF);
            
            var matrix:Matrix = new Matrix();
            matrix.tx = 4;
            matrix.ty = 4;
            
            bitmapData.draw(label, matrix, null, null, new Rectangle(0, 0, label.width, label.height));
            
            var g:Graphics = graphics;
            g.lineStyle(0, 0xffffff, 0);
            g.beginBitmapFill(bitmapData);
            g.drawRect(0, 0, label.width, label.height);
            g.endFill();
        }
        
        private function drawBackground():void
        {
            var g:Graphics = graphics;
            g.clear();
            
            var hh:Number = actualHeight;
            var ww:Number = actualWidth;
            
            g.lineStyle(1, 0xBFBFBF);
            g.moveTo(0, hh);
            g.lineTo(ww, hh);
            
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
            
            g.lineStyle(1, 0xBFBFBF);
            g.moveTo(0, 0);
            g.lineTo(0, hh);
            
            g.moveTo(ww, 0);
            g.lineTo(ww, hh);
            
            g.lineStyle(0, 0x000000, 100);
        }
        
        private function drawSelectedBackground():void
        {
            var g:Graphics = graphics;
            g.clear();
            
            var hh:Number = actualHeight;
            var ww:Number = actualWidth;
            
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
            
            g.lineStyle(1, 0xBFBFBF);
            g.moveTo(0, 0);
            g.lineTo(0, hh);
            
            g.moveTo(ww, 0);
            g.lineTo(ww, hh);
            
            g.lineStyle(0, 0x000000, 100);
        }
        
        private function drawDropDownMenuBackground():void
        {
            var g:Graphics = dropDownMenuButton.graphics;
            
            g.clear();
            g.lineStyle(1, 0xBFBFBF);
            g.moveTo(0, 0);
            g.lineTo(0, HeaderPanel.HEADER_HEIGHT);
            
            var hh:Number = HeaderPanel.HEADER_HEIGHT;
            var ww:Number = 20;
            
            var colors:Array = [ 0xFFFFFF, 0xFFFFFF, 0xE6E6E6 ];
            //var colors:Array = [ 0xE6E6E6, 0xE6E6E6, 0xBBBBBB ];
            
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
            
            g.lineStyle(1, 0x666666);
            
            g.beginFill(0x666666);
            g.moveTo(8, 11);
            g.lineTo(14, 11);
            g.lineTo(11, 15);
            g.lineTo(8, 11);
            g.endFill();
        }
        
        private function drawDropDownMenuSelectedBackground():void
        {
            var g:Graphics = dropDownMenuButton.graphics;
            
            g.clear();
            g.lineStyle(1, 0xBFBFBF);
            g.moveTo(0, 0);
            g.lineTo(0, HeaderPanel.HEADER_HEIGHT);
            
            var hh:Number = HeaderPanel.HEADER_HEIGHT;
            var ww:Number = 20;
            
            //var colors:Array = [ 0xFFFFFF, 0xFFFFFF, 0xE6E6E6 ];
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
            
            g.lineStyle(1, 0x666666);
            
            g.beginFill(0x666666);
            g.moveTo(8, 11);
            g.lineTo(14, 11);
            g.lineTo(11, 15);
            g.lineTo(8, 11);
            g.endFill();
        }
        
        private function openDropDownList():void
        {
            if(dropDownList.parent == null) {
                PopUpManager.addPopUp(dropDownList, this, false);
                
                dropDownList.owner = this;
            } else {
                PopUpManager.bringToFront(dropDownList);
            }
            
            var point:Point = localToGlobal(new Point(column.metrics.width - ColumnHeaderDropDownList.DEFAULT_LIST_WIDTH, HeaderPanel.HEADER_HEIGHT));
            
            dropDownList.x = point.x;
            dropDownList.y = point.y;
            
            dropDownList.open(column.title.toLowerCase()); // TODO: fix this
        }
        
        private function closeDropDownList():void
        {
            if(dropDownList.isOpen) {
                dropDownList.close();
            }
        }
        
        // TODO: Use Method from VectorCommon.GraphicUtils. Remove this method
        private function makeBitmapTrasparent(bitmapData:BitmapData, bitmapWidth:int, bitmapHeight:int, transparencyFactor:Number):BitmapData
        {
            var resultBitmapData:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0xFFFFFFFF);
            
            for(var i:int = 0; i < bitmapWidth; i++) {
                for(var j:int = 0; j < bitmapHeight; j++) {
                    var pixelValue:uint = bitmapData.getPixel32(i, j);
                    var alphaValue:uint = pixelValue >> 24 & 0xFF;
                    var rgbValue:uint = pixelValue & 0xffffff;
                    var resultAlpha:uint = alphaValue * (transparencyFactor);
                    
                    resultBitmapData.setPixel32(i, j, resultAlpha << 24 | rgbValue);
                }
            }
            
            return resultBitmapData;
        }
    }
}