package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.proxies.RegistryAPIProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class FetchEntryPermissionsCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			ApplicationFacade.getInstance().registryServiceProxy.hasWritablePermissions(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
		}
	}
}