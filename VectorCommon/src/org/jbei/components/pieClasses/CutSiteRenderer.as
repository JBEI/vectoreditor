package org.jbei.components.pieClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import org.jbei.bio.enzymes.RestrictionCutSite;
	import org.jbei.components.common.AnnotationRenderer;
	import org.jbei.components.common.GraphicUtils;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class CutSiteRenderer extends AnnotationRenderer
	{
		private const FRAME_COLOR:int = 0x606060;
		private const CURVY_LINE_COLOR:int = 0xFF0000;
		
		private var _middlePoint:Point;
		
		private var center:Point;
		private var railRadius:Number;
		private var angle:Number;
		
		// Constructor
		public function CutSiteRenderer(contentHolder:ContentHolder, cutSite:RestrictionCutSite)
		{
			super(contentHolder, cutSite);
		}
		
		// Properties
		public function get middlePoint():Point
		{
			return _middlePoint;
		}
		
		public function get cutSite():RestrictionCutSite
		{
			return annotation as RestrictionCutSite;
		}
		
		// Public Methods
		public function update(railRadius:Number, center:Point):void
		{
			this.center = center;
			this.railRadius = railRadius;
			
			angle = cutSite.start * 2 * Math.PI / contentHolder.sequenceProvider.sequence.length;
			
			_middlePoint = GraphicUtils.pointOnCircle(center, angle, railRadius + 10);
			
			needsMeasurement = true;
			invalidateDisplayList();
		}
		
		// Protected Methods
		protected override function render():void
		{
			super.render();
			
			var g:Graphics = graphics;
			g.clear();
			
			g.lineStyle(1, FRAME_COLOR);
			
			var point1:Point = new Point();
			var point2:Point = new Point();
			
			point1.x = center.x + railRadius * Math.sin(angle);
			point1.y = center.y - railRadius * Math.cos(angle);
			point2.x = center.x + (railRadius + 10) * Math.sin(angle);
			point2.y = center.y - (railRadius + 10) * Math.cos(angle);
			
			g.moveTo(point1.x, point1.y);
			g.lineTo(point2.x, point2.y);
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = cutSite.restrictionEnzyme.name + ": " + (cutSite.start + 1) + ".." + (cutSite.end + 1) + (cutSite.strand == 1 ? "" : ", complement") + ", cuts " + cutSite.numCuts + " times";
		}
	}
}
