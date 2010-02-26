package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.proxies.MainServiceProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class FetchUserRestrictionEnzymesCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			var mainServiceProxy:MainServiceProxy = ApplicationFacade.getInstance().retrieveProxy(MainServiceProxy.NAME) as MainServiceProxy;
			
			mainServiceProxy.fetchUserRestrictionEnzymes(ApplicationFacade.getInstance().sessionId);
		}
	}
}
