package org.jbei.registry.utils
{
    import flash.display.BitmapData;
    import flash.geom.ColorTransform;

    /**
     * @author Zinovii Dmytriv
     */
    public class SystemUtils
    {
        public static function randomColor():uint
        {
            var redBias:Number = 0xFF;
            var greenBias:Number = 0xFF;
            var blueBias:Number = 0xFF;
            
            var ct:ColorTransform = new ColorTransform(1, 1, 1, 1, Math.random() * redBias, Math.random() * greenBias, Math.random() * blueBias);
            
            var color:uint = ct.color;
            
            return color
        }
        
        // TODO: Use Method from VectorCommon.GraphicUtils. Remove this method
        public static function makeBitmapTrasparent(bitmapData:BitmapData, bitmapWidth:int, bitmapHeight:int, transparencyFactor:Number):BitmapData
        {
            var resultBitmapData:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0xFFFFFFFF);
            
            for(var i:int = 0; i < bitmapWidth; i++) {
                for(var j:int = 0; j < bitmapHeight; j++) {
                    var pixelValue:uint = bitmapData.getPixel32(i, j);
                    var alphaValue:uint = pixelValue >> 24 & 0xFF;
                    var rgbValue:uint = pixelValue & 0xffffff;
                    var resultAlpha:uint = alphaValue * (transparencyFactor);
                    
                    resultBitmapData.setPixel32(i, j, resultAlpha << 24 | rgbValue);
                }
            }
            
            return resultBitmapData;
        }
    }
}