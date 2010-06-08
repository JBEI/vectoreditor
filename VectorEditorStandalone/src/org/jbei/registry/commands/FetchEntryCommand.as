package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.proxies.RegistryAPIProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class FetchEntryCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			ApplicationFacade.getInstance().registryServiceProxy.fetchEntry(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
		}
	}
}
