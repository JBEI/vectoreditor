package org.jbei.registry.proxies
{
    import flash.utils.ByteArray;
    
    import mx.events.ResizeEvent;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.InvokeEvent;
    import mx.rpc.events.ResultEvent;
    
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.models.SequenceCheckerProject;
    import org.jbei.registry.models.TraceData;

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
        public function createSequenceCheckerProject(sessionId:String, project:SequenceCheckerProject):void
        {
            sendNotification(Notifications.LOCK, "Creating project on the server ...");
            
            service.createSequenceCheckerProject(sessionId, project);
        }
        
        public function getSequenceCheckerProject(sessionId:String, projectId:String):void
        {
            sendNotification(Notifications.LOCK, "Fetching project from the server ...");
            
            service.getSequenceCheckerProject(sessionId, projectId);
        }
        
        public function saveSequenceCheckerProject(sessionId:String, project:SequenceCheckerProject):void
        {
            sendNotification(Notifications.LOCK, "Saving project to the server ...");
            
            service.saveSequenceCheckerProject(sessionId, project);
        }
        
        public function alignSequenceCheckerProject(sessionId:String, project:SequenceCheckerProject):void
        {
            sendNotification(Notifications.LOCK, "Aligning project ...");
            
            service.alignSequenceCheckerProject(sessionId, project);
        }
        
        public function importSequenceFile(data:String):void
        {
            sendNotification(Notifications.LOCK, "Parsing sequence file ...");
            
            service.parseSequenceFile(data);
        }
        
        public function parseTraceFile(filename:String, data:ByteArray):void
        {
            sendNotification(Notifications.LOCK, "Parsing trace file ...");
            
            service.parseTraceFile(filename, data);
        }
        
        // Protected Methods
        protected override function onServiceFault(event:FaultEvent):void
        {
            sendNotification(Notifications.APPLICATION_FAILURE, "Service call failed!\n" + event.fault.faultString);
        }
        
        protected override function registerServiceOperations():void
        {
            service.createSequenceCheckerProject.addEventListener(ResultEvent.RESULT, onCreateSequenceCheckerProjectResult);
            service.getSequenceCheckerProject.addEventListener(ResultEvent.RESULT, onGetSequenceCheckerProjectResult);
            service.saveSequenceCheckerProject.addEventListener(ResultEvent.RESULT, onSaveSequenceCheckerProjectResult);
            service.alignSequenceCheckerProject.addEventListener(ResultEvent.RESULT, onAlignSequenceCheckerProjectResult);
            service.parseSequenceFile.addEventListener(ResultEvent.RESULT, onParseSequenceFileResult);
            service.parseTraceFile.addEventListener(ResultEvent.RESULT, onParseTraceFileResult);
        }
        
        // Private Methods: Response handlers
        private function onCreateSequenceCheckerProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to create project on the server!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            ApplicationFacade.getInstance().updateProject(event.result as SequenceCheckerProject);
            
            sendNotification(Notifications.ACTION_MESSAGE, "Project created successfully");
        }
        
        private function onGetSequenceCheckerProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch project from the server!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            ApplicationFacade.getInstance().updateProject(event.result as SequenceCheckerProject);
            
            sendNotification(Notifications.ACTION_MESSAGE, "Project fetched successfully");
        }
        
        private function onSaveSequenceCheckerProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to save project on the server!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            ApplicationFacade.getInstance().updateProject(event.result as SequenceCheckerProject);
            
            sendNotification(Notifications.ACTION_MESSAGE, "Project saved successfully");
        }
        
        private function onAlignSequenceCheckerProjectResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to align project!");
                
                return;
            }
            
            sendNotification(Notifications.UNLOCK);
            
            ApplicationFacade.getInstance().updateProject(event.result as SequenceCheckerProject);
        }
        
        private function onParseSequenceFileResult(event:ResultEvent):void
        {
            sendNotification(Notifications.UNLOCK);
            
            if(!event.result) {
                sendNotification(Notifications.ACTION_MESSAGE, "Failed to parse sequence!");
                
                return;
            }
            
            ApplicationFacade.getInstance().updateSequence(event.result as FeaturedDNASequence);
        }
        
        private function onParseTraceFileResult(event:ResultEvent):void
        {
            sendNotification(Notifications.UNLOCK);
            
            if(!event.result) {
                sendNotification(Notifications.ACTION_MESSAGE, "Failed to parse trace file!");
                
                ApplicationFacade.getInstance().importTrace(null);
            } else {
                ApplicationFacade.getInstance().importTrace(event.result as TraceData);
            }
        }
    }
}