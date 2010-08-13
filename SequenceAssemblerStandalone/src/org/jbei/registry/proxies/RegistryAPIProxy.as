package org.jbei.registry.proxies
{
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.InvokeEvent;
    import mx.rpc.events.ResultEvent;
    
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.AssemblyProject;
    import org.jbei.registry.models.PermutationSet;

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
        public function createAssemblyProject(sessionId:String, project:AssemblyProject):void
        {
            sendNotification(Notifications.LOCK, "Creating project on the server ...");
            
            service.createAssemblyProject(sessionId, project);
        }
        
        public function getAssemblyProject(sessionId:String, projectId:String):void
        {
            sendNotification(Notifications.LOCK, "Fetching project from the server ...");
            
            service.getAssemblyProject(sessionId, projectId);
        }
        
        public function saveAssemblyProject(sessionId:String, project:AssemblyProject):void
        {
            sendNotification(Notifications.LOCK, "Saving project to the server ...");
            
            service.saveAssemblyProject(sessionId, project);
        }
        
        public function assembleAssemblyProject(sessionId:String, project:AssemblyProject):void
        {
            sendNotification(Notifications.LOCK, "Assembling project ...");
            
            service.assembleAssemblyProject(sessionId, project);
        }
        
        public function parseSequenceFile(data:String):void
        {
            sendNotification(Notifications.LOCK, "Parsing sequence file ...");
            
            service.parseSequenceFile(data);
        }
        
        // Protected Methods
        protected override function onServiceFault(event:FaultEvent):void
        {
            sendNotification(Notifications.APPLICATION_FAILURE, "Service call failed!\n" + event.fault.faultString);
        }
        
        protected override function registerServiceOperations():void
        {
            service.createAssemblyProject.addEventListener(ResultEvent.RESULT, onCreateAssemblyProjectResult);
            service.getAssemblyProject.addEventListener(ResultEvent.RESULT, onGetAssemblyProjectResult);
            service.saveAssemblyProject.addEventListener(ResultEvent.RESULT, onSaveAssemblyProjectResult);
            service.assembleAssemblyProject.addEventListener(ResultEvent.RESULT, onAssembleAssemblyProjectResult);
            service.parseSequenceFile.addEventListener(ResultEvent.RESULT, onParseSequenceFileResult);
        }
        
        // Private Methods: Response handlers
        private function onCreateAssemblyProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to create project on the server!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            ApplicationFacade.getInstance().loadProject(event.result as AssemblyProject);
            
            sendNotification(Notifications.GLOBAL_ACTION_MESSAGE, "Project created successfully");
        }
        
        private function onGetAssemblyProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch project from the server!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            ApplicationFacade.getInstance().loadProject(event.result as AssemblyProject);
            
            sendNotification(Notifications.GLOBAL_ACTION_MESSAGE, "Project fetched successfully");
        }
        
        private function onSaveAssemblyProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to save project on the server!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            ApplicationFacade.getInstance().loadProject(event.result as AssemblyProject);
            
            sendNotification(Notifications.GLOBAL_ACTION_MESSAGE, "Project saved successfully");
        }
        
        private function onAssembleAssemblyProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to assemble project!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            ApplicationFacade.getInstance().resultPermutations = event.result as PermutationSet;
            
            sendNotification(Notifications.UPDATE_RESULTS_PERMUTATIONS_TABLE);
            sendNotification(Notifications.SWITCH_TO_RESULTS_VIEW);
        }
        
        private function onParseSequenceFileResult(event:ResultEvent):void
        {
            sendNotification(Notifications.UNLOCK);
            
            sendNotification(Notifications.PARSED_IMPORT_SEQUENCE_FILE, event.result);
        }
    }
}