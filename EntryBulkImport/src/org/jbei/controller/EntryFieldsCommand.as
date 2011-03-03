package org.jbei.controller
{
	import org.jbei.Notifications;
	import org.jbei.view.EntryType;
	import org.jbei.model.RegistryAPIProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * Simple command for activities associated with the entry type fields
	 */
	public class EntryFieldsCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var type : EntryType = notification.getBody() as EntryType;
			var proxy : RegistryAPIProxy = facade.retrieveProxy( RegistryAPIProxy.NAME ) as RegistryAPIProxy;
			
			if( proxy == null )
			{
				sendNotification( Notifications.FAILURE );
				return;
			}
			
			proxy.loadEntryFields( type );
		}
	}
}