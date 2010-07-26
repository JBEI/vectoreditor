package org.jbei.components.common
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Point;
	
    /**
     * @author Zinovii Dmytriv
     */
	public final class GraphicUtils
	{
		public static function drawDashedLine(graphics:Graphics, fromPoint:Point, toPoint:Point, length:int = 5, gap:int = 5):void
		{
            var segmentLength:int = length + gap;
            
            var deltaX:int = toPoint.x - fromPoint.x;
            var deltaY:int = toPoint.y - fromPoint.y;
            
            var delta:Number = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
            
            var numSegments:Number = Math.floor(Math.abs(delta / segmentLength));
            
            var radians:Number = Math.atan2(deltaY, deltaX);
            
            var cx:int = fromPoint.x;
            var cy:int = fromPoint.y;
            
            deltaX = Math.cos(radians) * segmentLength;
            deltaY = Math.sin(radians) * segmentLength;
            
            for (var i:int = 0; i < numSegments; i++) {
                graphics.moveTo(cx, cy);
                graphics.lineTo(cx + Math.cos(radians)*length, cy + Math.sin(radians)*length);
                
                cx += deltaX;
                cy += deltaY;
            }
            
            graphics.moveTo(cx, cy);
            delta = Math.sqrt((toPoint.x - cx)*(toPoint.x - cx) + (toPoint.y - cy)*(toPoint.y - cy));
            
            if(delta > length){
				graphics.lineTo(cx + Math.cos(radians) * length, cy + Math.sin(radians) * length);
            } else if(delta > 0) {
				graphics.lineTo(cx + Math.cos(radians) * delta, cy + Math.sin(radians) * delta);
            }
            
            graphics.moveTo(toPoint.x, toPoint.y);
		}
		
		public static function drawDashedRectangle(graphics:Graphics, fromPoint:Point, toPoint:Point, length:int = 5, gap:int = 5):void
		{
			GraphicUtils.drawDashedLine(graphics, fromPoint, new Point(toPoint.x, fromPoint.y), gap);
			GraphicUtils.drawDashedLine(graphics, new Point(toPoint.x, fromPoint.y), new Point(toPoint.x, toPoint.y), gap);
			GraphicUtils.drawDashedLine(graphics, new Point(toPoint.x, toPoint.y), new Point(fromPoint.x, toPoint.y), gap);
			GraphicUtils.drawDashedLine(graphics, new Point(fromPoint.x, toPoint.y), fromPoint, gap);
		}
		
		/**
		 * Draw an Arc
		 * @param graphics
		 * @param center
		 * @param radius
		 * @param angle1 - start angle from the vertical
		 * @param angle2 - end angle from the vertical
		 */
		public static function drawArc(graphics:Graphics, center:Point, radius:Number, angle1:Number, angle2:Number, reverseRendering:Boolean = false):void 
		{
			var alpha:Number = (angle2 < angle1) ? (2 * Math.PI - angle1 + angle2) : (angle2 - angle1); // smallest angle beetwen angle1 and angle2
			var parts:Number = 1 + Math.floor(Math.abs(alpha)/(Math.PI/4));
			var gamma:Number = alpha / parts;
			
            var controlPoint:Point = new Point();
            var endPoint:Point = new Point();
            
            if(!reverseRendering) {
	            var span:Number = angle1;
	            for(var i:int = 0; i < parts; i++) {
					controlPoint.x = center.x + radius/Math.cos(gamma/2)*Math.sin(span + gamma/2);
					controlPoint.y = center.y - radius/Math.cos(gamma/2)*Math.cos(span + gamma/2);
					
					endPoint.x = center.x + radius * Math.sin(span + gamma);
					endPoint.y = center.y - radius * Math.cos(span + gamma);
					
					graphics.curveTo(controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
					
					span += gamma;
	            }
			} else {
	            var spanReverse:Number = angle2;
	            for(var j:int = 0; j < parts; j++) {
					controlPoint.x = center.x + radius/Math.cos(gamma/2)*Math.sin(spanReverse - gamma/2);
					controlPoint.y = center.y - radius/Math.cos(gamma/2)*Math.cos(spanReverse - gamma/2);
					
					endPoint.x = center.x + radius * Math.sin(spanReverse - gamma);
					endPoint.y = center.y - radius * Math.cos(spanReverse - gamma);
					
					graphics.curveTo(controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
					
					spanReverse -= gamma;
	            }
			}
        }
        
		/**
		 * @param graphics
		 * @param center
		 * @param radius
		 * @param thickness
		 * @param angle1 start angle from the vertical
		 * @param angle2 end angle from the vertical
		 */        
		public static function drawPiePiece(graphics:Graphics, center:Point, radius:Number, thickness:Number, angle1:Number, angle2:Number):void
		{
			var radius1:Number = radius + thickness / 2;
			var radius2:Number = radius - thickness / 2;
			
			var point11:Point = new Point();
			var point12:Point = new Point();
			var point21:Point = new Point();
			var point22:Point = new Point();
			
			point11.x = center.x + radius1*Math.sin(angle1);
			point11.y = center.y - radius1*Math.cos(angle1);
			point12.x = center.x + radius1*Math.sin(angle2);
			point12.y = center.y - radius1*Math.cos(angle2);
			
			point21.x = center.x + radius2*Math.sin(angle1);
			point21.y = center.y - radius2*Math.cos(angle1);
			point22.x = center.x + radius2*Math.sin(angle2);
			point22.y = center.y - radius2*Math.cos(angle2);
			
			graphics.moveTo(point11.x, point11.y);
			GraphicUtils.drawArc(graphics, center, radius1, angle1, angle2);
			graphics.lineTo(point22.x, point22.y);
			GraphicUtils.drawArc(graphics, center, radius2, angle2, angle1);
			graphics.lineTo(point11.x, point11.y);
		}

		/**
		 * @param graphics
		 * @param center
		 * @param radius
		 * @param thickness
		 * @param angle1 start angle from the vertical
		 * @param angle2 end angle from the vertical
		 * @param direction 0 - None, 1 - Forward, 2 - Backward
		 */
		public static function drawDirectedPiePiece(graphics:Graphics, center:Point, radius:Number, thickness:Number, angle1:Number, angle2:Number, direction:int):void
		{
			var radius1:Number = radius + thickness / 2; // outside radius
			var radius2:Number = radius - thickness / 2; // inside radius
			var radiusM:Number = radius2 + (radius1 - radius2) / 2; // middle arrow radius
			
			var point11:Point = new Point(); // outside point
			var point12:Point = new Point(); // outside point
			var point21:Point = new Point(); // inside point
			var point22:Point = new Point(); // inside point
			var pointM:Point = new Point(); // middle arrow point
			
			if(direction > 0) {
				// Calculate arc length
				var arcLength:Number;
				if(angle1 == angle2) {
					arcLength = 2 * Math.PI * radiusM;
				} else {
					arcLength = (angle1 > angle2) ? radiusM * (2 * Math.PI - (angle2 - angle1)) : radiusM * (angle2 - angle1);
				}
				
				// If arc is smaller then some constant - draw triangle, otherwise draw pointed arc
				if(arcLength > 8) {
					var alpha:Number = 8 / radiusM;
					
					if(direction == 1) {
						pointM.x = center.x + radiusM * Math.sin(angle2);
						pointM.y = center.y - radiusM * Math.cos(angle2);
						
						angle2 -= alpha;
						
						point11.x = center.x + radius1*Math.sin(angle1);
						point11.y = center.y - radius1*Math.cos(angle1);
						point12.x = center.x + radius1*Math.sin(angle2);
						point12.y = center.y - radius1*Math.cos(angle2);
						
						point21.x = center.x + radius2*Math.sin(angle1);
						point21.y = center.y - radius2*Math.cos(angle1);
						point22.x = center.x + radius2*Math.sin(angle2);
						point22.y = center.y - radius2*Math.cos(angle2);
						
						graphics.moveTo(point11.x, point11.y);
						GraphicUtils.drawArc(graphics, center, radius1, angle1, angle2);
						graphics.lineTo(pointM.x, pointM.y);
						graphics.lineTo(point22.x, point22.y);
						GraphicUtils.drawArc(graphics, center, radius2, angle1, angle2, true);
						graphics.lineTo(point11.x, point11.y);
					} else if(direction == 2) {
						pointM.x = center.x + radiusM * Math.sin(angle1);
						pointM.y = center.y - radiusM * Math.cos(angle1);
						
						angle1 += alpha;
						
						point11.x = center.x + radius1*Math.sin(angle1);
						point11.y = center.y - radius1*Math.cos(angle1);
						point12.x = center.x + radius1*Math.sin(angle2);
						point12.y = center.y - radius1*Math.cos(angle2);
						
						point21.x = center.x + radius2*Math.sin(angle1);
						point21.y = center.y - radius2*Math.cos(angle1);
						point22.x = center.x + radius2*Math.sin(angle2);
						point22.y = center.y - radius2*Math.cos(angle2);
						
						graphics.moveTo(point11.x, point11.y);
						GraphicUtils.drawArc(graphics, center, radius1, angle1, angle2);
						graphics.lineTo(point22.x, point22.y);
						GraphicUtils.drawArc(graphics, center, radius2, angle1, angle2, true);
						graphics.lineTo(pointM.x, pointM.y);
						graphics.lineTo(point11.x, point11.y);
					}
				} else {
					if(direction == 1) {
						pointM.x = center.x + radiusM * Math.sin(angle2);
						pointM.y = center.y - radiusM * Math.cos(angle2);
						
						point11.x = center.x + radius1*Math.sin(angle1);
						point11.y = center.y - radius1*Math.cos(angle1);
						point21.x = center.x + radius2*Math.sin(angle1);
						point21.y = center.y - radius2*Math.cos(angle1);
						
						graphics.moveTo(point11.x, point11.y);
						graphics.lineTo(pointM.x, pointM.y);
						graphics.lineTo(point21.x, point21.y);
						graphics.lineTo(point11.x, point11.y);
					} else if(direction == 2) {
						pointM.x = center.x + radiusM * Math.sin(angle1);
						pointM.y = center.y - radiusM * Math.cos(angle1);
						
						point12.x = center.x + radius1*Math.sin(angle2);
						point12.y = center.y - radius1*Math.cos(angle2);
						point22.x = center.x + radius2*Math.sin(angle2);
						point22.y = center.y - radius2*Math.cos(angle2);
						
						graphics.moveTo(point12.x, point12.y);
						graphics.lineTo(point22.x, point22.y);
						graphics.lineTo(pointM.x, pointM.y);
						graphics.lineTo(point12.x, point12.y);
					}
				}
			} else {
				point11.x = center.x + radius1*Math.sin(angle1);
				point11.y = center.y - radius1*Math.cos(angle1);
				point12.x = center.x + radius1*Math.sin(angle2);
				point12.y = center.y - radius1*Math.cos(angle2);
				
				point21.x = center.x + radius2*Math.sin(angle1);
				point21.y = center.y - radius2*Math.cos(angle1);
				point22.x = center.x + radius2*Math.sin(angle2);
				point22.y = center.y - radius2*Math.cos(angle2);
				
				graphics.moveTo(point11.x, point11.y);
				GraphicUtils.drawArc(graphics, center, radius1, angle1, angle2);
				graphics.lineTo(point22.x, point22.y);
				GraphicUtils.drawArc(graphics, center, radius2, angle1, angle2, true);
				graphics.lineTo(point11.x, point11.y);
			}
		}
		
		public static function pointOnCircle(center:Point, angle:Number, radius:Number):Point
		{
			if(angle > 2 * Math.PI) {
				angle = angle % (2 * Math.PI);
			}
			
			var point:Point = new Point();
			
			if(angle < Math.PI / 2) {
				point.x = center.x + Math.sin(angle) * radius;
				point.y = center.y - Math.cos(angle) * radius;
			} else if((angle >= Math.PI / 2) && (angle < Math.PI)) {
				point.x = center.x + Math.sin(Math.PI - angle) * radius;
				point.y = center.y + Math.cos(Math.PI - angle) * radius;
			} else if((angle >= Math.PI) && (angle < 3 * Math.PI / 2)) {
				point.x = center.x - Math.sin(angle - Math.PI) * radius;
				point.y = center.y + Math.cos(angle - Math.PI) * radius;
			} else if((angle >= 3 * Math.PI / 2) && (angle <= 2 * Math.PI)) {
				point.x = center.x - Math.sin(2 * Math.PI - angle) * radius;
				point.y = center.y - Math.cos(2 * Math.PI - angle) * radius;
			}
			
			return point;
		}
        
        /* Makes bitmap transparent from regular bitmap. Transparency level depends on transparencyFactor variable. */
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
