package org.jbei.registry.proxies {

    import com.adobe.serialization.json.JSON;

    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;

    import mx.controls.Alert;

    import org.jbei.lib.utils.Logger;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.utils.FeaturedDNASequenceUtils;
    import org.puremvc.as3.patterns.proxy.Proxy;

    public class RESTClientProxy extends Proxy {

        public static const PROXY_NAME:String = "RESTClientProxy";

        public function RESTClientProxy() {
            super(PROXY_NAME);
        }

        public function retrieveSequence(id:String, sid:String):void {
            sendNotification(Notifications.LOCK, "Loading sequence...");
            // Application.application.url
            var request:URLRequest = new URLRequest("/rest/parts/" + id + "/sequence?sid=" + sid);
            request.method = URLRequestMethod.GET;

            var loader:URLLoader = new URLLoader();
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            loader.dataFormat = URLLoaderDataFormat.TEXT;
            request.contentType = "application/json";
            loader.addEventListener(Event.COMPLETE, handleResults);
            loader.load(request);
        }

        function handleResults(evt:Event):void {
            var response:String = evt.target.data as String;

            var obj:Object = JSON.decode(response);
            var sequence:FeaturedDNASequence = FeaturedDNASequenceUtils.fromObject(obj);
            ApplicationFacade.getInstance().updateSequence(sequence);

            ApplicationFacade.getInstance().updateEntryPermissions(sequence.canEdit);
            sendNotification(Notifications.UNLOCK);
        }

        public function saveSequence(sessionId:String, entryId:String, featuredDNASequence:FeaturedDNASequence):void
        {
            sendNotification(Notifications.LOCK, "Saving sequence ...");

            var request:URLRequest = new URLRequest("/rest/parts/" + entryId + "/sequence?sid=" + sessionId);
            request.method = URLRequestMethod.POST;
            request.data = JSON.encode(FeaturedDNASequenceUtils.toObject(featuredDNASequence));

            var loader:URLLoader = new URLLoader();
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            loader.dataFormat = URLLoaderDataFormat.TEXT;
            request.contentType = "application/json";
            loader.addEventListener(Event.COMPLETE, onSaveSequenceResult);
            loader.load(request);
        }

        function httpStatusHandler(e:HTTPStatusEvent):void
        {
            Logger.getInstance().info("httpStatusHandler:" + e.status);
            // do something if not 200
        }

        function securityErrorHandler(e:SecurityErrorEvent):void
        {
            Alert.show("securityErrorHandler:" + e.text);
        }

        function ioErrorHandler(e:IOErrorEvent):void
        {
            Alert.show("ioErrorHandler: " + e.text);    // 2032
        }

        private function onSaveSequenceResult(event:Event):void
        {
            Logger.getInstance().info(event.toString());
            // todo
//            if(event.result == false) {
//                Alert.show("Failed to save sequence.\n\nIf you have any sequence feature attribute values " +
//                        "that contain more than 4095 characters (e.g. SBOL_DS_nucleotides attributes from " +
//                        "importing an SBOL file and preserving SBOL information), those attributes or the features " +
//                        "they apply to need to be removed.", "Save error");
//                sendNotification(Notifications.UNLOCK);
//
//                return;
//            }

            sendNotification(Notifications.UNLOCK);
            Logger.getInstance().info("Sequence saved successfully");
        }
    }
}
