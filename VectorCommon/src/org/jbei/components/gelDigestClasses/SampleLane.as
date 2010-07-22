package org.jbei.components.gelDigestClasses
{
    import flash.display.Graphics;
    
    import mx.core.UIComponent;
    
    import org.jbei.bio.sequence.dna.DigestionFragment;
    
    public class SampleLane extends UIComponent
    {
        private var _fragments:Vector.<DigestionFragment>;
        private var _ladder:Ladder;
        
        private var actualWidth:Number;
        private var actualHeight:Number;
        
        private var fragmentsChanged:Boolean = true;
        private var ladderChanged:Boolean = true;
        private var needsRemeasurement:Boolean = true;
        
        private var gelBands:Vector.<GelBand>;
        
        // Contructor
        public function SampleLane()
        {
            super();
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
                needsRemeasurement = true;
                
                invalidateDisplayList();
            }
        }
        
        // Public Methods
        public function updateMetrics():void
        {
            needsRemeasurement = true;
            
            invalidateDisplayList();
        }
        
        // Protected Methods
        protected override function commitProperties():void
        {
            super.commitProperties();
            
            if(fragmentsChanged) {
                fragmentsChanged = false;
                
                removeGelBands();
                createGelBands();
            }
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                actualWidth = unscaledWidth;
                actualHeight = unscaledHeight;
                
                redrawBands();
            }
        }
        
        // Private Methods

        private function redrawBands():void
        {
            if(!ladder || ladder.bandSizes.length < 2 || !fragments || fragments.length == 0) {
                return;
            }
            
            updateGelBands();
            
            var ladderHeight:Number = actualHeight * 0.8;
            
            var ladderMin:int = ladder.bandSizes[0];
            var ladderMax:int = ladder.bandSizes[ladder.bandSizes.length - 1];
            
            var totalLogDifference:Number = Math.log(ladderMax / ladderMin);
            
            for(var i:int = 0; i < fragments.length; i++) {
                var fragment:DigestionFragment = fragments[i];
                
                var currentLogDifference:Number = Math.log(fragment.length / ladderMin);
                var normalizedLogDifference:Number = currentLogDifference / totalLogDifference;
                var scalingFactor:Number = - (.1 * Math.sin(2*Math.PI*normalizedLogDifference)); // adding this makes the ladders look nicer

                var bandYPosition:Number = 0.9 * actualHeight  - (scalingFactor + normalizedLogDifference) * ladderHeight;

                if(bandYPosition < 0) {
                    bandYPosition = 2;
                }
                if(bandYPosition > actualHeight) {
                    bandYPosition = actualHeight - 2;
                }
                
                var gelBand:GelBand = gelBands[i];
                
                gelBand.x = 32.5;
                gelBand.y = bandYPosition;
                
                gelBand.height = 2;
                gelBand.width = actualWidth - 65;
            }
        }
        
        private function removeGelBands():void
        {
            if(!gelBands || gelBands.length == 0) {
                return;
            }
            
            for(var i:int = 0; i < gelBands.length; i++) {
                removeChild(gelBands[i]);
            }
            
            gelBands.splice(0, gelBands.length);
        }
        
        private function createGelBands():void
        {
            if(!fragments || fragments.length == 0) {
                return;
            }
            
            if(!gelBands) {
                gelBands = new Vector.<GelBand>();
            }
            
            for(var i:int = 0; i < fragments.length; i++) {
                var gelBand:GelBand = new GelBand(fragments[i]);
                
                gelBands.push(gelBand);
                
                addChild(gelBand);
            }
        }
        
        private function updateGelBands():void
        {
            if(!gelBands || gelBands.length == 0) {
                return;
            }
            
            for(var i:int = 0; i < gelBands.length; i++) {
                var gelBand:GelBand = gelBands[i];
                
                gelBand.updateMetrics();
            }
        }
    }
}