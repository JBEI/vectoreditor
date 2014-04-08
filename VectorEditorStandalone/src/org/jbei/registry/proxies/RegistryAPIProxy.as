package org.jbei.registry.proxies
{
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.jbei.lib.utils.Logger;
    import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.UserPreferences;
	import org.jbei.registry.models.UserRestrictionEnzymes;
	import org.jbei.registry.models.VectorEditorProject;

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
        public function createVectorEditorProject(sessionId:String, project:VectorEditorProject):void
        {
            sendNotification(Notifications.LOCK, "Creating project on the server ...");
            
            service.createVectorEditorProject(sessionId, project);
        }
        
        public function getVectorEditorProject(sessionId:String, projectId:String):void
        {
            sendNotification(Notifications.LOCK, "Fetching project from the server ...");
            
            service.getVectorEditorProject(sessionId, projectId);
        }
        
        public function saveVectorEditorProject(sessionId:String, project:VectorEditorProject):void
        {
            sendNotification(Notifications.LOCK, "Saving project to the server ...");
            
            service.saveVectorEditorProject(sessionId, project);
        }
        
		public function fetchSequence(sessionId:String, entryId:String):void
		{
            sendNotification(Notifications.LOCK, "Fetching sequence ...");

            service.getSequence(sessionId, entryId);
		}
		
		public function saveSequence(sessionId:String, entryId:String, featuredDNASequence:FeaturedDNASequence):void
		{
            sendNotification(Notifications.LOCK, "Saving sequence ...");
            
            service.saveSequence(sessionId, entryId, featuredDNASequence);
		}
		
		public function fetchUserPreferences(sessionId:String):void
		{
            sendNotification(Notifications.LOCK, "Fetching user preferences ...");
            
            service.getUserPreferences(sessionId);
		}
		
		public function saveUserPreferences(sessionId:String, userPreferences:UserPreferences):void
		{
            sendNotification(Notifications.LOCK, "Saving user preferences ...");
            
            service.saveUserPreferences(sessionId, userPreferences);
		}
		
		public function fetchUserRestrictionEnzymes(sessionId:String):void
		{
            sendNotification(Notifications.LOCK, "Fetching user enzymes ...");
            
            service.getUserRestrictionEnzymes(sessionId);
		}
		
		public function saveUserRestrictionEnzymes(sessionId:String, userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
            CONFIG::standalone {
                return;
            }
            
            sendNotification(Notifications.LOCK, "Saving user enzymes ...");
            
            service.saveUserRestrictionEnzymes(sessionId, userRestrictionEnzymes);
		}
		
        public function hasWritablePermissions(sessionId:String, entryId:String):void
        {
            sendNotification(Notifications.LOCK);
            
            service.hasWritablePermissions(sessionId, entryId);
        }
        
		public function generateSequence(sessionId:String, featuredDNASequence:FeaturedDNASequence):void
		{
            sendNotification(Notifications.LOCK);
            
            service.generateGenBank(sessionId, featuredDNASequence, featuredDNASequence.name, featuredDNASequence.isCircular);
		}
		
        public function parseSequenceFile(data:String):void
        {
            sendNotification(Notifications.LOCK, "Parsing sequence file ...");
            
            service.parseSequenceFile(data);
        }
        
        public function generateSequenceFile(featuredDNASequence:FeaturedDNASequence):void
        {
            sendNotification(Notifications.LOCK, "Generating sequence file ...");
            
            service.generateSequenceFile(featuredDNASequence);
        }
        
		// Protected Methods
		protected override function onServiceFault(event:FaultEvent):void
		{
			sendNotification(Notifications.APPLICATION_FAILURE, "Service call failed!\n" + event.fault.faultString);
		}
		
		protected override function registerServiceOperations():void
		{
            // Project
            service.createVectorEditorProject.addEventListener(ResultEvent.RESULT, onCreateVectorEditorProjectResult);
            service.getVectorEditorProject.addEventListener(ResultEvent.RESULT, onGetVectorEditorProjectResult);
            service.saveVectorEditorProject.addEventListener(ResultEvent.RESULT, onSaveVectorEditorProjectResult);
            
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
        private function onCreateVectorEditorProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to create project on the server!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            sendNotification(Notifications.PROJECT_UPDATED, event.result as VectorEditorProject);
            
            sendNotification(Notifications.ACTION_MESSAGE, "Project created successfully");
        }
        
        private function onGetVectorEditorProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch project from the server!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            sendNotification(Notifications.PROJECT_UPDATED, event.result as VectorEditorProject);
            
            sendNotification(Notifications.ACTION_MESSAGE, "Project fetched successfully");
        }
        
        private function onSaveVectorEditorProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to save project on the server!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            sendNotification(Notifications.PROJECT_UPDATED, event.result as VectorEditorProject);
            
            sendNotification(Notifications.ACTION_MESSAGE, "Project saved successfully");
        }
        
		private function onGetSequenceResult(event:ResultEvent):void
		{
			sendNotification(Notifications.UNLOCK);
			
			updateSequence(event.result as FeaturedDNASequence);
		}
		
		private function onHasWritablePermissionsResult(event:ResultEvent):void {
			if(event.result == null) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch entry permissions! Invalid response result type!");
				
				return;
			}
			
            sendNotification(Notifications.UNLOCK);
			
			updateEntryPermissions(event.result);
		}
		
		private function onGetUserPreferencesResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch user preferences!");
				
				return;
			}
			
            sendNotification(Notifications.UNLOCK);
			
			updateUserPreferences(event.result as UserPreferences);
		}
		
		private function onSaveUserPreferencesResult(event:ResultEvent):void
		{
            if(!event.result || event.result != true) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to save user preferences!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
			
			sendNotification(Notifications.ACTION_MESSAGE, "User preferences has been saved");
            
            ApplicationFacade.getInstance().updateUserPreferences(ApplicationFacade.getInstance().userPreferences);
		}
		
		private function onGetUserRestrictionEnzymesResult(event:ResultEvent):void
		{
			if(!event.result) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch user restriction enzymes!");
				
				return;
			}
			
            sendNotification(Notifications.UNLOCK);
			
			updateUserRestrictionEnzymes(event.result as UserRestrictionEnzymes);
		}
		
		private function onSaveUserRestrictionEnzymesResult(event:ResultEvent):void
		{
            sendNotification(Notifications.UNLOCK);
			
			sendNotification(Notifications.USER_RESTRICTION_ENZYMES_CHANGED);
            
            sendNotification(Notifications.ACTION_MESSAGE, "User restriction enzymes saved");
			
			Logger.getInstance().info("User restriction enzymes saved successfully");
		}
		
		private function onSaveSequenceResult(event:ResultEvent):void
		{
			if(event.result == false) {
				Alert.show("Failed to save sequence.\n\nIf you have any sequence feature attribute values " +
                    "that contain more than 4095 characters (e.g. SBOL_DS_nucleotides attributes from " +
                    "importing an SBOL file and preserving SBOL information), those attributes or the features " +
                    "they apply to need to be removed.", "Save error");
                sendNotification(Notifications.UNLOCK);
                
				return;
			}
			
            sendNotification(Notifications.UNLOCK);
			
			Logger.getInstance().info("Sequence saved successfully");
		}
		
		private function onGenerateGenBankResult(event:ResultEvent):void
		{
			if(event.result == null) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Failed to generate genbank!");
				
				return;
			}
			
            sendNotification(Notifications.UNLOCK);
			
			sendNotification(Notifications.SEQUENCE_GENERATED_AND_FETCHED, event.result as String);
			
			Logger.getInstance().info("Genbank file generated and fetched successfully");
		}
		
        private function onParseSequenceFileResult(event:ResultEvent):void
        {
            sendNotification(Notifications.UNLOCK);
            
            if(!event.result) {
                Alert.show("Failed to parse sequence file", "Failed to parse");
                
                return;
            }
            
            sendNotification(Notifications.ACTION_MESSAGE, "Sequence parsed successfully");
            
            sendNotification(Notifications.SEQUENCE_UPDATED, event.result as FeaturedDNASequence);
        }
        
        private function onGenerateSequenceFileResult(event:ResultEvent):void
        {
            if(event.result == null) {
                Alert.show("Failed to parse sequence file", "Failed to parse");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            var notificationBody:Object = {fileString:event.result as String, fileExtension:".gb"};
            sendNotification(Notifications.SEQUENCE_FILE_GENERATED, notificationBody);
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
