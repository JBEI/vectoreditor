package org.jbei.components.sequenceClasses
{
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    import mx.core.UIComponent;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class Caret extends UIComponent
    {
        public static const CARET_COLOR:int = 0x000000;
        public static const CARET_WIDTH:int = 1;
        public static const TIMER_REFRESH_SPEED:int = 500; // in ms
        
        private var contentHolder:ContentHolder;
        private var timer:Timer;
        
        private var _caretHeight:int = 20;
        private var _position:int;
        
        private var needsRemeasurement:Boolean = false;
        
        // Constructor
        public function Caret(contentHolder:ContentHolder)
        {
            super();
            
            this.contentHolder = contentHolder;
            
            initializeTimer();
        }
        
        // Properties
        public function get position():int
        {
            return _position;
        }
        
        public function set position(value:int):void
        {
            _position = value;
            
            needsRemeasurement = true;
            
            delayTimer();
            
            invalidateDisplayList();
        }
        
        // Public Methods
        public function show():void
        {
            visible = true;
            
            activateTimer();
        }
        
        public function hide():void
        {
            visible = false;
            
            deactivateTimer();
        }
        
        public function get caretHeight():int
        {
            return _caretHeight;
        }
        
        public function set caretHeight(value:int):void
        {
            if(_caretHeight != value) {
                _caretHeight = value;
                
                needsRemeasurement = true;
                
                invalidateDisplayList();
            }
        }
        
        // Protected Methods
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(! contentHolder.sequenceProvider) { return; }
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                render();
            }
        }
        
        // Private Methods
        private function onTimerEvent(event:TimerEvent):void
        {
            visible = !visible;
        }
        
        private function render():void
        {
            var caretMetrics:Rectangle = contentHolder.bpMetricsByIndex(_position);
            
            this.x = caretMetrics.x + 1; // +1 to look pretty
            this.y = caretMetrics.y + 2; // +2 to look pretty
            
            measuredWidth = CARET_WIDTH;
            measuredHeight = _caretHeight;
            
            graphics.clear();
            graphics.lineStyle(1, CARET_COLOR);
            graphics.moveTo(0, 0);
            graphics.lineTo(0, measuredHeight);
        }
        
        private function initializeTimer():void
        {
            timer = new Timer(TIMER_REFRESH_SPEED, 0);
            timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
        }
        
        private function activateTimer():void
        {
            timer.reset();
            timer.start();
        }
        
        private function deactivateTimer():void
        {
            timer.stop();
        }
        
        private function delayTimer():void
        {
            show();
            
            timer.delay = TIMER_REFRESH_SPEED;
        }
    }
}