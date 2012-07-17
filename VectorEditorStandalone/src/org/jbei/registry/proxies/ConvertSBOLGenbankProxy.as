package org.jbei.registry.proxies
{
    import com.ak33m.rpc.xmlrpc.XMLRPCObject;
    
    import flash.utils.ByteArray;
    
    import mx.controls.Alert;
    import mx.rpc.AsyncToken;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.utils.Base64Decoder;
    import mx.utils.Base64Encoder;
    
    import nochump.util.zip.ZipEntry;
    import nochump.util.zip.ZipFile;
    
    import org.jbei.bio.parsers.GenbankFormat;
    import org.jbei.lib.SequenceProvider;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.view.dialogs.SBOLImportDialogForm;
    import org.puremvc.as3.patterns.proxy.Proxy;

    /**
     * @author Joanna Chen
     */
    public class ConvertSBOLGenbankProxy extends Proxy
    {
        public static const PROXY_NAME:String = "ConvertSBOLGenbankProxy";
        
        public static const CONVERT_SBOL_TO_GENBANK_CLEAN:String = "ConvertSBOLXMLToGenBankClean";
        public static const CONVERT_SBOL_TO_GENBANK_PRESERVE_SBOL_INFO:String = "ConvertSBOLXMLToGenBankPreserveSBOLInformation";
        public static const CONVERT_GENBANK_TO_SBOL_XML:String = "ConvertGenBankToSBOLXML";
        
        private var xmlrpcObject:XMLRPCObject;
        
        // Constructor
        public function ConvertSBOLGenbankProxy()
        {
            super(PROXY_NAME);
        }
        
        // Public Methods
        public function convertGenbankToSBOL(genbank:String):void
        {
            if (xmlrpcObject == null) {
                initializeService();
            }
            
            var base64Encoder:Base64Encoder = new Base64Encoder();
            
            base64Encoder.encodeUTFBytes(genbank);
            var encodedData:String = base64Encoder.toString();
            
            var paramObj:Object = new Object();
            paramObj.encoded_to_be_converted_file = encodedData;
            paramObj.conversion_method = CONVERT_GENBANK_TO_SBOL_XML;
            
            var myToken:AsyncToken = xmlrpcObject.ConvertSBOLXML(paramObj);
            myToken.methodName = CONVERT_GENBANK_TO_SBOL_XML;
       }
        
        //FIXME: currently this will result in the converted file being loaded, separate these two actions if possible
        public function convertSBOLToGenbank(sbol:String, conversionMethod:String):void
        {
            if (xmlrpcObject == null) {
                initializeService();
            }
            
            var base64Encoder:Base64Encoder = new Base64Encoder();
            
            base64Encoder.encodeUTFBytes(sbol);
            var encodedData:String = base64Encoder.toString();
            
            var paramObj:Object = new Object();
            paramObj.encoded_to_be_converted_file = encodedData;
            paramObj.conversion_method = conversionMethod;
            
            var myToken:AsyncToken = xmlrpcObject.ConvertSBOLXML(paramObj);
            myToken.methodName = conversionMethod;
        }
        
        // Event Handlers
        private function onXMLRPCResult(event:ResultEvent):void
        {
            var base64Decoder:Base64Decoder = new Base64Decoder();
            
            var encodedOutputFile:String = event.result.encoded_output_file;
            base64Decoder.decode(encodedOutputFile);
            var outputZipFile:ZipFile = new ZipFile(base64Decoder.toByteArray());
            
            var zipEntry:ZipEntry;
            var regExpResult:Array;
            
            switch (event.token.methodName) {
                case CONVERT_GENBANK_TO_SBOL_XML:
                    var sbolExtensionRegExp:RegExp = /\.xml$/;
                    var resultSBOLXML:String;
                    
                    for (var j:int = 0; j < outputZipFile.size; j++) { //find the SBOL XML
                        zipEntry = outputZipFile.entries[i];
                        regExpResult = sbolExtensionRegExp.exec(zipEntry.name);
                        if (regExpResult != null && regExpResult.length > 0) { //if xml extension
                            resultSBOLXML = outputZipFile.getInput(zipEntry).toString();
                            break;
                        }
                    }
                    
                    var notificationBody:Object = {fileString:resultSBOLXML, fileExtension:".xml"};
                    sendNotification(Notifications.SEQUENCE_FILE_GENERATED, notificationBody);
                    break;
                
                case CONVERT_SBOL_TO_GENBANK_CLEAN:
                case CONVERT_SBOL_TO_GENBANK_PRESERVE_SBOL_INFO:
                    var genbankExtensionRegExp:RegExp = /\.gb$/;
                    var resultGenbank:String;   
                    
                    for (var i:int = 0; i < outputZipFile.size; i++) { //find the genbank output
                        zipEntry = outputZipFile.entries[i];
                        regExpResult = genbankExtensionRegExp.exec(zipEntry.name);
                        if (regExpResult != null && regExpResult.length > 0) { //if genbank extension
                            resultGenbank = outputZipFile.getInput(zipEntry).toString();
                            break;
                        }
                    }
                    
                    var sequenceProvider:SequenceProvider = (facade as ApplicationFacade).sequenceProvider;
                    var featuredDNASequence:FeaturedDNASequence = sequenceProvider.fromGenbankFileModel(GenbankFormat.parseGenbankFile(resultGenbank));
                    
                    if (featuredDNASequence == null) {
                        Alert.show("Failed to parse sequence file", "Failed to parse");
                        return;
                    }
                    
                    sendNotification(Notifications.ACTION_MESSAGE, "Sequence parsed successfully");
                    sendNotification(Notifications.SEQUENCE_UPDATED, featuredDNASequence);
                    break;
            }
        }
        
        private function onXMLRPCFault(event:FaultEvent):void
        {
            Alert.show("Failed to parse sequence file.  Below is the error returned by the j5 XML " +
                "RPC web service:\n\n" + event.fault.faultString, "Failed to parse");
        }
        
        // Private Methods
        private function initializeService():void
        {
            xmlrpcObject = new XMLRPCObject();
            xmlrpcObject.endpoint = (facade as ApplicationFacade).convertSBOLXMLRPCServerLocation;
            xmlrpcObject.destination = (facade as ApplicationFacade).convertSBOLXMLRPCServicePath;
            xmlrpcObject.addEventListener(ResultEvent.RESULT, onXMLRPCResult);
            xmlrpcObject.addEventListener(FaultEvent.FAULT, onXMLRPCFault);
        }
    }
}