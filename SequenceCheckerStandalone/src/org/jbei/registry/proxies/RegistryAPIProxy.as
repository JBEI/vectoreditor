package org.jbei.registry.proxies
{
    import mx.collections.ArrayCollection;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    import org.jbei.lib.utils.Logger;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.utils.StandaloneUtils;
    
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
        
        public function fetchTraces(sessionId:String, entryId:String):void
        {
            service.getTraces(sessionId, entryId);
        }
        
        // Protected Methods
        protected override function onServiceFault(event:FaultEvent):void
        {
            sendNotification(Notifications.APPLICATION_FAILURE, "Service call failed!\n" + event.fault.faultString);
        }
        
        protected override function registerServiceOperations():void
        {
            // Sequence
            service.getSequence.addEventListener(ResultEvent.RESULT, onGetSequenceResult);
            
            // Traces
            service.getTraces.addEventListener(ResultEvent.RESULT, onGetTracesResult);
        }
        
        // Private Methods: Response handlers
        private function onGetSequenceResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch sequence! Invalid response result type!");
                
                return;
            }
            
            sendNotification(Notifications.DATA_FETCHED);
            
            updateSequence(event.result as FeaturedDNASequence);
        }
        
        private function onGetTracesResult(event:ResultEvent):void
        {
            if(!event.result) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch traces!");
                
                return;
            }
            
            sendNotification(Notifications.DATA_FETCHED);
            
            updateTraces(event.result as ArrayCollection);
        }
        
        // Private Methods
        private function updateSequence(featuredDNASequence:FeaturedDNASequence):void
        {
            ApplicationFacade.getInstance().updateSequence(featuredDNASequence);
            
            Logger.getInstance().info("Sequence fetched successfully");
        }
        
        private function updateTraces(traces:ArrayCollection):void
        {
            ApplicationFacade.getInstance().updateTraces(traces);
            
            Logger.getInstance().info("Traces fetched successfully");
        }
    }
}
