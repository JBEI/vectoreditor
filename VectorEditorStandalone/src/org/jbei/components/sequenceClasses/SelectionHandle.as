package org.jbei.components.sequenceClasses
{
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.core.BitmapAsset;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	import mx.styles.StyleManager;
	
	public class SelectionHandle extends Canvas
	{
		public static const START_HANDLE:String = "START";
		public static const END_HANDLE:String = "END";
		
		[Embed(source="assets/handle.png")]
		private var handleIconClass:Class;
		
		[Embed(source="assets/handle_cursor.png")]
		private var handleCursorClass:Class;
		
		private var handleCursorID:uint;
		
		private var _actualHeight:uint = 1;
		private var _actualWidth:uint = 0;
		
		private var _kind:String;
		
		// Constructor
		public function SelectionHandle(kind:String)
		{
			super();
			
			_kind = kind;
			
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
		
		// Properties
		public function get actualHeight():uint
		{
			return _actualHeight;
		}
		
		public function get actualWidth():uint
		{
			return _actualWidth;
		}
		
		public function get kind():String
		{
			return _kind;
		}
		
		// Public Methods
		public function show():void
		{
			visible = true;
		}
		
		public function hide():void
		{
			visible = false;
		}
		
		// Protected Methods
		protected override function createChildren():void
		{
			super.createChildren();
			
			draw();
		}
		
		protected function draw(): void
		{
			var handleIconObject:BitmapAsset = new handleIconClass() as BitmapAsset;
			
			var g:Graphics = graphics;
			g.beginBitmapFill(handleIconObject.bitmapData);
			
			_actualWidth = handleIconObject.width;
			_actualHeight = handleIconObject.height;
			
			g.drawRect(0, 0, _actualWidth, _actualHeight);
			g.endFill();
		}
		
		// Private Methods 
	    private function onRollOver(event:MouseEvent):void
	    {
	    	handleCursorID = CursorManager.setCursor(handleCursorClass);
	    }
	    
	    private function onRollOut(event:MouseEvent):void
	    {
	    	CursorManager.removeCursor(handleCursorID);
	    }
	}
}
