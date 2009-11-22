package org.jbei.registry.model
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.registry.model.vo.UserPreferences;
	import org.jbei.registry.utils.StandaloneUtils;
	import org.jbei.registry.view.dialogs.PreferencesDialogForm;
	import org.jbei.utils.Logger;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class UserPreferencesProxy extends Proxy
	{
		public static const NAME:String = "UserPreferencesProxy";
		private static const USER_PREFERENCES_SERVICE_NAME:String = "UserPreferencesService";
		
		private var _userPreferences:UserPreferences;
		private var userPreferencesService:RemoteObject;
		
		// Constructor
		public function UserPreferencesProxy()
		{
			super(NAME);
			
			userPreferencesService = new RemoteObject(USER_PREFERENCES_SERVICE_NAME);
			userPreferencesService.addEventListener(FaultEvent.FAULT, onUserPreferencesServiceFault);
			userPreferencesService.addEventListener(InvokeEvent.INVOKE, onUserPreferencesServiceInvoke);
			userPreferencesService.fetchUserPreferences.addEventListener(ResultEvent.RESULT, onUserPreferencesServiceFetchResult);
			userPreferencesService.saveUserPreferences.addEventListener(ResultEvent.RESULT, onUserPreferencesServiceSaveResult);
		}
		
		// Properties
		public function get userPreferences():UserPreferences
		{
			return _userPreferences;
		}
		
		// Public Methods
		public function fetchUserPreferences(authToken:String):void
		{
			CONFIG::standalone {
				fetchStandaloneUserPreferences();
				return;
			}
			
			userPreferencesService.fetchUserPreferences(authToken);
		}
		
		public function saveUserPreferences(authToken:String, userPreferences:UserPreferences):void
		{
			CONFIG::standalone {
				updateUserPreferences(userPreferences);
				
				return;
			}
			
			userPreferencesService.saveUserPreferences(authToken, userPreferences);
		}
		
		// Private Methods
		private function onUserPreferencesServiceFault(event:FaultEvent):void
		{
			sendNotification(ApplicationFacade.APPLICATION_FAILURE, "UserPreferencesService failed!");
		}
		
		private function onUserPreferencesServiceInvoke(event:InvokeEvent):void
		{
			sendNotification(ApplicationFacade.FETCHING_DATA, "Loading User Preferences...");
		}
		
		private function onUserPreferencesServiceFetchResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(ApplicationFacade.APPLICATION_FAILURE, "Failed to fetch user preferences!");
				return;
			}
			
			sendNotification(ApplicationFacade.DATA_FETCHED);
			
			updateUserPreferences(event.result as UserPreferences);
		}
		
		private function onUserPreferencesServiceSaveResult(event:ResultEvent):void
		{
			sendNotification(ApplicationFacade.DATA_FETCHED);
			
			sendNotification(ApplicationFacade.USER_PREFERENCES_CHANGED);
			
			Logger.getInstance().info("User preferences saved successfully");
		}
		
		private function fetchStandaloneUserPreferences():void
		{
			updateUserPreferences(StandaloneUtils.standaloneUserPreferences());
		}
		
		private function updateUserPreferences(userPreferences:UserPreferences):void
		{
			_userPreferences = userPreferences;
			
			sendNotification(ApplicationFacade.USER_PREFERENCES_FETCHED);
			
			Logger.getInstance().info("User preferences fetched successfully");
		}
	}
}
