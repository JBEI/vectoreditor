package org.jbei.registry.proxies
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
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
		public function fetchSequence(sessionId:String, entryId:String):void
		{
            service.getSequence(sessionId, entryId);
		}
		
		public function saveSequence(sessionId:String, entryId:String, featuredDNASequence:FeaturedDNASequence):void
		{
            service.saveSequence(sessionId, entryId, featuredDNASequence);
		}
		
		public function fetchUserPreferences(sessionId:String):void
		{
            service.getUserPreferences(sessionId);
		}
		
		public function saveUserPreferences(sessionId:String, userPreferences:UserPreferences):void
		{
            service.saveUserPreferences(sessionId, userPreferences);
		}
		
		public function fetchUserRestrictionEnzymes(sessionId:String):void
		{
            service.getUserRestrictionEnzymes(sessionId);
		}
		
		public function saveUserRestrictionEnzymes(sessionId:String, userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
            service.saveUserRestrictionEnzymes(sessionId, userRestrictionEnzymes);
		}
		
        public function hasWritablePermissions(sessionId:String, entryId:String):void
        {
            service.hasWritablePermissions(sessionId, entryId);
        }
        
		public function generateGenBank(sessionId:String, featuredDNASequence:FeaturedDNASequence, name:String, isCircular:Boolean):void
		{
            service.generateGenBank(sessionId, featuredDNASequence, name, isCircular);
		}
		
        public function parseSequenceFile(data:String):void
        {
            service.parseSequenceFile(data);
        }
        
        public function generateSequenceFile(featuredDNASequence:FeaturedDNASequence):void
        {
            service.generateSequenceFile(featuredDNASequence);
        }
        
		// Protected Methods
		protected override function onServiceFault(event:FaultEvent):void
		{
			sendNotification(Notifications.APPLICATION_FAILURE, "Service call failed!\n" + event.fault.faultString);
		}
		
		protected override function registerServiceOperations():void
		{
			// Entry
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
            
            // File
            service.parseSequenceFile.addEventListener(ResultEvent.RESULT, onParseSequenceFileResult);
            service.generateSequenceFile.addEventListener(ResultEvent.RESULT, onGenerateSequenceFileResult);
		}
		
		// Private Methods: Response handlers
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
		
        private function onParseSequenceFileResult(event:ResultEvent):void
        {
            if(event.result == null) {
                Alert.show("Failed to parse sequence file", "Failed to parse");
                
                return;
            }
            
            updateSequence(event.result as FeaturedDNASequence);
        }
        
        private function onGenerateSequenceFileResult(event:ResultEvent):void
        {
            if(event.result == null) {
                Alert.show("Failed to parse sequence file", "Failed to parse");
                
                return;
            }
            
            sendNotification(Notifications.DATA_FETCHED);
            
            sendNotification(Notifications.SEQUENCE_GENERATED, event.result as String);
        }
        
		// Private Methods
		private function updateSequence(featuredDNASequence:FeaturedDNASequence):void
		{
            ApplicationFacade.getInstance().updateSequence(featuredDNASequence);
			
			Logger.getInstance().info("Sequence fetched successfully");
		}
		
		private function updateEntryPermissions(hasWritablePermissions:Boolean):void
		{
            ApplicationFacade.getInstance().updateEntryPermissions(hasWritablePermissions);
			
			Logger.getInstance().info("Entry permissions fetched successfully");
		}
		
		private function updateUserPreferences(userPreferences:UserPreferences):void
		{
            ApplicationFacade.getInstance().updateUserPreferences(userPreferences);
			
			Logger.getInstance().info("User preferences fetched successfully");
		}
		
		private function updateUserRestrictionEnzymes(userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
            ApplicationFacade.getInstance().updateUserRestrictionEnzymes(userRestrictionEnzymes);
			
			Logger.getInstance().info("User restriction enzymes fetched successfully");
		}
	}
}
