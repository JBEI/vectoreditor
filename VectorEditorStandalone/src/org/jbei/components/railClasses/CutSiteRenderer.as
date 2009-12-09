package org.jbei.components.railClasses
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import org.jbei.bio.data.CutSite;
	
	public class CutSiteRenderer extends AnnotationRenderer
	{
		public static const CUT_SITE_HEIGHT:Number = 8;
		
		private const LINE_COLOR:int = 0x606060;
		
		private var _connectionPoint:Point;
		
		// Constructor
		public function CutSiteRenderer(contentHolder:ContentHolder, cutSite:CutSite)
		{
			super(contentHolder, cutSite);
		}
		
		// Properties
		public function get cutSite():CutSite
		{
			return annotation as CutSite;
		}
		
		public function get connectionPoint():Point
		{
			return _connectionPoint;
		}
		
		// Public Methods
		public function update():void
		{
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
			
			var xPosition:Number = contentHolder.startRailPoint.x + contentHolder.bpWidth * (cutSite.end + cutSite.start) / 2;
			var yPosition1:Number = contentHolder.startRailPoint.y;
			var yPosition2:Number = contentHolder.startRailPoint.y - CUT_SITE_HEIGHT;
			
			_connectionPoint = new Point(xPosition, (yPosition1 + yPosition2) / 2);
			
			g.moveTo(xPosition, yPosition1);
			g.lineTo(xPosition, yPosition2);
		}
		
		protected override function createToolTipLabel():void
		{
			tooltipLabel = cutSite.restrictionEnzyme.name + ": " + (cutSite.start + 1) + ".." + (cutSite.end + 1) + (cutSite.forward ? "" : ", complement") + ", cuts " + cutSite.numCuts + " times";
		}
	}
}
