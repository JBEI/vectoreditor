package org.jbei.components.common
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.ToolTip;
	import mx.core.FlexTextField;
	import mx.core.UIComponent;
	import mx.managers.ToolTipManager;
	
	import org.jbei.bio.data.IAnnotation;

	public class LabelBox extends UIComponent
	{
		private var needsMeasurement:Boolean = true;
		private var contentHolder:IContentHolder;
		private var tip:ToolTip;
		private var _relatedAnnotation:IAnnotation;
		private var _includeInView:Boolean = true;
		
		protected var _totalWidth:Number;
		protected var _totalHeight:Number;
		
		// Constructor
		public function LabelBox(contentHolder:IContentHolder, relatedAnnotation:IAnnotation)
		{
			super();
			
			this.contentHolder = contentHolder;
			
			_relatedAnnotation = relatedAnnotation;
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
		
		// Properties
		public function get relatedAnnotation():IAnnotation
		{
			return _relatedAnnotation;
		}
		
		public function get includeInView():Boolean
		{
			return _includeInView;
		}
		
		public function set includeInView(value:Boolean):void
		{
			if(_includeInView != value) {
				_includeInView = value;
				
				visible = _includeInView;
			}
		}
		
		public function get totalWidth():Number
		{
			return _totalWidth;
		}
		
		public function get totalHeight():Number
		{
			return _totalHeight;
		}
		
		// Protected Methods
		protected function label():String
		{
			// Abstract Method
			return "";
		}
		
		protected function tipText():String
		{
			// Abstract Method
			return "";
		}
		
		protected function render():void
		{
			// Abstract Method
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(needsMeasurement) {
				needsMeasurement = false;
				
				render();
			}
		}
		
		// Private Methods
		private function onClick(event:MouseEvent):void
		{
			contentHolder.select(_relatedAnnotation.start, _relatedAnnotation.end + 1);
		}
		
		private function onRollOver(event:MouseEvent):void
		{
			var localPoint:Point = localToGlobal(new Point(event.localX + 20, event.localY));
			
		    tip = ToolTipManager.createToolTip(tipText(), localPoint.x, localPoint.y) as ToolTip;
    	}
		
		private function onRollOut(event:MouseEvent):void
		{
			ToolTipManager.destroyToolTip(tip);
		}
	}
}
