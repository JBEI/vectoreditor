package org.jbei.model
{
    import mx.controls.Alert;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.remoting.RemoteObject;
    
    import org.jbei.ApplicationFacade;
    import org.jbei.Notifications;
    import org.jbei.model.registry.Entry;
    import org.puremvc.as3.interfaces.IProxy;
    import org.puremvc.as3.patterns.proxy.Proxy;
    
    /**
     * Proxy for retrieving a user's saved bulk import. This is intended to be used
     * by an admin to verify saved imports 
     */
    public class BulkImportVerifierProxy extends Proxy implements IProxy
    {
        public static const NAME:String = "org.jbei.model.BulkImportVerifierProxy";
        private var _remote:RemoteObject;
        private var _sessionId:String;
        
        public function BulkImportVerifierProxy( sessionId:String )
        {
            super( NAME );
            this._sessionId = sessionId;
            _remote = new RemoteObject( ApplicationFacade.REMOTE_SERVICE_NAME );
            registerListeners();
        }
        
        protected function registerListeners() : void 
        {
            _remote.retrieveImportData.addEventListener( "fault", faultHandler );
            _remote.retrieveImportData.addEventListener( ResultEvent.RESULT, retrieveImportDataResult );
        }		
        
        // 
        // PUBLIC METHODS
        //
        public function retrieveData( importId:String ) : void
        {
            _remote.retrieveImportData( _sessionId, importId );
        }
        
        //
        // REMOTE INVOCATION EVENT LISTENER METHODS
        // 
        private function faultHandler( event:FaultEvent ) : void
        {			
            Alert.show( event.fault.faultString + "\n\nDetails\n" + event.fault.faultDetail + "\n\nStackTrace\n" + event.fault.getStackTrace(), event.fault.faultCode );
        }
        
        private function retrieveImportDataResult( event:ResultEvent ) : void 
        {
            if( event.result != null ) {
                sendNotification( Notifications.VERIFY, event.result, "" );
            }
            // TODO : use the last parameter to differentiate the types of verification that we are dealing with
        }
    }
}