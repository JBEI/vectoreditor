package org.jbei.registry.components.assemblyRail
{
    import flash.display.Graphics;
    
    import mx.core.UIComponent;
    
    import org.jbei.registry.components.AssemblyRail;
    import org.jbei.registry.models.AssemblyProvider;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ContentHolder extends UIComponent
    {
        public static const BACKGROUND_COLOR:uint = 0xFFFFFF;
        public static const WIDGETS_GAP:int = 5;
        public static const SIDE_GAP:int = 5;
        
        private var assemblyRail:AssemblyRail;
        
        private var widgets:Vector.<ItemWidget> = new Vector.<ItemWidget>();
        
        private var assemblyRailWidth:Number;
        private var assemblyRailHeight:Number;
        private var needsRemeasurement:Boolean = false;
        private var assemblyProviderChanged:Boolean = false;
        
        private var _assemblyProvider:AssemblyProvider;
        private var _totalHeight:int = 0;
        private var _totalWidth:int = 0;
        
        // Contructor
        public function ContentHolder(assemblyRail:AssemblyRail)
        {
            super();
            
            this.assemblyRail = assemblyRail;
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
        
        public function get totalHeight():Number
        {
            return _totalHeight;
        }
        
        public function get totalWidth():Number
        {
            return _totalWidth;
        }
        
        // Public Methods
        public function updateMetrics(assemblyRailWidth:Number, assemblyRailHeight:Number):void
        {
            this.assemblyRailWidth = assemblyRailWidth;
            this.assemblyRailHeight = assemblyRailHeight;
            
            needsRemeasurement = true;
            
            invalidateDisplayList();
        }
        
        // Protected Methods
        protected override function commitProperties():void
        {
            super.commitProperties();
            
            if(assemblyProviderChanged) {
                assemblyProviderChanged = false;
                
                needsRemeasurement = true;
                
                removeWidgets();
                createWidgets();
            }
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                _totalWidth = assemblyRailWidth;
                _totalHeight = assemblyRailHeight;
                
                if(widgets && widgets.length > 0) {
                    var currentWidth:Number = ItemWidget.ITEM_WIDGET_WIDTH * widgets.length + WIDGETS_GAP * (widgets.length - 1) + 2 * SIDE_GAP;
                    
                    if(currentWidth > _totalWidth) {
                        _totalWidth = currentWidth;
                    }
                }
                
                drawBackground();
                
                updateWidgets();
            }
        }
        
        // Private Methods
        private function createWidgets():void
        {
            if(!_assemblyProvider || _assemblyProvider.bins.length == 0) {
                return;
            }
            
            if(!widgets) {
                widgets = new Vector.<ItemWidget>();
            }
            
            for(var i:int = 0; i < _assemblyProvider.bins.length; i++) {
                var newWidget:ItemWidget = new ItemWidget(_assemblyProvider.bins[i].featureType.key);
                
                widgets.push(newWidget);
                
                addChild(newWidget);
            }
        }
        
        private function removeWidgets():void
        {
            if(!widgets || widgets.length == 0) {
                return;
            }
            
            for(var i:int = 0; i < widgets.length; i++) {
                removeChild(widgets[i]);
            }
            
            widgets.splice(0, widgets.length);
        }
        
        private function updateWidgets():void
        {
            if(!widgets || widgets.length == 0) {
                return;
            }
            
            for(var i:int = 0; i < widgets.length; i++) {
                widgets[i].x = SIDE_GAP + (_totalWidth - 2 * SIDE_GAP - (ItemWidget.ITEM_WIDGET_WIDTH * widgets.length + WIDGETS_GAP * (widgets.length - 1))) / 2 + (ItemWidget.ITEM_WIDGET_WIDTH + WIDGETS_GAP) * i;
                
                if(assemblyRailWidth < _totalWidth) { // if horizontal scroll exist then move widgets 20 pixels ups 
                    widgets[i].y = (_totalHeight - 20 - ItemWidget.ITEM_WIDGET_HEIGHT) / 2; // -20 for scroll
                } else {
                    widgets[i].y = (_totalHeight - ItemWidget.ITEM_WIDGET_HEIGHT) / 2;
                }
            }
        }
        
        private function drawBackground():void
        {
            var g:Graphics = graphics;
            
            g.clear();
            
            g.beginFill(BACKGROUND_COLOR);
            g.drawRect(0, 0, _totalWidth, _totalHeight);
            g.endFill();
        }
    }
}