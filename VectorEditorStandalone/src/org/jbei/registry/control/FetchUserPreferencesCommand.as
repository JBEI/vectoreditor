package org.jbei.registry.control
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.model.UserPreferencesProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class FetchUserPreferencesCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			var userPreferencesProxy:UserPreferencesProxy = ApplicationFacade.getInstance().retrieveProxy(UserPreferencesProxy.NAME) as UserPreferencesProxy;
			
			userPreferencesProxy.fetchUserPreferences("This IS USER TOKEN!");
		}
	}
}
