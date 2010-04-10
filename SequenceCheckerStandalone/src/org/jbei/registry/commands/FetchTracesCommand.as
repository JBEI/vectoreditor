package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.proxies.TraceAlignmentServiceProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class FetchTracesCommand extends SimpleCommand
	{
		// Public Methods
		public override function execute(notification:INotification):void
		{
			var traceAlignmentServiceProxy:TraceAlignmentServiceProxy = ApplicationFacade.getInstance().retrieveProxy(TraceAlignmentServiceProxy.NAME) as TraceAlignmentServiceProxy;
			
			traceAlignmentServiceProxy.fetchTraces(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
		}
	}
}
