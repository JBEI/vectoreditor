package org.jbei.view.components
{
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	
	import org.jbei.events.GridCellMouseEvent;

	public class DragCorner extends UIComponent
	{
		[Embed("/org/jbei/view/assets/corner_cursor.gif")]
		private var customCursor:Class;
		private var _size:int;	
		private var _cell:GridCell;
		
		public function DragCorner( size:int, cell:GridCell )
		{
			this._size = size;
			this._cell = cell;
			
			this.graphics.clear();
			this.graphics.lineStyle( 1, 0xFFFFFF );
			this.graphics.moveTo( 0, 0 );			
			this.graphics.lineTo( 5, 0 );
			this.graphics.moveTo( 0, 0 );	
			this.graphics.lineTo( 0, -5 );
			
			graphics.beginFill( 0x5685d6 );
			graphics.drawRect( 0, 0, 8, 8 );
			graphics.endFill();
			
			this.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
			this.addEventListener( MouseEvent.MOUSE_OVER, mouseOver );
			this.addEventListener( MouseEvent.MOUSE_OUT, mouseOut );
		}
		
		private function mouseOut( event:MouseEvent ) : void
		{
			CursorManager.removeAllCursors();
		}
		
		// changes the cursor when a mouse hovers over
		private function mouseOver( event:MouseEvent ) : void
		{	
			CursorManager.setCursor( customCursor, CursorManagerPriority.HIGH, -8, -7 );
		}
		
		private function mouseDown( event:MouseEvent ) : void
		{
			dispatchEvent( new GridCellMouseEvent( GridCellMouseEvent.CORNER_CLICK, this._cell, true ) );
		}		
	}
}