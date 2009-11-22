package org.jbei.registry.control
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.registry.model.UserPreferencesProxy;
	import org.jbei.utils.Logger;
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
