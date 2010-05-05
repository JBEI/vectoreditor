package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class FetchTracesCommand extends SimpleCommand
	{
		// Public Methods
		public override function execute(notification:INotification):void
		{
			ApplicationFacade.getInstance().registryServiceProxy.fetchTraces(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
		}
	}
}
