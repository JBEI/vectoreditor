package org.jbei.components.common
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.ToolTip;
	import mx.core.UIComponent;
	import mx.managers.ToolTipManager;
	
	import org.jbei.bio.sequence.common.Annotation;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class AnnotationRenderer extends UIComponent
	{
		protected var contentHolder:IContentHolder;
		protected var annotation:Annotation;
		protected var needsMeasurement:Boolean = false;
		protected var tooltipLabel:String;
		
		private var tip:ToolTip;
		
		// Constructor
		public function AnnotationRenderer(contentHolder:IContentHolder, annotation:Annotation)
		{
			super();
			
			this.contentHolder = contentHolder;
			this.annotation = annotation;
			
			tooltipLabel = "";
			
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			createToolTipLabel();
		}
		
		// Protected Methods
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(needsMeasurement) {
				needsMeasurement = false;
				
				render();
			}
		}
		
		protected function render():void
		{
			// Abstract Method
		}
		
		protected function createToolTipLabel():void
		{
			// Abstract Method
		}
		
		// Private Methods
		private function onRollOver(event:MouseEvent):void
		{
			// Calculate tip position
			var tipPoint:Point = localToGlobal(new Point(event.localX + 20, event.localY));
			
			tip = ToolTipManager.createToolTip(tooltipLabel, tipPoint.x, tipPoint.y) as ToolTip;
			
			if(tip.x + tip.width > stage.stageWidth) {
				tip.x -= (tip.x + tip.width - stage.stageWidth);
				tip.y += 20;
			}
		}
		
		private function onRollOut(event:MouseEvent):void
		{
			ToolTipManager.destroyToolTip(tip);
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			contentHolder.select(annotation.start, annotation.end + 1);
		}
	}
}
