package org.jbei.components.pieClasses
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	import mx.utils.StringUtil;
	
	import org.jbei.bio.enzymes.RestrictionCutSite;
	import org.jbei.bio.sequence.common.Annotation;
	import org.jbei.components.common.LabelBox;

    /**
     * @author Zinovii Dmytriv
     */
	public class CutSiteLabelBox extends LabelBox
	{
		private var contentHolder:ContentHolder;
		
		private var cutSite:RestrictionCutSite;
		
		// Constructor
		public function CutSiteLabelBox(contentHolder:ContentHolder, relatedAnnotation:Annotation)
		{
			super(contentHolder, relatedAnnotation);
			
			this.contentHolder = contentHolder;
			
			cutSite = relatedAnnotation as RestrictionCutSite;
			
			if(cutSite.restrictionEnzyme.name == null || cutSite.restrictionEnzyme.name == "" || StringUtil.trim(cutSite.restrictionEnzyme.name) == "") {
				visible = false;
			}
		}
		
		// Protected Methods
		protected override function tipText():String
		{
			return cutSite.restrictionEnzyme.name + ": " + (cutSite.start + 1) + ".." + (cutSite.end + 1) + (cutSite.strand == 1 ? "" : ", complement") + ", cuts " + cutSite.numCuts + " times";
		}
		
		protected override function render():void
		{
			var g:Graphics = graphics;
			g.clear();
			
			var cutSiteBitMap:BitmapData = (cutSite.numCuts == 1) ? contentHolder.singleCutterCutSiteTextRenderer.textToBitmap(cutSite.restrictionEnzyme.name) : contentHolder.cutSiteTextRenderer.textToBitmap(cutSite.restrictionEnzyme.name);
			
			_totalWidth = cutSiteBitMap.width;
			_totalHeight = cutSiteBitMap.height;
			
			g.beginBitmapFill(cutSiteBitMap);
			g.drawRect(0, 0, cutSiteBitMap.width, cutSiteBitMap.height);
			g.endFill();
		}
		
		protected override function label():String
		{
			return cutSite.restrictionEnzyme.name;
		}
	}
}
