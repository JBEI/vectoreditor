package org.jbei.components.sequenceClasses
{
	import flash.events.Event;
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
		protected var tooltipLabel:String;
		
		private var tip:ToolTip;
		
		private var needsMeasurement:Boolean = false;
		
		// Constructor
		public function AnnotationRenderer(contentHolder:ContentHolder, annotation:IAnnotation)
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
		
		// Public Methods
		public function update():void
		{
			needsMeasurement = true;
			invalidateDisplayList();
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
		private function onRollOver(event:MouseEvent):void
		{
			// Calculate tip position
			var localPoint:Point = localToGlobal(new Point(event.localX + 20, event.localY));
			
			tip = ToolTipManager.createToolTip(tooltipLabel, localPoint.x, localPoint.y) as ToolTip;
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
