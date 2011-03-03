package org.jbei.view.components
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.Mouse;
	
	import mx.controls.Image;
	
	import org.jbei.events.GridCellEvent;

	public class TranspOverlay extends Image
	{
		[Embed("/org/jbei/view/assets/transp.png")]
		private var _source:Class;
		private var _cell:GridCell;
		
		public function TranspOverlay( cell:GridCell )
		{
			super();
			super.source = _source;
			this._cell = cell;
			
			this.addMenu();
			this.addEventListener( MouseEvent.MOUSE_MOVE, mouseOver );
			this.addEventListener( Event.PASTE, paste );
		}
		
		private function mouseOver( event:MouseEvent ) : void
		{
			this.toolTip = this._cell.tooltip;
		}
		
		private function paste( event:Event ) : void
		{
			var text:String = Clipboard.generalClipboard.getData( ClipboardFormats.TEXT_FORMAT ) as String;
			dispatchEvent( new GridCellEvent( GridCellEvent.PASTE, _cell, text ) );
		}
		
		private function addMenu() : void 
		{
			this.contextMenu = new ContextMenu();
			this.contextMenu.hideBuiltInItems();
			this.contextMenu.clipboardMenu = true;
			this.contextMenu.clipboardItems.paste = true;
			this.contextMenu.clipboardItems.copy = true;
			this.contextMenu.clipboardItems.cut = true;
			this.contextMenu.clipboardItems.selectAll = true;
		}
	}
}