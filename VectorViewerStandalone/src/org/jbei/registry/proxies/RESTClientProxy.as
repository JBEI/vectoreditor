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
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.utils.FeaturedDNASequenceUtils;
    import org.puremvc.as3.patterns.proxy.Proxy;

    public class RESTClientProxy extends Proxy {

        public static const PROXY_NAME:String = "RESTClientProxy";

        public function RESTClientProxy() {
            super(PROXY_NAME);

            // to retrieve
            // var proxy:RESTClientProxy = applicationFacade.retrieveProxy(RESTClientProxy.PROXY_NAME) as RESTClientProxy;
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
            loader.addEventListener(Event.COMPLETE, handleResults);
            loader.load(request);
        }

        function handleResults(evt:Event):void {
            var response:String = evt.target.data as String;

            var obj:Object = JSON.decode(response);
            var sequence:FeaturedDNASequence = FeaturedDNASequenceUtils.fromObject(obj);
            ApplicationFacade.getInstance().updateSequence(sequence);
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
