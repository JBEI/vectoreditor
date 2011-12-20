package org.jbei.components.pieClasses
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	import mx.utils.StringUtil;
	
	import org.jbei.bio.sequence.common.Annotation;
	import org.jbei.bio.sequence.dna.Feature;
	import org.jbei.bio.sequence.dna.FeatureNote;
	import org.jbei.components.common.LabelBox;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class FeatureLabelBox extends LabelBox
	{
		private var contentHolder:ContentHolder;
		
		private var _feature:Feature;
		
		// Contructor
		public function FeatureLabelBox(contentHolder:ContentHolder, relatedAnnotation:Annotation)
		{
			super(contentHolder, relatedAnnotation);
			
			this.contentHolder = contentHolder;
			
			_feature = relatedAnnotation as Feature;
			
			if(label() == null || label() == "" || StringUtil.trim(label()) == "") {
				visible = false;
			}
		}
		
		// Properties
		public function get feature():Feature
		{
			return _feature;
		}
		
		// Protected Methods
		protected override function tipText():String
		{
			return _feature.type + (" - " + label()) + ": " + (_feature.start + 1) + ".." + (_feature.end);
		}
		
		protected override function render():void
		{
			var g:Graphics = graphics;
			g.clear();
			
			var featureBitMap:BitmapData = contentHolder.featureTextRenderer.textToBitmap(label());
			
			_totalWidth = featureBitMap.width;
			_totalHeight = featureBitMap.height;
			
			g.beginBitmapFill(featureBitMap);
			g.drawRect(0, 0, featureBitMap.width, featureBitMap.height);
			g.endFill();
		}
		
		protected override function label():String
		{
			var result:String = null;
			if(_feature.name == null || _feature.name == "" || StringUtil.trim(_feature.name) == "") {
				var notes:Vector.<FeatureNote> = _feature.notes;
				for (var i:int = 0; i < notes.length; i++) {
					var note:FeatureNote = notes[i];
					if ("label" == note.name || "apeinfo_label" == note.name || "note" == note.name || "gene" == note.name) {
						result = note.value;
						break;
					}
				}
			} else {
				result = _feature.name;
			}
			if (result == null) {
				result = "";
			}
			return result;
		}
	}
}
