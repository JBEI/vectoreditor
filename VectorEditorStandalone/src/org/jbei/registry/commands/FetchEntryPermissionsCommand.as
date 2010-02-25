package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.proxies.EntriesProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class FetchEntryPermissionsCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			var entriesProxy:EntriesProxy = ApplicationFacade.getInstance().retrieveProxy(EntriesProxy.NAME) as EntriesProxy;
			
			entriesProxy.hasWritablePermissions(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
		}
	}
}