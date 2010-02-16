package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.proxies.UserPreferencesProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class FetchUserPreferencesCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			var userPreferencesProxy:UserPreferencesProxy = ApplicationFacade.getInstance().retrieveProxy(UserPreferencesProxy.NAME) as UserPreferencesProxy;
			
			userPreferencesProxy.fetchUserPreferences(ApplicationFacade.getInstance().sessionId);
		}
	}
}
