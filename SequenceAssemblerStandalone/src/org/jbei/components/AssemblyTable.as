package org.jbei.components
{
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    
    import mx.core.ScrollControlBase;
    import mx.core.ScrollPolicy;
    import mx.events.ResizeEvent;
    import mx.events.ScrollEvent;
    import mx.events.ScrollEventDirection;
    import mx.managers.IFocusManagerComponent;
    
    import org.jbei.components.assemblyTableClasses.CaretEvent;
    import org.jbei.components.assemblyTableClasses.Cell;
    import org.jbei.components.assemblyTableClasses.Column;
    import org.jbei.components.assemblyTableClasses.ColumnHeaderDragEvent;
    import org.jbei.components.assemblyTableClasses.ContentHolder;
    import org.jbei.components.assemblyTableClasses.DataCell;
    import org.jbei.registry.models.AssemblyItem;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.AssemblyProviderEvent;
    
    [Event(name="caretChanged", type="org.jbei.components.assemblyTableClasses.CaretEvent")]
    [Event(name="selectionChanged", type="org.jbei.components.assemblyTableClasses.SelectionEvent")]
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyTable extends ScrollControlBase implements IFocusManagerComponent
    {
        public static const BACKGROUND_COLOR:uint = 0xFFFFFF;
        
        private var contentHolder:ContentHolder;
        
        private var assemblyProviderChanged:Boolean = false;
        private var needsRemeasurement:Boolean = true;
        private var nullifyContentHolderPosition:Boolean = false;
        
        private var actualWidth:Number = 0;
        private var actualHeight:Number = 0;
        
        private var _assemblyProvider:AssemblyProvider;
        
        // Constructor
        public function AssemblyTable()
        {
            super();
            
            verticalScrollPolicy = ScrollPolicy.AUTO;
            horizontalScrollPolicy = ScrollPolicy.AUTO;
            
            addEventListener(ResizeEvent.RESIZE, onResize);
            liveScrolling = true;
            
            addEventListener(ScrollEvent.SCROLL, onScroll);
            
            addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
            addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
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
        }
        
        public function get selectedItems():Vector.<Vector.<Cell>>
        {
            return contentHolder.selectedCells;
        }
        
        // Public Methods
        public function selectAll():void
        {
            contentHolder.selectAll();
        }
        
        public function deleteSelected():void
        {
            contentHolder.deleteSelectedCells();
        }
        
        // Protected Methods
        protected override function createChildren():void
        {
            super.createChildren();
            
            createContentHolder();
        }
        
        protected override function commitProperties():void
        {
            super.commitProperties();
            
            if(assemblyProviderChanged) {
                assemblyProviderChanged = false;
                
                if(_assemblyProvider) {
                    _assemblyProvider.addEventListener(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, onAssemblyProviderChanged);
                }
                
                contentHolder.assemblyProvider = assemblyProvider;
                
                horizontalScrollPosition = 0;
                verticalScrollPosition = 0;
                contentHolder.x = 0;
                contentHolder.y = 0;
                
                needsRemeasurement = true;
                
                invalidateDisplayList();
            }
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                actualWidth = unscaledWidth;
                actualHeight = unscaledHeight;
                
                contentHolder.updateMetrics(unscaledWidth, unscaledHeight);
                contentHolder.validateNow();
                
                if(!nullifyContentHolderPosition) {
                    nullifyContentHolderPosition = true;
                } else {
                    contentHolder.x = 0;
                    contentHolder.y = 0;
                }
                
                adjustScrollBars();
            }
        }
        
        protected override function mouseWheelHandler(event:MouseEvent):void
        {
            if(verticalScrollBar) {
                doScroll(event.delta, verticalScrollBar.lineScrollSize);
            }
        }
        
        // Event Handlers
        private function onResize(event:ResizeEvent):void
        {
            needsRemeasurement = true;
            
            invalidateDisplayList();
            
            contentHolder.updateHeaderPosition(0);
            
            contentHolder.x = 0;
            contentHolder.y = 0;
            
            horizontalScrollPosition = 0;
            verticalScrollPosition = 0;
        }
        
        private function onFocusIn(event:FocusEvent):void
        {
            // trace("Focus in...");
        }
        
        private function onFocusOut(event:FocusEvent):void
        {
            // trace("Focus out...");
        }
        
        private function onScroll(event:ScrollEvent):void
        {
            if(event.direction == ScrollEventDirection.HORIZONTAL) {
                // Adjust content position. Content moves into oposide direction to scroll.
                contentHolder.x = -event.position;
                
                // Adjust scroll position to content position
                if (horizontalScrollPosition != -contentHolder.x) {
                    horizontalScrollPosition = -contentHolder.x;
                }
            } else if(event.direction == ScrollEventDirection.VERTICAL) {
                // Adjust content position. Content moves into oposide direction to scroll.
                contentHolder.y = -event.position;
                
                // Prevent scrolling further then content
                if(contentHolder.y + contentHolder.totalHeight < height) {
                    contentHolder.y += height - (contentHolder.y + contentHolder.totalHeight)
                }
                
                // Adjust scroll position to content position
                if (verticalScrollPosition != -contentHolder.y) {
                    verticalScrollPosition = -contentHolder.y;
                }
                
                contentHolder.updateHeaderPosition(-contentHolder.y);
            }
        }
        
        private function onCaretChanged(event:CaretEvent):void
        {
            if(! event.cell) {
                return;
            }
            
            adjustScrollbarsToActiveCell(event.cell);
        }
        
        private function onHeaderDragging(event:ColumnHeaderDragEvent):void
        {
            adjustScrollbarsToHeaderColumn(event.columnHeader.column);
        }
        
        private function onAssemblyProviderChanged(event:AssemblyProviderEvent):void
        {
            assemblyProviderChanged = true;
            
            invalidateProperties();
        }
        
        // Private Methods
        private function createContentHolder():void
        {
            if(!contentHolder) {
                contentHolder = new ContentHolder(this);
                contentHolder.includeInLayout = false;
                
                contentHolder.addEventListener(CaretEvent.CARET_CHANGED, onCaretChanged);
                contentHolder.addEventListener(ColumnHeaderDragEvent.HEADER_DRAGGING, onHeaderDragging);
                
                addChild(contentHolder);
                // Make content fit into ScrollControlBase control
                // Hide invisible portion of the content
                contentHolder.mask = maskShape;
            }
        }
        
        private function adjustScrollBars():void
        {
            setScrollBarProperties(contentHolder.totalWidth, width, contentHolder.totalHeight, height);
            
            var totalWidth:Number = contentHolder.totalWidth;
            
            // Hack to fix HScrollbar issue
            if(verticalScrollBar && verticalScrollBar.visible) {
                totalWidth += 20;
            }
            
            setScrollBarProperties(totalWidth, width, contentHolder.totalHeight, height);
            
            if(verticalScrollBar) {
                verticalScrollBar.lineScrollSize = 20;
                verticalScrollBar.pageScrollSize = verticalScrollBar.lineScrollSize * 10;
            }
        }
        
        private function doScroll(delta:int, speed:uint = 3):void
        {
            if (verticalScrollBar && verticalScrollBar.visible) {
                var scrollDirection:int = delta <= 0 ? 1 : -1;
                
                var oldPosition:Number = verticalScrollPosition;
                verticalScrollPosition += speed * scrollDirection;
                
                if(verticalScrollPosition < 0) {
                    verticalScrollPosition = 0;
                }
                
                if(verticalScrollPosition > maxVerticalScrollPosition) {
                    verticalScrollPosition = maxVerticalScrollPosition;
                }
                
                var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
                scrollEvent.direction = ScrollEventDirection.VERTICAL;
                scrollEvent.position = verticalScrollPosition;
                scrollEvent.delta = verticalScrollPosition - oldPosition;
                dispatchEvent(scrollEvent);
            }
        }
        
        private function adjustScrollbarsToActiveCell(cell:Cell):void
        {
            if(horizontalScrollBar && horizontalScrollBar.visible) {
                if(contentHolder.x < 0 && -contentHolder.x > cell.column.metrics.x) {
                    contentHolder.x = -cell.column.metrics.x;
                    horizontalScrollPosition = -contentHolder.x;
                    
                    nullifyContentHolderPosition = false;
                } else if(cell.column.metrics.x + cell.metrics.width > actualWidth - contentHolder.x) {
                    contentHolder.x += -((cell.column.metrics.x + cell.metrics.width) - (actualWidth - contentHolder.x) + 20);
                    horizontalScrollPosition = -contentHolder.x;
                    
                    nullifyContentHolderPosition = false;
                }
            }
            
            if(verticalScrollBar && verticalScrollBar.visible) {
                if(contentHolder.y < 0 && -contentHolder.y > cell.metrics.y) {
                    contentHolder.y = -cell.metrics.y;
                    verticalScrollPosition = -contentHolder.y;
                    
                    contentHolder.updateHeaderPosition(-contentHolder.y);
                    nullifyContentHolderPosition = false;
                } else if(cell.metrics.y + cell.metrics.height > actualHeight - contentHolder.y) {
                    contentHolder.y += -((cell.metrics.y + cell.metrics.height) - (actualHeight - contentHolder.y) + 20) - ((horizontalScrollBar && horizontalScrollBar.visible) ? 25 : 0);
                    verticalScrollPosition = -contentHolder.y;
                    
                    contentHolder.updateHeaderPosition(-contentHolder.y);
                    
                    nullifyContentHolderPosition = false;
                }
            }
        }
        
        private function adjustScrollbarsToHeaderColumn(column:Column):void
        {
            if(horizontalScrollBar && horizontalScrollBar.visible) {
                if(contentHolder.x < 0 && -contentHolder.x > column.metrics.x) {
                    contentHolder.x = -column.metrics.x;
                    horizontalScrollPosition = -contentHolder.x;
                } else if(column.metrics.x + column.metrics.width > actualWidth - contentHolder.x) {
                    contentHolder.x += -((column.metrics.x + column.metrics.width) - (actualWidth - contentHolder.x) + 20);
                    horizontalScrollPosition = -contentHolder.x;
                }
            }
        }
    }
}