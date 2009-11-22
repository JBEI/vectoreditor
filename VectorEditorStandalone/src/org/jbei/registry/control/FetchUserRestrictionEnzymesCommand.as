package org.jbei.registry.control
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.registry.model.UserRestrictionEnzymesProxy;
	import org.jbei.registry.model.vo.UserRestrictionEnzymes;
	import org.jbei.utils.Logger;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class FetchUserRestrictionEnzymesCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			var userRestrictionEnzymesProxy:UserRestrictionEnzymesProxy = ApplicationFacade.getInstance().retrieveProxy(UserRestrictionEnzymesProxy.NAME) as UserRestrictionEnzymesProxy;
			
			userRestrictionEnzymesProxy.fetchUserRestrictionEnzymes("This IS USER TOKEN!");
		}
	}
}
