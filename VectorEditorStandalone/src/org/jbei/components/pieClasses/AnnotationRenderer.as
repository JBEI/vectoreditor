package org.jbei.components.pieClasses
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.ToolTip;
	import mx.core.UIComponent;
	import mx.managers.ToolTipManager;
	
	import org.jbei.bio.data.IAnnotation;
	
	public class AnnotationRenderer extends UIComponent
	{
		protected var contentHolder:ContentHolder;
		protected var annotation:IAnnotation;
		protected var needsMeasurement:Boolean = false;
		protected var tooltipLabel:String;
		
		private var tip:ToolTip;
		
		// Constructor
		public function AnnotationRenderer(contentHolder:ContentHolder, annotation:IAnnotation)
		{
			super();
			
			this.contentHolder = contentHolder;
			this.annotation = annotation;
			
			tooltipLabel = "";
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
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
			tooltipLabel = "";
		}
		
		// Private Methods
		private function onMouseOver(event:MouseEvent):void
		{
			// Calculate tip position
			var localPoint:Point = localToGlobal(new Point(event.localX + 20, event.localY));
			
			tip = ToolTipManager.createToolTip(tooltipLabel, localPoint.x, localPoint.y) as ToolTip;
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			ToolTipManager.destroyToolTip(tip);
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			contentHolder.select(annotation.start, annotation.end);
		}
	}
}
