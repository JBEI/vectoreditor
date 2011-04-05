package org.jbei.components.railClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.jbei.bio.enzymes.RestrictionCutSite;
	import org.jbei.components.common.AnnotationRenderer;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class CutSiteRenderer extends AnnotationRenderer
	{
		public static const CUT_SITE_HEIGHT:Number = 8;
		
		private const LINE_COLOR:int = 0x606060;
		
		private var _connectionPoint:Point;
		private var bpWidth:Number;
		private var railMetrics:Rectangle;
		
		// Constructor
		public function CutSiteRenderer(contentHolder:ContentHolder, cutSite:RestrictionCutSite)
		{
			super(contentHolder, cutSite);
		}
		
		// Properties
		public function get cutSite():RestrictionCutSite
		{
			return annotation as RestrictionCutSite;
		}
		
		public function get connectionPoint():Point
		{
			return _connectionPoint;
		}
		
		// Public Methods
		public function update(railMetrics:Rectangle, bpWidth:Number):void
		{
			this.railMetrics = railMetrics;
			this.bpWidth = bpWidth;
			
			needsMeasurement = true;
			invalidateDisplayList();
		}
		
		// Protected Methods
		protected override function render():void
		{
			super.render();
			
			var g:Graphics = graphics;
			g.clear();
			
			g.lineStyle(1, LINE_COLOR);
			
			var xPosition:Number = railMetrics.x + bpWidth * cutSite.start;
			var yPosition1:Number = railMetrics.y;
			var yPosition2:Number = railMetrics.y - CUT_SITE_HEIGHT;
			
			_connectionPoint = new Point(xPosition, (yPosition1 + yPosition2) / 2);
			
			g.moveTo(xPosition, yPosition1);
			g.lineTo(xPosition, yPosition2);
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = cutSite.restrictionEnzyme.name + ": " + (cutSite.start + 1) + ".." + (cutSite.end) + (cutSite.strand == 1 ? "" : ", complement") + ", cuts " + cutSite.numCuts + " times";
		}
	}
}
