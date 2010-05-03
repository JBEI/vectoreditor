package org.jbei.registry.proxies
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.UserPreferences;
	import org.jbei.registry.models.UserRestrictionEnzymes;
	import org.jbei.registry.utils.StandaloneUtils;

	public class MainServiceProxy extends AbstractServiceProxy
	{
		public static const NAME:String = "MainServiceProxy";
		private static const MAIN_SERVICE_NAME:String = "VectorEditorService";
		
		private var _userPreferences:UserPreferences;
		
		// Constructor
		public function MainServiceProxy()
		{
			super(NAME, MAIN_SERVICE_NAME);
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
			
			service.getUserPreferences(authToken);
		}
		
		public function saveUserPreferences(authToken:String, userPreferences:UserPreferences):void
		{
			CONFIG::standalone {
				updateUserPreferences(userPreferences);
				
				return;
			}
			
			service.saveUserPreferences(authToken, userPreferences);
		}
		
		public function fetchUserRestrictionEnzymes(authToken:String):void
		{
			CONFIG::standalone {
				fetchStandaloneUserRestrictionEnzymes();
				return;
			}
			
			service.getUserRestrictionEnzymes(authToken);
		}
		
		public function saveUserRestrictionEnzymes(authToken:String, userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
			CONFIG::standalone {
				updateUserRestrictionEnzymes(userRestrictionEnzymes);
				
				return;
			}
			
			service.saveUserRestrictionEnzymes(authToken, userRestrictionEnzymes);
			
			RestrictionEnzymeGroupManager.instance.activeGroup = userRestrictionEnzymes.activeGroup;
		}
		
		public function saveFeaturedDNASequence(authToken:String, entryId:String, featuredDNASequence:FeaturedDNASequence):void
		{
			CONFIG::standalone {
				return;
			}
			
			service.saveFeaturedDNASequence(authToken, entryId, featuredDNASequence);
		}
		
		public function generateGenBank(authToken:String, featuredDNASequence:FeaturedDNASequence, name:String, isCircular:Boolean):void
		{
			CONFIG::standalone {
				return;
			}
			
			service.generateGenBank(authToken, featuredDNASequence, name, isCircular);
		}
		
		// Protected Methods
		protected override function onServiceFault(event:FaultEvent):void
		{
			sendNotification(Notifications.APPLICATION_FAILURE, serviceName + " failed!");
		}
		
		protected override function onServiceInvoke(event:InvokeEvent):void
		{
			sendNotification(Notifications.FETCHING_DATA, "Calling " + serviceName + "...");
		}
		
		protected override function registerServiceOperations():void
		{
			// User Preferences
			service.getUserPreferences.addEventListener(ResultEvent.RESULT, onUserPreferencesServiceFetchResult);
			service.saveUserPreferences.addEventListener(ResultEvent.RESULT, onUserPreferencesServiceSaveResult);
			
			// Restriction Enzymes
			service.getUserRestrictionEnzymes.addEventListener(ResultEvent.RESULT, onUserRestrictionEnzymesServiceFetchResult);
			service.saveUserRestrictionEnzymes.addEventListener(ResultEvent.RESULT, onUserRestrictionEnzymesServiceSaveResult);
			
			// FeaturedDNASequence
			service.saveFeaturedDNASequence.addEventListener(ResultEvent.RESULT, onSaveFeaturedDNASequenceResult);
			
			// GenBank
			service.generateGenBank.addEventListener(ResultEvent.RESULT, onGenerateGenBankResult);
		}
		
		// Private Methods
		private function onUserPreferencesServiceFetchResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch user preferences!");
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateUserPreferences(event.result as UserPreferences);
		}
		
		private function onUserPreferencesServiceSaveResult(event:ResultEvent):void
		{
			sendNotification(Notifications.DATA_FETCHED);
			
			sendNotification(Notifications.USER_PREFERENCES_CHANGED);
			
			Logger.getInstance().info("User preferences saved successfully");
		}
		
		private function fetchStandaloneUserPreferences():void
		{
			updateUserPreferences(StandaloneUtils.standaloneUserPreferences());
		}
		
		private function updateUserPreferences(userPreferences:UserPreferences):void
		{
			_userPreferences = userPreferences;
			
			sendNotification(Notifications.USER_PREFERENCES_FETCHED);
			
			Logger.getInstance().info("User preferences fetched successfully");
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
		
		private function onSaveFeaturedDNASequenceResult(event:ResultEvent):void
		{
			if(event.result == false) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to save sequence!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			sendNotification(Notifications.SEQUENCE_SAVED);
			
			Logger.getInstance().info("Sequence saved successfully");
		}
		
		private function onUserRestrictionEnzymesServiceSaveResult(event:ResultEvent):void
		{
			sendNotification(Notifications.DATA_FETCHED);
			
			sendNotification(Notifications.USER_RESTRICTION_ENZYMES_CHANGED);
			
			Logger.getInstance().info("User restriction enzymes saved successfully");
		}
		
		private function onGenerateGenBankResult(event:ResultEvent):void
		{
			if(event.result == null) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to save sequence!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			sendNotification(Notifications.GENBANK_FETCHED, event.result as String);
			
			Logger.getInstance().info("Genbank file generated and fetched successfully");
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
