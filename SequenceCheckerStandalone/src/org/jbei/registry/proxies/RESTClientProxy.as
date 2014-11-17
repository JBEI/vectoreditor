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

    import mx.collections.ArrayCollection;

    import mx.controls.Alert;

    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.models.TraceSequenceAlignmentInfo;
    import org.jbei.registry.models.TraceSequenceAnalysis;
    import org.jbei.registry.utils.FeaturedDNASequenceUtils;
    import org.jbei.registry.utils.ObjectTranslator;
    import org.puremvc.as3.patterns.proxy.Proxy;

    public class RESTClientProxy extends Proxy {

        public static const PROXY_NAME:String = "RESTClientProxy";

        public function RESTClientProxy() {
            super(PROXY_NAME);

            // to retrieve
            // var proxy:RESTClientProxy = applicationFacade.retrieveProxy(RESTClientProxy.PROXY_NAME)
            // as RESTClientProxy;
        }

        public function retrieveSequence(id:int, sid:String, url:String):void {
            // Application.application.url
            var requestUrl:String;
            if (url)
                requestUrl = "/rest/remote/" + url + "/" + id + "/sequence?sid=" + sid;
            else
                requestUrl = "/rest/parts/" + id + "/sequence?sid=" + sid;

            var request:URLRequest = new URLRequest(requestUrl);

            request.method = URLRequestMethod.GET;

            var loader:URLLoader = new URLLoader();
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            loader.dataFormat = URLLoaderDataFormat.TEXT;
            request.contentType = "application/json";
            loader.addEventListener(Event.COMPLETE, onGetSequenceResult);
            loader.load(request);
        }

        public function retrieveTraces(id:int, sid:String, url:String):void {
            // Application.application.url
            var requestUrl:String;
            if (url)
                requestUrl = "/rest/remote/" + url + "/parts/" + id + "/traces?sid=" + sid;
            else
                requestUrl = "/rest/parts/" + id + "/traces?sid=" + sid;

            var request:URLRequest = new URLRequest(requestUrl);

            request.method = URLRequestMethod.GET;

            var loader:URLLoader = new URLLoader();
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

            loader.dataFormat = URLLoaderDataFormat.TEXT;
            request.contentType = "application/json";
            loader.addEventListener(Event.COMPLETE, onGetTracesResult);
            loader.load(request);
        }

        private function onGetSequenceResult(evt:Event):void {
            if (!evt.target.data) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch sequence! Invalid response result type!");
                return;
            }

            var response:String = evt.target.data as String;

            var obj:Object = JSON.decode(response);
            var sequence:FeaturedDNASequence = FeaturedDNASequenceUtils.fromObject(obj);
            sendNotification(Notifications.DATA_FETCHED);
            ApplicationFacade.getInstance().updateSequence(sequence);
        }

        private function onGetTracesResult(event:Event):void {
            if (!event.target.data) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Failed to fetch traces!");
                return;
            }

            var response:String = event.target.data as String;
            var traceFilesArray:Array = JSON.decode(response) as Array;
            var traceFiles:ArrayCollection = new ArrayCollection();

            for (var i:int = 0; i < traceFilesArray.length; i += 1) {
                var trace:TraceSequenceAnalysis = ObjectTranslator.objectToInstance(traceFilesArray[i], TraceSequenceAnalysis);
                if (traceFilesArray[i].traceSequenceAlignment != null) {
                    trace.traceSequenceAlignment = ObjectTranslator.objectToInstance(traceFilesArray[i].traceSequenceAlignment, TraceSequenceAlignmentInfo);
//                    Alert.show(trace.traceSequenceAlignment as String);
                }
                traceFiles.addItem(trace);
            }

            sendNotification(Notifications.DATA_FETCHED);
            ApplicationFacade.getInstance().updateTraces(traceFiles);
        }

        function httpStatusHandler(e:HTTPStatusEvent):void {
            trace("httpStatusHandler:" + e.status);
            // do something if not 200
        }

        function securityErrorHandler(e:SecurityErrorEvent):void {
            Alert.show("securityErrorHandler:" + e.text);
        }

        function ioErrorHandler(e:IOErrorEvent):void {
            Alert.show("ioErrorHandler: " + e.text);    // 2032
        }
    }
}
