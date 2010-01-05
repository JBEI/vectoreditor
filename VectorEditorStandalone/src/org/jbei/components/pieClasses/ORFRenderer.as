package org.jbei.components.pieClasses
{
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.jbei.bio.data.ORF;
	import org.jbei.components.common.GraphicUtils;
	import org.jbei.components.common.AnnotationRenderer;

	public class ORFRenderer extends AnnotationRenderer
	{
		public static const DISTANCE_FROM_RAIL:Number = 15;
		public static const DISTANCE_BETWEEN_ORFS:Number = 10;
		private const ORF_FRAME_COLOR1:int = 0xFF0000;
		private const ORF_FRAME_COLOR2:int = 0x31B440;
		private const ORF_FRAME_COLOR3:int = 0x3366CC;
		
		private var orfAlignmentMap:Dictionary;
		private var railRadius:Number;
		private var center:Point;
		
		// Contructor
		public function ORFRenderer(contentHolder:ContentHolder, orf:ORF)
		{
			super(contentHolder, orf);
		}
		
		// Properties
		public function get orf():ORF
		{
			return annotation as ORF;
		}
		
		// Public Methods
		public function update(railRadius:Number, center:Point, orfAlignmentMap:Dictionary):void
		{
			this.orfAlignmentMap = orfAlignmentMap;
			this.railRadius = railRadius;
			this.center = center;
			
			needsMeasurement = true;
			invalidateDisplayList();
		}
		
		// Protected Methods
		protected override function render():void
		{
			var color:int = colorByFrame();
			
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(2, color);
			
			// render curve
			var rowIndex:int = orfAlignmentMap[orf];
			
			var orfRadius:Number = railRadius + DISTANCE_FROM_RAIL;
			if(rowIndex > 0) {
				orfRadius += rowIndex * DISTANCE_BETWEEN_ORFS;
			}
			
			var angle1:Number = orf.start * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			var angle2:Number = (orf.end + 1) * 2 * Math.PI / contentHolder.featuredSequence.sequence.length;
			
			g.moveTo(center.x + orfRadius * Math.sin(angle1), center.y - orfRadius * Math.cos(angle1));
			GraphicUtils.drawArc(g, center, orfRadius, angle1, angle2);
			
			// render start codons as bold dots
			for(var i:int = 0; i < orf.startCodons.length; i++) {
				var startCodonAngle:Number = orf.startCodons[i] * 2 * Math.PI / contentHolder.featuredSequence.sequence.length
				
				var startCodonX:Number = center.x + orfRadius * Math.sin(startCodonAngle);
				var startCodonY:Number = center.y - orfRadius * Math.cos(startCodonAngle);
				
				g.drawCircle(startCodonX, startCodonY, 2);
			}
			
			// render end codons as arrows
			if(! orf.isComplement) {
				var arrowShiftAngle1:Number = angle2 - 5 / orfRadius;
				
				g.moveTo(center.x + (orfRadius + 2) * Math.sin(arrowShiftAngle1), center.y - (orfRadius + 2) * Math.cos(arrowShiftAngle1));
				g.lineTo(center.x + orfRadius * Math.sin(angle2), center.y - orfRadius * Math.cos(angle2));
				g.lineTo(center.x + (orfRadius - 2) * Math.sin(arrowShiftAngle1), center.y - (orfRadius - 2) * Math.cos(arrowShiftAngle1));
				g.lineTo(center.x + (orfRadius + 2) * Math.sin(arrowShiftAngle1), center.y - (orfRadius + 2) * Math.cos(arrowShiftAngle1));
			} else {
				var arrowShiftAngle2:Number = angle1 + 5 / orfRadius;
				
				g.moveTo(center.x + (orfRadius + 2) * Math.sin(arrowShiftAngle2), center.y - (orfRadius + 2) * Math.cos(arrowShiftAngle2));
				g.lineTo(center.x + orfRadius * Math.sin(angle1), center.y - orfRadius * Math.cos(angle1));
				g.lineTo(center.x + (orfRadius - 2) * Math.sin(arrowShiftAngle2), center.y - (orfRadius - 2) * Math.cos(arrowShiftAngle2));
				g.lineTo(center.x + (orfRadius + 2) * Math.sin(arrowShiftAngle2), center.y - (orfRadius + 2) * Math.cos(arrowShiftAngle2));
			}
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = orf.start + ".." + orf.end + ", frame: " + orf.frame() + ", length: " + (Math.abs(orf.end - orf.start) + 1) + " BP, " + int((Math.abs(orf.end - orf.start) + 1) / 3) + " AA" + (orf.isComplement ? ", complimentary" : "");
			if(orf.startCodons.length > 1) {
				tooltipLabel += "\n";
				for(var i:int = 0; i < orf.startCodons.length; i++) {
					tooltipLabel += orf.startCodons[i];
					
					if(i != orf.startCodons.length - 1) {
						tooltipLabel += ", ";
					}
				}
			}
    	}
		
		// Private Methods
		private function colorByFrame():int
		{
			var color:int = ORF_FRAME_COLOR1;
			
			if(orf.frame() == 0) {
				color = ORF_FRAME_COLOR1;
			} else if(orf.frame() == 1) {
				color = ORF_FRAME_COLOR2;
			} else if(orf.frame() == 2) {
				color = ORF_FRAME_COLOR3;
			}
			
			return color;
		}
	}
}
