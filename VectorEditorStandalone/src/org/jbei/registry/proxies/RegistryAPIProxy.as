package org.jbei.registry.proxies
{
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.UserPreferences;
	import org.jbei.registry.models.UserRestrictionEnzymes;
	import org.jbei.registry.utils.StandaloneUtils;

    /**
     * @author Zinovii Dmytriv
     */
	public class RegistryAPIProxy extends AbstractServiceProxy
	{
		public static const REMOTE_SERVICE_NAME:String = "RegistryAMFAPI";
		public static const PROXY_NAME:String = "RegistryAPIProxy";
		
		// Constructor
		public function RegistryAPIProxy()
		{
			super(PROXY_NAME, REMOTE_SERVICE_NAME);
		}
		
		// Public Methods
		public function fetchEntry(sessionId:String, entryId:String):void
		{
			CONFIG::standalone {
				updateEntry(StandaloneUtils.standaloneEntry() as Entry);
				
				return;
			}
			
			service.getEntry(sessionId, entryId);
		}
		
		public function hasWritablePermissions(sessionId:String, entryId:String):void
		{
			CONFIG::standalone {
				updateEntryPermissions(true);
				
				return;
			}
			
			service.hasWritablePermissions(sessionId, entryId);
		}
		
		public function fetchSequence(sessionId:String, entryId:String):void
		{
			CONFIG::standalone {
				updateSequence(StandaloneUtils.standaloneSequence() as FeaturedDNASequence);
				
				return;
			}
			
			service.getSequence(sessionId, entryId);
		}
		
		public function saveSequence(sessionId:String, entryId:String, featuredDNASequence:FeaturedDNASequence):void
		{
			CONFIG::standalone {
				return;
			}
			
			service.saveSequence(sessionId, entryId, featuredDNASequence);
		}
		
		public function fetchUserPreferences(sessionId:String):void
		{
			CONFIG::standalone {
				updateUserPreferences(StandaloneUtils.standaloneUserPreferences());
				
				return;
			}
			
			service.getUserPreferences(sessionId);
		}
		
		public function saveUserPreferences(sessionId:String, userPreferences:UserPreferences):void
		{
			CONFIG::standalone {
				updateUserPreferences(userPreferences);
				
				return;
			}
			
			service.saveUserPreferences(sessionId, userPreferences);
		}
		
		public function fetchUserRestrictionEnzymes(sessionId:String):void
		{
			CONFIG::standalone {
				updateUserRestrictionEnzymes(StandaloneUtils.standaloneUserRestrictionEnzymes());
				
				return;
			}
			
			service.getUserRestrictionEnzymes(sessionId);
		}
		
		public function saveUserRestrictionEnzymes(sessionId:String, userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
			CONFIG::standalone {
				updateUserRestrictionEnzymes(userRestrictionEnzymes);
				
				return;
			}
			
			service.saveUserRestrictionEnzymes(sessionId, userRestrictionEnzymes);
		}
		
		public function generateGenBank(sessionId:String, featuredDNASequence:FeaturedDNASequence, name:String, isCircular:Boolean):void
		{
			CONFIG::standalone {
				return;
			}
			
			service.generateGenBank(sessionId, featuredDNASequence, name, isCircular);
		}
		
		public function fetchRestrictionEnzymes(sessionId:String):void
		{
			CONFIG::standalone {
				updateRestrictionEnzymes(StandaloneUtils.standaloneRestrictionEnzymes());
				
				return;
			}
			
			service.getRestrictionEnzymes(sessionId);
		}
		
		// Protected Methods
		protected override function onServiceFault(event:FaultEvent):void
		{
			sendNotification(Notifications.APPLICATION_FAILURE, "Service call failed!\n" + event.fault.faultString);
		}
		
		protected override function registerServiceOperations():void
		{
			// Entry
			service.getEntry.addEventListener(ResultEvent.RESULT, onGetEntryResult);
			service.hasWritablePermissions.addEventListener(ResultEvent.RESULT, onHasWritablePermissionsResult);
			
			// Sequence
			service.saveSequence.addEventListener(ResultEvent.RESULT, onSaveSequenceResult);
			service.getSequence.addEventListener(ResultEvent.RESULT, onGetSequenceResult);
			
			// User Preferences
			service.getUserPreferences.addEventListener(ResultEvent.RESULT, onGetUserPreferencesResult);
			service.saveUserPreferences.addEventListener(ResultEvent.RESULT, onSaveUserPreferencesResult);
			
			// Restriction Enzymes
			service.getUserRestrictionEnzymes.addEventListener(ResultEvent.RESULT, onGetUserRestrictionEnzymesResult);
			service.saveUserRestrictionEnzymes.addEventListener(ResultEvent.RESULT, onSaveUserRestrictionEnzymesResult);
			
			// GenBank
			service.generateGenBank.addEventListener(ResultEvent.RESULT, onGenerateGenBankResult);
			
			// Restriction Enzymes Database
			service.getRestrictionEnzymes.addEventListener(ResultEvent.RESULT, onGetRestrictionEnzymesResult);
		}
		
		// Private Methods: Response handlers
		private function onGetEntryResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch entry! Invalid response result type!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateEntry(event.result as Entry);
		}
		
		private function onGetSequenceResult(event:ResultEvent):void
		{
			sendNotification(Notifications.DATA_FETCHED);
			
			updateSequence(event.result as FeaturedDNASequence);
		}
		
		private function onHasWritablePermissionsResult(event:ResultEvent):void {
			if(event.result == null) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch entry permissions! Invalid response result type!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateEntryPermissions(event.result);
		}
		
		private function onGetUserPreferencesResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch user preferences!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateUserPreferences(event.result as UserPreferences);
		}
		
		private function onSaveUserPreferencesResult(event:ResultEvent):void
		{
			sendNotification(Notifications.DATA_FETCHED);
			
			sendNotification(Notifications.USER_PREFERENCES_CHANGED);
            sendNotification(Notifications.ACTION_MESSAGE, "User preferences has been saved");
			
			Logger.getInstance().info("User preferences saved successfully");
		}
		
		private function onGetUserRestrictionEnzymesResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch user restriction enzymes!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateUserRestrictionEnzymes(event.result as UserRestrictionEnzymes);
		}
		
		private function onSaveUserRestrictionEnzymesResult(event:ResultEvent):void
		{
			sendNotification(Notifications.DATA_FETCHED);
			
			sendNotification(Notifications.USER_RESTRICTION_ENZYMES_CHANGED);
            
            sendNotification(Notifications.ACTION_MESSAGE, "User restriction enzymes saved");
			
			Logger.getInstance().info("User restriction enzymes saved successfully");
		}
		
		private function onSaveSequenceResult(event:ResultEvent):void
		{
			if(event.result == false) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to save sequence!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			sendNotification(Notifications.SEQUENCE_SAVED);
            sendNotification(Notifications.ACTION_MESSAGE, "Sequence has been saved");
			
			Logger.getInstance().info("Sequence saved successfully");
		}
		
		private function onGenerateGenBankResult(event:ResultEvent):void
		{
			if(event.result == null) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to generate genbank!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			sendNotification(Notifications.GENBANK_FETCHED, event.result as String);
			
			Logger.getInstance().info("Genbank file generated and fetched successfully");
		}
		
		private function onGetRestrictionEnzymesResult(event:ResultEvent):void
		{
			if(event.result == null) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to get restriction enzymes database!");
				
				return;
			}
			
			sendNotification(Notifications.DATA_FETCHED);
			
			updateRestrictionEnzymes(event.result as ArrayCollection);
		}
		
		// Private Methods
		private function updateEntry(entry:Entry):void
		{
			sendNotification(Notifications.ENTRY_FETCHED, entry);
			
			Logger.getInstance().info("Entry fetched successfully");
		}
		
		private function updateSequence(featuredDNASequence:FeaturedDNASequence):void
		{
			sendNotification(Notifications.SEQUENCE_FETCHED, featuredDNASequence);
			
			Logger.getInstance().info("Sequence fetched successfully");
		}
		
		private function updateRestrictionEnzymes(enzymes:ArrayCollection):void
		{
			sendNotification(Notifications.RESTRICTION_ENZYMES_FETCHED, enzymes);
			
			Logger.getInstance().info("Restriction Enzymes fetched successfully");
		}
		
		private function updateEntryPermissions(hasWritablePermissions:Boolean):void
		{
			sendNotification(Notifications.ENTRY_PERMISSIONS_FETCHED, hasWritablePermissions);
			
			Logger.getInstance().info("Entry permissions fetched successfully");
		}
		
		private function updateUserPreferences(userPreferences:UserPreferences):void
		{
			sendNotification(Notifications.USER_PREFERENCES_FETCHED, userPreferences);
			
			Logger.getInstance().info("User preferences fetched successfully");
		}
		
		private function updateUserRestrictionEnzymes(userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
			sendNotification(Notifications.USER_RESTRICTION_ENZYMES_FETCHED, userRestrictionEnzymes);
			
			Logger.getInstance().info("User restriction enzymes fetched successfully");
		}
	}
}
