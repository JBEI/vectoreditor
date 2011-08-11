package org.jbei.model
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.jbei.Notifications;
	import org.jbei.view.components.GridCell;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class PasteEventProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "org.jbei.model.PasteEventProxy";
		
		public function PasteEventProxy()
		{
			super( NAME );
		}
		
		// Splits the text around tabs and endlines
		public function distributeCopiedText( cell:GridCell, text:String, gridPaste:GridPaste ) : void
		{
			if( !text )
			{
				Alert.show( "Cannot paste empty text", "Paste" );
				return;
			}
			
			var dist:ArrayCollection = new ArrayCollection();
			
			// TODO : array of arrays
			var rows:Array = text.split( '\n' );
			for each( var row:String  in rows )
			{
				// split by tabs
				var cells:Array = row.split( '\t' );
				dist.addItem( cells );
			}
			
			gridPaste.dist = dist;
			sendNotification( Notifications.PASTE_CELL_DISTRIBUTION, gridPaste );		
		}
	}
}