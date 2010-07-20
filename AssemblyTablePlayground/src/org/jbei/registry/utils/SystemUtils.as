package org.jbei.registry.utils
{
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
    }
}