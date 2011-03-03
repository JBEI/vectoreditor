package org.jbei.controller
{
	import org.jbei.events.GridCellEvent;
	import org.jbei.model.GridPaste;
	import org.jbei.model.PasteEventProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class PasteCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ):void
		{
			var cellEvent:GridCellEvent = notification.getBody() as GridCellEvent;
			var proxy:PasteEventProxy = facade.retrieveProxy( PasteEventProxy.NAME ) as PasteEventProxy;
			var gridPaste:GridPaste = new GridPaste( cellEvent.cell.row, cellEvent.cell.index );
			proxy.distributeCopiedText( cellEvent.cell, cellEvent.text, gridPaste );
		}
	}
}