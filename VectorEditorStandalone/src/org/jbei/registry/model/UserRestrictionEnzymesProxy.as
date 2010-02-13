package org.jbei.registry.model
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.jbei.registry.Notifications;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.model.vo.UserRestrictionEnzymes;
	import org.jbei.registry.utils.StandaloneUtils;
	import org.jbei.utils.Logger;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class UserRestrictionEnzymesProxy extends Proxy
	{
		public static const NAME:String = "UserRestrictionEnzymesProxy";
		private static const USER_RESTRICTION_ENZYMES_SERVICE_NAME:String = "UserRestrictionEnzymesService";
		
		private var userRestrictionEnzymesService:RemoteObject;
		
		// Constructor
		public function UserRestrictionEnzymesProxy()
		{
			super(NAME);
			
			userRestrictionEnzymesService = new RemoteObject(USER_RESTRICTION_ENZYMES_SERVICE_NAME);
			userRestrictionEnzymesService.addEventListener(FaultEvent.FAULT, onUserRestrictionEnzymesServiceFault);
			userRestrictionEnzymesService.addEventListener(InvokeEvent.INVOKE, onUserRestrictionEnzymesServiceInvoke);
			userRestrictionEnzymesService.fetchUserRestrictionEnzymes.addEventListener(ResultEvent.RESULT, onUserRestrictionEnzymesServiceFetchResult);
			userRestrictionEnzymesService.saveUserRestrictionEnzymes.addEventListener(ResultEvent.RESULT, onUserRestrictionEnzymesServiceSaveResult);
		}
		
		// Public Methods
		public function fetchUserRestrictionEnzymes(authToken:String):void
		{
			CONFIG::standalone {
				fetchStandaloneUserRestrictionEnzymes();
				return;
			}
			
			userRestrictionEnzymesService.fetchUserRestrictionEnzymes(authToken);
		}
		
		public function saveUserRestrictionEnzymes(authToken:String, userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
			CONFIG::standalone {
				updateUserRestrictionEnzymes(userRestrictionEnzymes);
				
				return;
			}
			
			userRestrictionEnzymesService.saveUserRestrictionEnzymes(authToken, userRestrictionEnzymes);
			
			RestrictionEnzymeGroupManager.instance.activeGroup = userRestrictionEnzymes.activeGroup;
		}
		
		// Private Methods
		private function onUserRestrictionEnzymesServiceFault(event:FaultEvent):void
		{
			sendNotification(Notifications.APPLICATION_FAILURE, "UserRestrictionEnzymesService failed!");
		}
		
		private function onUserRestrictionEnzymesServiceInvoke(event:InvokeEvent):void
		{
			sendNotification(Notifications.FETCHING_DATA, "Loading User Restriction Enzymes...");
		}
		
		private function onUserRestrictionEnzymesServiceFetchResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch user restriction enzymes!");
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateUserRestrictionEnzymes(event.result as UserRestrictionEnzymes);
		}
		
		private function onUserRestrictionEnzymesServiceSaveResult(event:ResultEvent):void
		{
			sendNotification(Notifications.DATA_FETCHED);
			
			sendNotification(Notifications.USER_RESTRICTION_ENZYMES_CHANGED);
			
			Logger.getInstance().info("User restriction enzymes saved successfully");
		}
		
		private function fetchStandaloneUserRestrictionEnzymes():void
		{
			updateUserRestrictionEnzymes(StandaloneUtils.standaloneUserRestrictionEnzymes());
		}
		
		private function updateUserRestrictionEnzymes(userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
			if(userRestrictionEnzymes) {
				RestrictionEnzymeGroupManager.instance.userGroups = userRestrictionEnzymes.groups;
				if(userRestrictionEnzymes.activeGroup.length > 0) {
					RestrictionEnzymeGroupManager.instance.activeGroup = userRestrictionEnzymes.activeGroup;
				}
			}
			
			sendNotification(Notifications.USER_RESTRICTION_ENZYMES_FETCHED);
			
			Logger.getInstance().info("User restriction enzymes fetched successfully");
		}
	}
}
