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
        private var assemblyRail:AssemblyRail;
        
        private var widgets:Vector.<ItemWidget> = new Vector.<ItemWidget>();
        
        private var assemblyRailWidth:Number;
        private var assemblyRailHeight:Number;
        private var needsRemeasurement:Boolean = false;
        private var assemblyProviderChanged:Boolean = false;
        
        private var _assemblyProvider:AssemblyProvider;
        
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
                widgets[i].x = (assemblyRailWidth - (ItemWidget.ITEM_WIDGET_WIDTH + 5) * widgets.length) / 2 + (ItemWidget.ITEM_WIDGET_WIDTH + 5) * i;
                widgets[i].y = (assemblyRailHeight - ItemWidget.ITEM_WIDGET_HEIGHT) / 2;
            }
        }
        
        private function drawBackground():void
        {
            var g:Graphics = graphics;
            
            g.clear();
            
            g.beginFill(0xFFFFFF);
            g.drawRect(0, 0, assemblyRailWidth, assemblyRailHeight);
            g.endFill();
        }
    }
}