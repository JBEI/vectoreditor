package org.jbei.registry.components.assemblyRail
{
    import flash.display.Graphics;
    
    import mx.core.BitmapAsset;
    import mx.core.UIComponent;

    /**
     * @author Zinovii Dmytriv
     */
    public class ItemWidget extends UIComponent
    {
        public static const ITEM_WIDGET_WIDTH:int = 56;
        public static const ITEM_WIDGET_HEIGHT:int = 56;
        
        private var type:String;
        
        private var needsRemeasurement:Boolean = true;
        
        // Constructor
        public function ItemWidget(type:String)
        {
            this.type = type;
        }
        
        // Protected Methods
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                render();
            }
        }
        
        // Private Methods
        private function render():void
        {
            var g:Graphics = graphics;
            
            g.clear();
            
            var iconClass:Class = IconsLoader.instance.getIcon(type);
            
            if(!iconClass) {
                return;
            }
            
            var iconBitmapAsset:BitmapAsset = new iconClass() as BitmapAsset;
            
            g.lineStyle(1, 0x000000);
            
            g.beginBitmapFill(iconBitmapAsset.bitmapData);
            
            g.drawRect(0, 0, ITEM_WIDGET_WIDTH, ITEM_WIDGET_HEIGHT);
            
            g.endFill();
        }
    }
}