package org.jbei.registry.components
{
    import mx.core.ScrollControlBase;
    import mx.core.ScrollPolicy;
    import mx.events.ResizeEvent;
    
    import org.jbei.registry.components.assemblyRail.ContentHolder;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.AssemblyProviderEvent;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyRail extends ScrollControlBase
    {
        private var _assemblyProvider:AssemblyProvider;
        
        private var needsRemeasurement:Boolean = false;
        private var assemblyProviderChanged:Boolean = false;
        
        private var actualWidth:Number = 0;
        private var actualHeight:Number = 0;
        
        private var contentHolder:ContentHolder;
        
        // Contructor
        public function AssemblyRail()
        {
            super();
            
            horizontalScrollPolicy = ScrollPolicy.AUTO;
            verticalScrollPolicy = ScrollPolicy.OFF;
            
            addEventListener(ResizeEvent.RESIZE, onResize);
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
                contentHolder.x = 0;
                
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
                
                contentHolder.updateMetrics(actualWidth, actualHeight);
            }
        }
        
        // Event Handlers
        private function onResize(event:ResizeEvent):void
        {
            contentHolder.x = 0;
            
            horizontalScrollPosition = 0;
            
            needsRemeasurement = true;
            
            invalidateDisplayList();
        }
        
        private function onAssemblyProviderChanged(event:AssemblyProviderEvent):void
        {
            assemblyProviderChanged = true;
            
            invalidateProperties();
        }
        
        // Private Methods
        public function createContentHolder():void
        {
            if(!contentHolder) {
                contentHolder = new ContentHolder(this);
                contentHolder.includeInLayout = false;
                
                contentHolder.x = 0;
                contentHolder.y = 0;
                
                addChild(contentHolder);
                // Make content fit into ScrollControlBase control
                // Hide invisible portion of the content
                contentHolder.mask = maskShape;
            }
        }
    }
}