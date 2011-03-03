package org.jbei.view.components
{
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	
	import mx.managers.IFocusManager;
	
	import org.jbei.events.RowHeaderEvent;
	
	import spark.components.Label;

	public class GridRowHeader extends Label
	{
		public static var DEFAULT_WIDTH:Number = 30;
		public static var DEFAULT_HEIGHT:Number = GridCell.DEFAULT_HEIGHT;
		
		private var index:Number;
		
		public function GridRowHeader(index:Number)
		{
			this.width = DEFAULT_WIDTH;
			this.height = DEFAULT_HEIGHT;
			this.index = index;
			this.text = String( index );
			
			setStyle( "textAlign", "center" );
			setStyle( "verticalAlign", "middle" );
			setStyle( "fontSize", 10);			
				
			render();
			
			// Event Listeners
			this.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
			this.addEventListener( MouseEvent.MOUSE_OVER, mouseOver );
			this.addEventListener( MouseEvent.MOUSE_UP, mouseUp );
		}
		
		private function mouseDown( event:MouseEvent ) : void
		{
			dispatchEvent( new RowHeaderEvent( RowHeaderEvent.MOUSE_DOWN, this.index ) );
		}
		
		private function mouseOver( event:MouseEvent ) : void
		{
			dispatchEvent( new RowHeaderEvent( RowHeaderEvent.MOUSE_OVER, this.index ) );
		}
		
		private function mouseUp( event:MouseEvent ) : void
		{	
			dispatchEvent( new RowHeaderEvent( RowHeaderEvent.MOUSE_UP, this.index ) );
		}
		
		public function highlight() : void
		{
			this.graphics.clear();
			this.graphics.lineStyle( 1, 0x000000 );
			this.graphics.beginFill( 0xf6cc82 );
			this.graphics.drawRect( 0, 0, this.width, this.height );
			this.graphics.endFill();
		}
		
		public function reset() : void
		{
			render();
		}
		
		private function render():void
		{
			var g:Graphics = this.graphics;
			g.clear();
			g.lineStyle( 1, 0xDDDDDD );
			g.beginFill(0xCCCCCC);
			g.drawRect( 0, 0, this.width, this.height );
			g.endFill();
		}
	}
}