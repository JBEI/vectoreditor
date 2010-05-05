package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class FetchRestrictionEnzymesCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			ApplicationFacade.getInstance().registryServiceProxy.fetchRestrictionEnzymes(ApplicationFacade.getInstance().sessionId);
		}
	}
}
