package org.jbei.view.components
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.Keyboard;
	
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.formatters.NumberFormatter;
	import mx.managers.IFocusManagerComponent;
	import mx.managers.ToolTipManager;
	
	import org.jbei.events.Direction;
	import org.jbei.events.GridCellEvent;
	import org.jbei.events.GridCellMouseEvent;
	import org.jbei.events.MoveCellEvent;
	
	import spark.components.TextArea;
	import spark.components.TextInput;

	/**
	 * Smallest unit in the grid
	 */ 
	public class GridCell extends UIComponent implements IFocusManagerComponent
	{
		public static const DEFAULT_WIDTH:Number = 100;
		public static const DEFAULT_HEIGHT:Number = 20;
		
		private var _index:int;
		private var _row:int;
		private var _highlighted:Boolean = false;
		private var _control:Boolean = false;
		private var _error:Boolean = false;
		
		protected var _editMode:Boolean = false;
		protected var _doubleClick:Boolean = false;
		
		// controls
		protected var _label:Label;
		protected var _overlay:TranspOverlay;
		
		private var _corner:DragCorner;
		private var _textInput:TextInput;
		
		public function GridCell( index:int, row:int )
		{
			this._index = index;
			this._row = row;
			this._label = new Label();
			this._label.width = DEFAULT_WIDTH;
			this._label.height = DEFAULT_HEIGHT;
			ToolTipManager.showDelay = 0;
			
			this._textInput = new TextInput();
			this._textInput.setStyle( "focusColor", 0xFFFFFF );
			this._textInput.width = DEFAULT_WIDTH;
			this._textInput.height = DEFAULT_HEIGHT;

			this.render();
			this.addChild( this._label );
			
			this._overlay = new TranspOverlay( this );
			this._overlay.width = DEFAULT_WIDTH;
			this._overlay.height = DEFAULT_HEIGHT;
			this.addChild( this._overlay );
				
			// event Listeners
			this.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
			this.addEventListener( MouseEvent.MOUSE_UP, mouseUp );
			this.addEventListener( MouseEvent.MOUSE_OVER, mouseOver );
			this.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			
			this._textInput.addEventListener( Event.CHANGE, eventChange );
			
			this.doubleClickEnabled = true;
			this.addEventListener( MouseEvent.DOUBLE_CLICK, doubleClick );
		}
		
		protected function doubleClick( event:MouseEvent ) : void
		{
			this.switchToEditMode( true );
			_doubleClick = true;
		}
		
		public function get inEditMode() : Boolean
		{
			return this._editMode;
		}
		
		public function switchToEditMode( setFocus:Boolean=false ) : void
		{
			if( this._editMode )
				return;
			
			this._textInput.text = this._label.text;
			this.removeChild( this._label );
			this.removeChild( this._overlay );
			
			this.addChild( this._textInput );
			
			if( setFocus) 
				this._textInput.setFocus();
			this._editMode = true;
		}
		
		public function switchToDisplayMode() : void
		{
			if( !this._editMode )
				return;
			
			this._editMode = false;
			this._doubleClick = false;
			this._label.text = this._textInput.text;
			this.removeChild( this._textInput );
			this.addChild( this._label );
			this.addChild( this._overlay );
		}
		
		private function mouseOver( event:MouseEvent ) : void
		{
			if( event.buttonDown )
			{
				dispatchEvent( new GridCellMouseEvent( GridCellMouseEvent.MOUSE_DRAG, this, event.buttonDown ) );
			}
		}
		
		private function eventChange( event:Event ) : void
		{
			dispatchEvent( new GridCellEvent( GridCellEvent.TEXT_CHANGE, this ) );
		}
		
		/**
		 * Key down event handler. First detects if the arrow key
		 * is pressed, and dispatches and event to allow one of the parents 
		 * to switch the selected cell  
		 */ 
		protected function keyDown( event:KeyboardEvent ) : void
		{
			if( !this._editMode || ( this._editMode && !this._doubleClick ) )
			{
				switch( event.keyCode )
				{
					case Keyboard.LEFT:
						dispatchEvent( new MoveCellEvent( MoveCellEvent.ARROW_PRESSED, Direction.MOVE_LEFT, this ) );
						return;
					
					case Keyboard.RIGHT:
						dispatchEvent( new MoveCellEvent( MoveCellEvent.ARROW_PRESSED, Direction.MOVE_RIGHT, this ) );
						return;
					
					case Keyboard.UP:
						dispatchEvent( new MoveCellEvent( MoveCellEvent.ARROW_PRESSED, Direction.MOVE_UP, this ) );
						return;
					
					case Keyboard.DOWN:
					case Keyboard.ENTER:
						dispatchEvent( new MoveCellEvent( MoveCellEvent.ARROW_PRESSED, Direction.MOVE_DOWN, this ) );
						return;
					
					case Keyboard.CONTROL:
						dispatchEvent( new GridCellEvent( GridCellEvent.CTRL_BTN_DOWN, this ) );
						break;
				}
			}
			else
			{
				// enter is allow to move cursor from current cell
				if( event.keyCode == Keyboard.ENTER )
				{
					dispatchEvent( new MoveCellEvent( MoveCellEvent.ARROW_PRESSED, Direction.MOVE_DOWN, this ) );
					return;
				}
			}
			
			if( event.ctrlKey || event.keyCode == Keyboard.TAB )
			{
				// TODO : prevents tab and control key from switching mode to edit
			}
			else if( !_editMode )
			{
				this._textInput.text = "";
				this.switchToEditMode( true );
				
				// WORKAROUND FOR FLEX BUG : https://bugs.adobe.com/jira/browse/SDK-26705 
				var storedSelectionAnchorPosition : int = this._textInput.selectionAnchorPosition; 
				var storedTextLength : int = this._textInput.text.length; 
				
				var differenceTextLength : int = (this._textInput.text.length - storedTextLength) 
				storedSelectionAnchorPosition = storedSelectionAnchorPosition + differenceTextLength; 
				
				// sets the cursor caret at the end of the text 
				this._textInput.selectRange( storedSelectionAnchorPosition, storedSelectionAnchorPosition ); 
			}				
		}
		
		public function get row() : int
		{
			return this._row;
		}
		
		public function get index() : int
		{
			return this._index;
		}
		
		// EVENT HANDLERS
		private function mouseDown( event:MouseEvent ) : void
		{
			dispatchEvent( new GridCellEvent( GridCellEvent.MOUSE_DOWN, this ) ); 	// use in grid Holder
			dispatchEvent( new GridCellEvent( GridCellEvent.POSSIBLE_END, this ) ); // TODO : this should probably not be sent from here. 
		}
		
		private function mouseUp( event:MouseEvent ) : void
		{
			dispatchEvent( new GridCellEvent( GridCellEvent.MOUSE_UP, this ) );
		}
		
		public function highlight( addCorner:Boolean ) : void
		{
			this._highlighted = true;
			var g:Graphics = this._label.graphics;
			g.clear();
			g.lineStyle( 2, 0x5685d6 );
			g.beginFill( 0xFFFFFF );
			g.drawRect( this._label.x+1, this._label.y+1, this._label.width-2, this._label.height-2 );
			g.endFill();
			
			if( addCorner )
			{
				this._corner = new DragCorner( 7, this );
				this._corner.x = 93;
				this._corner.y = 13;
//				this._label.addChild( this._corner );
				this.addChild( this._corner );
			}
		}
		
		public function addCorner() : void
		{
			if( this._corner )
				return;
			
			this._corner = new DragCorner( 5, this);
			this._corner.x = 95;
			this._corner.y = 15;
//			this._label.addChild( this._corner );
			this.addChild( this._corner );
		}
		
		public function dashBorderLeft() : void
		{
			var g:Graphics = this._label.graphics;
			g.lineStyle( 1, 0x333333 );
			
			// todo : use a loop
			g.moveTo( this._label.x, this._label.y );
			g.lineTo( this._label.x, this._label.y + 5 );
			
			g.lineStyle( 1, 0xCCCCCC );
			g.lineTo( this._label.x, this._label.y + 10 );
			
			g.lineStyle( 1, 0x333333 );
			g.lineTo( this._label.x, this._label.y + 15 );
			
			g.lineStyle( 1, 0xCCCCCC );
			g.lineTo( this._label.x, this._label.y + 20 );
		}
		
		public function dashBorderTop() : void
		{
			var dashUnit:int = 5;
			
			var g:Graphics = this._label.graphics;
			g.lineStyle(1, 0x000000);
			g.moveTo( this._label.x, this._label.y );
			for( var i:int = dashUnit; i<=this._label.width; i+= dashUnit )
			{
				g.lineTo( this._label.x + i, this._label.y );
				i += dashUnit;
				g.moveTo( this._label.x + i, this._label.y ); 
			}
		}
		
		public function clearTop() : void
		{
			var g:Graphics = this._label.graphics;
			g.lineStyle( 1, 0xCCCCCC );
			g.moveTo( this._label.x, this._label.y );
			g.lineTo( this._label.x + this._label.width, this._label.y );
		}
		
		public function fill() : void
		{
			var g:Graphics = this._label.graphics;
			g.clear();
			g.lineStyle(1, 0xCCCCCC);
			g.beginFill( 0xe3e9ff );
			g.drawRect(this._label.x, this._label.y, this._label.width, this._label.height);
			g.endFill();
		}
		
		public function errorFill( msg:String ) : void
		{
			if( this._corner )
			{
				this.removeChild( this._corner );
				this._corner = null;
			}
			
			if( this._editMode )
			{
				this.switchToDisplayMode();
			}
			
			var g:Graphics = this._label.graphics;
			g.clear();
			g.lineStyle(1, 0xCCCCCC);
			g.beginFill( 0xfe0003 );
			g.drawRect(this._label.x, this._label.y, this._label.width, this._label.height);
			g.endFill();
			
			this._error = true;
			this._label.toolTip = msg;
		}
		
		public function clearError() : void
		{
			if( this._corner )
			{
				this.removeChild( this._corner );
				this._corner = null;
			}
			
			this.render();
			this._error = false;
		}
		
		public function get error() : Boolean
		{
			return this._error;
		}
		
		public function reset() : void
		{
			this._highlighted = false;
			
			if( this._corner )
			{
				this.removeChild( this._corner );
				this._corner = null;
			}
			
			render();
		}			
		
		private function render() : void
		{
			var g:Graphics = this._label.graphics;
			g.clear();
			g.lineStyle( 1, 0xCCCCCC );
			g.beginFill( 0xFFFFFF );
			g.drawRect( this._label.x, this._label.y, this._label.width, this._label.height );
			g.endFill();
		}
		
		// equality is determined by location in the grid
		public function equals( cell:GridCell ) : Boolean
		{
			if( cell == null || this._index != cell.index )
				return false;
			
			if( this._row != cell.row )
				return false;
			
			return true;
		}
		
		public function set text( text:String ) : void
		{
			if( _editMode )
				this._textInput.text = text;
			else
				this._label.text = text;
		}
		
		public function get text():String
		{	
			if( _editMode )
				return _textInput.text;
			return this._label.text;
		}
		
		public function get highlighted() : Boolean
		{
			return this._highlighted;
		}
		
		public function get tooltip() : String
		{
			if( this._error )
				return this._label.toolTip;
			
			if( this._editMode )
				return this._textInput.text;
			
			return this._label.text;
		}
	}
}