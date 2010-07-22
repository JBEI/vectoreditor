package org.jbei.components.gelDigestClasses
{
    import flash.display.Graphics;
    
    import mx.controls.Label;
    import mx.core.UIComponent;
    
    public class LadderLane extends UIComponent
    {
        public static const BAND_COLOR:uint = 0xFFFFFF;
        public static const CONNECTOR_COLOR:uint = 0x999999;

        private var _ladder:Ladder;
        
        private var bandYPositions:Vector.<Number>;
        private var bandSizeLabels:Vector.<Label>;
        private var bandSizeLabelYPositions:Vector.<Number>;
        
        private var actualWidth:Number;
        private var actualHeight:Number;
        
        private var ladderChanged:Boolean = true;
        private var needsRemeasurement:Boolean = true;
        
        // Contructor
        public function LadderLane()
        {
            super();
        }
        
        // Properties
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
                invalidateProperties();
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
            
            if(ladderChanged) {
                ladderChanged = false;
                
                removeBandSizeLabels();
                createBandSizeLabels();
            }
        }
        
        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
                       
            if(needsRemeasurement) {
                needsRemeasurement = false;
                
                actualWidth = unscaledWidth;
                actualHeight = unscaledHeight;
                
                var g:Graphics = graphics;
                g.clear();
                
                redrawBands();
                redrawBandSizeLabels();
                redrawConnectors();
            }
        }
        
        // Private Methods
        private function redrawBands():void
        {
            var g:Graphics = graphics;
            
            if(!_ladder || _ladder.bandSizes.length < 2) {
                return;
            }
            
            g.lineStyle(2, BAND_COLOR);
            
            var ladderHeight:Number = actualHeight * 0.8;
            
            var ladderMin:int = _ladder.bandSizes[0];
            var ladderMax:int = _ladder.bandSizes[_ladder.bandSizes.length - 1];
            
            var totalLogDifference:Number = Math.log(ladderMax / ladderMin);
            
            if(!bandYPositions) {
                bandYPositions = new Vector.<Number>();
            } else {
                bandYPositions.splice(0, bandYPositions.length);
            }
            
            for(var i:int = 0; i < _ladder.bandSizes.length; i++) {
                var bandSize:int = _ladder.bandSizes[i];
                
                var currentLogDifference:Number = Math.log(_ladder.bandSizes[i] / ladderMin);
                var normalizedLogDifference:Number = currentLogDifference / totalLogDifference;
                var scalingFactor:Number = - (.1 * Math.sin(2*Math.PI*normalizedLogDifference)); // adding this makes the ladders look nicer
                
                bandYPositions.push(0.9 * actualHeight - (scalingFactor + normalizedLogDifference) * ladderHeight);
                
                g.moveTo(55, bandYPositions[i]);
                g.lineTo(actualWidth - 10, bandYPositions[i]);
            }
        }
        
        private function redrawBandSizeLabels():void
        {
            if(!bandSizeLabels || bandSizeLabels.length == 0) {
                return;
            }
            
            if(!bandSizeLabelYPositions) {
                bandSizeLabelYPositions = new Vector.<Number>();
            } else {
                bandSizeLabelYPositions.splice(0, bandSizeLabelYPositions.length);
            }
            
            for(var i:int = 0; i < bandSizeLabels.length; i++) {
                var label:Label = bandSizeLabels[i];
                                
                label.setStyle("color", BAND_COLOR);
                label.setStyle("textAlign", "right");
                
                label.text = _ladder.bandSizes[i].toString();
                
                label.validateNow();
                
                label.width = 40;
                label.height = label.textHeight;
                
                label.x = 5;
                
                var defaultLabelYPosition:Number = bandYPositions[i] - 10;
                if(i == 0 || defaultLabelYPosition < bandSizeLabelYPositions[i-1] - label.height) {
                    label.y = defaultLabelYPosition;
                    bandSizeLabelYPositions[i] = defaultLabelYPosition;
                } else {
                    label.y = bandSizeLabelYPositions[i-1] - label.height; 
                    bandSizeLabelYPositions[i] = bandSizeLabelYPositions[i-1] - label.height;
                }
            }
        }
        
        private function removeBandSizeLabels():void
        {
            if(!bandSizeLabels || bandSizeLabels.length == 0) {
                return;
            }
            
            for(var i:int = 0; i < bandSizeLabels.length; i++) {
                removeChild(bandSizeLabels[i]);
            }
            
            bandSizeLabels.splice(0, bandSizeLabels.length);
        }
        
        private function createBandSizeLabels():void
        {
            if(!_ladder || _ladder.bandSizes.length < 2) {
                return;
            }
            
            if(!bandSizeLabels) {
                bandSizeLabels = new Vector.<Label>;
            }
            
            for(var j:int = 0; j < _ladder.bandSizes.length; j++) {
                var label:Label = new Label();
                
                bandSizeLabels.push(label);
                
                addChild(label);
            }
        }
        
        private function redrawConnectors():void
        {
            var g:Graphics = graphics;
            
            if(!_ladder || _ladder.bandSizes.length < 2) {
                return;
            }
            
            g.lineStyle(1, CONNECTOR_COLOR);
            
            if(!bandSizeLabels || bandSizeLabels.length == 0) {
                return;
            }
            
            for(var i:int = 0; i < bandSizeLabels.length; i++) {
                g.moveTo(45, bandSizeLabelYPositions[i] + 10);
                g.lineTo(54, bandYPositions[i]);
            }
        }
    }
}