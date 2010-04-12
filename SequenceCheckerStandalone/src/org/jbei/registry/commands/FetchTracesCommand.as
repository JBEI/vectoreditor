package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.proxies.SequenceCheckerServiceProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class FetchTracesCommand extends SimpleCommand
	{
		// Public Methods
		public override function execute(notification:INotification):void
		{
			var sequenceCheckerServiceProxy:SequenceCheckerServiceProxy = ApplicationFacade.getInstance().retrieveProxy(SequenceCheckerServiceProxy.NAME) as SequenceCheckerServiceProxy;
			
			sequenceCheckerServiceProxy.fetchTraces(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
		}
	}
}
