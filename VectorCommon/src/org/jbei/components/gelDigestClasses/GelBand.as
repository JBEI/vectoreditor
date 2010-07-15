package org.jbei.components.gelDigestClasses
{
    import flash.display.Graphics;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    import mx.controls.ToolTip;
    import mx.core.UIComponent;
    import mx.managers.ToolTipManager;
    
    import org.jbei.bio.sequence.dna.DigestionFragment;
    
    public class GelBand extends UIComponent
    {
        public static const BAND_COLOR:uint = 0x000000;
        
        private var tip:ToolTip;
        
        private var _digestionFragment:DigestionFragment;
        
        private var needsRemeasurement:Boolean = true;
        
        // Constructor
        public function GelBand(digestionFragment:DigestionFragment)
        {
            super();
            
            _digestionFragment = digestionFragment;
            
            addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
            addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
            addEventListener(MouseEvent.CLICK, onMouseClick);
        }
        
        // Properties
        public function get digestionFragment():DigestionFragment
        {
            return _digestionFragment;
        }
        
        // Public Methods
        public function updateMetrics():void
        {
            needsRemeasurement = true;
            
            invalidateDisplayList();
        }
        
        // Protected Methods
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                var g:Graphics = graphics;
                
                g.clear();
                g.lineStyle(2, BAND_COLOR);
                g.moveTo(0, 0);
                g.lineTo(unscaledWidth, 0);
            }
        }
        
        // Event Handlers
        private function onMouseRollOver(event:MouseEvent):void
        {
            var tipPoint:Point = localToGlobal(new Point(event.localX + 20, event.localY));
            
            tip = ToolTipManager.createToolTip(_digestionFragment.length + "bp, " + _digestionFragment.start + " (" + (_digestionFragment.startRE ? _digestionFragment.startRE.name : "-") + ") .. " + _digestionFragment.end + " (" + (_digestionFragment.endRE ? _digestionFragment.endRE.name : "-") + ")", tipPoint.x, tipPoint.y) as ToolTip;
        }
        
        private function onMouseRollOut(event:MouseEvent):void
        {
            ToolTipManager.destroyToolTip(tip);
        }
        
        private function onMouseClick(event:MouseEvent):void
        {
            dispatchEvent(new BandEvent(BandEvent.BAND_SELECTED, _digestionFragment));
        }
    }
}