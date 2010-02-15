package org.jbei.components.railClasses
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.jbei.bio.data.CutSite;
	import org.jbei.bio.data.IAnnotation;
	import org.jbei.components.common.LabelBox;

	public class CutSiteLabelBox extends LabelBox
	{
		private var contentHolder:ContentHolder;
		
		private var cutSite:CutSite;
		
		// Constructor
		public function CutSiteLabelBox(contentHolder:ContentHolder, relatedAnnotation:IAnnotation)
		{
			super(contentHolder, relatedAnnotation);
			
			this.contentHolder = contentHolder;
			
			cutSite = relatedAnnotation as CutSite;
		}
		
		// Protected Methods
		protected override function tipText():String
		{
			return cutSite.label + ": " + (cutSite.start + 1) + ".." + (cutSite.end + 1) + (cutSite.forward ? "" : ", complement") + ", cuts " + cutSite.numCuts + " times";
		}
		
		protected override function render():void
		{
			var g:Graphics = graphics;
			g.clear();
			
			var cutSiteBitMap:BitmapData = (cutSite.numCuts == 1) ? contentHolder.singleCutterCutSiteTextRenderer.textToBitmap(cutSite.label) : contentHolder.cutSiteTextRenderer.textToBitmap(cutSite.label);
			
			_totalWidth = cutSiteBitMap.width;
			_totalHeight = cutSiteBitMap.height;
			
			g.beginBitmapFill(cutSiteBitMap);
			g.drawRect(0, 0, cutSiteBitMap.width, cutSiteBitMap.height);
			g.endFill();
		}
		
		protected override function label():String
		{
			return cutSite.label;
		}
	}
}
