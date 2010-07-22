package org.jbei.components
{
    import flash.display.Graphics;
    
    import mx.controls.Label;
    import mx.core.UIComponent;
    import mx.events.ResizeEvent;
    
    import org.jbei.bio.sequence.dna.DigestionFragment;
    import org.jbei.components.gelDigestClasses.Ladder;
    import org.jbei.components.gelDigestClasses.LadderLane;
    import org.jbei.components.gelDigestClasses.SampleLane;
    
    [Event(name="bandSelected", type="org.jbei.components.gelDigestClasses.BandEvent")]
    
    public class GelDigestComponent extends UIComponent
    {
        public static const BACKGROUND_COLOR:uint = 0x000000;
        public static const TEXT_COLOR:uint = 0xFFFFFF;
        
        private var numFragmentsLabel:Label;
        
        private var ladderLane:LadderLane;
        private var sampleLane:SampleLane;
        
        private var _fragments:Vector.<DigestionFragment>;
        private var _ladder:Ladder;
        
        private var needsMeasurement:Boolean;
        
        private var actualWidth:Number;
        private var actualHeight:Number;
        
        private var ladderChanged:Boolean = true;
        private var fragmentsChanged:Boolean = true;
        
        // Constructor
        public function GelDigestComponent()
        {
            super();
            
            addEventListener(ResizeEvent.RESIZE, onResize);
        }
        
        // Properties
        public function get fragments():Vector.<DigestionFragment>
        {
            return _fragments;
        }
        
        public function set fragments(value:Vector.<DigestionFragment>):void
        {
            if(_fragments != value) {
                _fragments = value;
                
                fragmentsChanged = true;
                
                invalidateProperties();
            }
        }
        
        public function get ladder():Ladder
        {
            return _ladder;
        }
        
        public function set ladder(value:Ladder):void
        {
            if(_ladder != value) {
                _ladder = value;
                
                ladderChanged = true;
                
                invalidateProperties();
            }
        }
        
        // Protected Methods
        protected override function measure():void
        {
            super.measure();
            
            measuredHeight = 400;
            measuredWidth = 250;
        }
        
        protected override function createChildren():void
        {
            super.createChildren();
            
            createNumFragmentsLabel();
            
            createLadderLane();
            createSampleLane();
        }
        
        protected override function commitProperties():void
        {
            super.commitProperties();
            
            if(ladderChanged) {
                ladderChanged = false;
                
                needsMeasurement = true;
                
                ladderLane.ladder = _ladder;
                sampleLane.ladder = _ladder;
                
               invalidateDisplayList();
            }
            
            if(fragmentsChanged) {
                fragmentsChanged = false;
                
                needsMeasurement = true;
                
                sampleLane.fragments = _fragments;
                
                if (!_fragments || _fragments.length == 0) {
                    numFragmentsLabel.text = "No digestion";
                } else if (_fragments.length == 1) {
                    numFragmentsLabel.text = "1 fragment";
                } else {
                    numFragmentsLabel.text = _fragments.length + " fragments";
                }
                
                invalidateDisplayList();
            }
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if (needsMeasurement) {
                needsMeasurement = false;
                
                ladderLane.updateMetrics();
                sampleLane.updateMetrics();
                
                actualWidth = unscaledWidth;
                actualHeight = unscaledHeight;
                
                adjustLabelPosition();
                adjustLanePosition();
                
                drawBackgroud();
            }
        }
        
        private function onResize(event:ResizeEvent):void
        {
            needsMeasurement = true;
            
            invalidateDisplayList();
        }
        
        private function createNumFragmentsLabel():void
        {
            if(!numFragmentsLabel) {
                numFragmentsLabel = new Label();
                numFragmentsLabel.height = 20;
                numFragmentsLabel.text = "No digestion";
                
                numFragmentsLabel.setStyle("color", TEXT_COLOR);
                numFragmentsLabel.setStyle("textAlign", "right");

                addChild(numFragmentsLabel);
            }
        }
        
        private function createLadderLane():void
        {
            if(!ladderLane) {
                ladderLane = new LadderLane();
                
                addChild(ladderLane);
            }
        }
        
        private function createSampleLane():void
        {
            if(!sampleLane) {
                sampleLane = new SampleLane();
                
                addChild(sampleLane);
            }
        }
        
        private function drawBackgroud():void
        {
            var g:Graphics = graphics;
            
            g.clear();
            g.beginFill(BACKGROUND_COLOR);
            g.drawRect(0, 0, actualWidth, actualHeight);
            g.endFill();
        }
        
        private function adjustLabelPosition():void
        {
            numFragmentsLabel.width = actualWidth - 20;
            
            numFragmentsLabel.x = 10;
            numFragmentsLabel.y = 10;
        }
        
        private function adjustLanePosition():void
        {
            ladderLane.width = actualWidth / 2 - 15;
            sampleLane.width = actualWidth / 2 - 15;
            
            ladderLane.height = actualHeight - 50;
            sampleLane.height = actualHeight - 50;
            
            ladderLane.x = 10;
            ladderLane.y = 40;
            
            sampleLane.x = actualWidth / 2 + 5;
            sampleLane.y = 40;
        }
    }
}