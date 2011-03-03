package org.jbei.view.components
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	
	import org.flashcommander.components.AutoComplete;
	import org.jbei.events.Direction;
	import org.jbei.events.GridCellEvent;
	import org.jbei.events.MoveCellEvent;

	public class AutoCompleteGridCell extends GridCell
	{
		private var _autoComplete:AutoComplete;
		
		public function AutoCompleteGridCell( index:int, row:int )
		{
			super( index, row );
			
			// autocomplete
			_autoComplete = new AutoComplete();
			_autoComplete.forceOpen = false;
			_autoComplete.width = DEFAULT_WIDTH;
			_autoComplete.height = DEFAULT_HEIGHT;
		}
		
		/**
		 * Key down event handler. First detects if the arrow key
		 * is pressed, and dispatches and event to allow one of the parents 
		 * to switch the selected cell  
		 */ 
		override protected function keyDown( event:KeyboardEvent ) : void
		{
			if( !this._editMode )
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
				this._autoComplete.text = "";
				this.switchToEditMode( true );
				
				// WORKAROUND FOR FLEX BUG : https://bugs.adobe.com/jira/browse/SDK-26705 
				var storedSelectionAnchorPosition : int = this._autoComplete.inputTxt.selectionAnchorPosition; 
				var storedTextLength : int = this._autoComplete.text.length; 
				
				var differenceTextLength : int = (this._autoComplete.text.length - storedTextLength) 
				storedSelectionAnchorPosition = storedSelectionAnchorPosition + differenceTextLength; 
				
				// sets the cursor caret at the end of the text 
				this._autoComplete.inputTxt.selectRange( storedSelectionAnchorPosition, storedSelectionAnchorPosition ); 
			}				
		}
		
		override protected function doubleClick( event:MouseEvent ) : void
		{
			_doubleClick = true;
			this.switchToEditMode( true );
		}
		
		public function set dataProvider( data:ArrayCollection ) : void
		{
			this._autoComplete.dataProvider = data;
		}
		
		override public function switchToEditMode( setFocus:Boolean=false ) : void
		{
			if( this._editMode )
				return;
			
			this.removeChild( this._label );
			this.addChild( this._autoComplete );
			
			if( setFocus ) 
			{
				this._autoComplete.inputTxt.setFocus()
			}
			this._editMode = true;
		}
		
		override public function set text( text:String ) : void
		{
			if( _editMode )
				this._autoComplete.text = text;
			else
				this._label.text = text;
		}
		
		override public function switchToDisplayMode() : void
		{
			if( !this._editMode )
				return;
			
			this._editMode = false;
			this._doubleClick = false;
			this._label.text = this._autoComplete.text;
			this.removeChild( this._autoComplete );
			this.addChild( this._label );
		}
	}
}