package org.jbei.controller
{
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.Notifications;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.Application;
	import spark.components.Label;
	import spark.components.TitleWindow;
	
	public class CancelCommand extends SimpleCommand
	{
		private var titleWindow:TitleWindow;
		
		override public function execute( notification : INotification ) : void
		{
//			var urlRequest:URLRequest = new URLRequest(Application.application.url);
//			navigateToURL(urlRequest,"_self");
//			sendNotification( Notifications.START_UP, ApplicationFacade.getInstance().application );
//			var values:ArrayCollection = notification.getBody() as ArrayCollection;
//			if( values == null )
//			{
//				trace( "Null values received for save" );
//				return;
//			}
//			trace( "Save1 : " + values.length );
//			var proxy:RegistryAPIProxy = facade.retrieveProxy( RegistryAPIProxy.NAME ) as RegistryAPIProxy;
//			var ret:Array = proxy.saveParts( values );
//			if( ret != null )
//				trace( "Received back " + ret.length ) ;
			
//		
			Alert.show("Hello World", "Title", Alert.OK );
		}
		
		private function titleWindow_close( event:CloseEvent ) : void
		{
			titleWindow.removeAllElements();
		}
	}
}