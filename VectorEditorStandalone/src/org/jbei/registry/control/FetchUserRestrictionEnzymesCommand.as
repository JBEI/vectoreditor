package org.jbei.registry.control
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.proxies.UserRestrictionEnzymesProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class FetchUserRestrictionEnzymesCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			var userRestrictionEnzymesProxy:UserRestrictionEnzymesProxy = ApplicationFacade.getInstance().retrieveProxy(UserRestrictionEnzymesProxy.NAME) as UserRestrictionEnzymesProxy;
			
			userRestrictionEnzymesProxy.fetchUserRestrictionEnzymes(ApplicationFacade.getInstance().sessionId);
		}
	}
}
