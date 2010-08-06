package org.jbei.registry.proxies
{
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.InvokeEvent;
    import mx.rpc.events.ResultEvent;
    
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.AssemblyProject;

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
            service.createAssemblyProject(sessionId, project);
        }
        
        public function getAssemblyProject(sessionId:String, projectId:String):void
        {
            service.getAssemblyProject(sessionId, projectId);
        }
        
        public function saveAssemblyProject(sessionId:String, project:AssemblyProject):void
        {
            service.saveAssemblyProject(sessionId, project);
        }
        
        public function assembleAssemblyProject(sessionId:String, project:AssemblyProject):void
        {
            service.assembleAssemblyProject(sessionId, project);
        }
        
        // Protected Methods
        protected override function onServiceInvoke(event:InvokeEvent):void
        {
            super.onServiceInvoke(event);
            
            sendNotification(Notifications.LOCK);
        }
        
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
        }
        
        // Private Methods: Response handlers
        private function onCreateAssemblyProjectResult(event:ResultEvent):void
        {
            sendNotification(Notifications.UNLOCK);
        }
        
        private function onGetAssemblyProjectResult(event:ResultEvent):void
        {
            sendNotification(Notifications.UNLOCK);
        }
        
        private function onSaveAssemblyProjectResult(event:ResultEvent):void
        {
            sendNotification(Notifications.UNLOCK);
        }
        
        private function onAssembleAssemblyProjectResult(event:ResultEvent):void
        {
            sendNotification(Notifications.UNLOCK);
        }
    }
}