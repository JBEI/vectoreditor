package org.jbei.registry.components
{
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    
    import mx.core.ScrollControlBase;
    import mx.core.ScrollPolicy;
    import mx.events.ResizeEvent;
    import mx.events.ScrollEvent;
    import mx.events.ScrollEventDirection;
    import mx.managers.IFocusManagerComponent;
    
    import org.jbei.registry.components.assemblyTableClasses.ContentHolder;
    import org.jbei.registry.models.AssemblyProvider;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyTable extends ScrollControlBase implements IFocusManagerComponent
    {
        public static const BACKGROUND_COLOR:uint = 0xFFFFFF;
        
        private var contentHolder:ContentHolder;
        
        private var assemblyProviderChanged:Boolean = false;
        private var needsRemeasurement:Boolean = true;
        
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
        
        // Public Methods
        
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
                
                contentHolder.assemblyProvider = assemblyProvider;
                
                needsRemeasurement = true;
                
                invalidateDisplayList();
            }
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                contentHolder.updateMetrics(unscaledWidth, unscaledHeight);
                contentHolder.validateNow();
                
                contentHolder.x = 0;
                contentHolder.y = 0;
                
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
            }
        }
        
        // Private Methods
        private function createContentHolder():void
        {
            if(!contentHolder) {
                contentHolder = new ContentHolder(this);
                contentHolder.includeInLayout = false;
                addChild(contentHolder);
                // Make content fit into ScrollControlBase control
                // Hide invisible portion of the content
                contentHolder.mask = maskShape;
            }
        }
        
        private function adjustScrollBars():void
        {
            setScrollBarProperties(contentHolder.totalWidth, width, contentHolder.totalHeight, height);
            
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
    }
}