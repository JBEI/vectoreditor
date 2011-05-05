package org.jbei.registry.utils
{
    import org.jbei.bio.sequence.common.StrandType;
    import org.jbei.bio.sequence.dna.Feature;
    import org.jbei.bio.sequence.dna.FeatureNote;
    import org.jbei.lib.SequenceProvider;
    
    /**
    * @author Joanna Chen
    */
    public class IceXmlUtils
    {
        public static function sequenceProviderToJbeiSeqXml(sequenceProvider:SequenceProvider):String
        {
            if (sequenceProvider == null) {
                return null;
            }
            
            var iceXmlString:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
            iceXmlString += "<seq:seq\n";
            iceXmlString += "  xmlns:seq=\"http://jbei.org/sequence\"\n";
            iceXmlString += "  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n";
            iceXmlString += "  xsi:schemaLocation=\"http://jbei.org/sequence seq.xsd\"\n";
            iceXmlString += ">\n";
            
            iceXmlString += "<seq:name>" + sequenceProvider.name + "</seq:name>\n";
            iceXmlString += "<seq:circular>" + sequenceProvider.circular.toString().toLowerCase() + "</seq:circular>\n";
            iceXmlString += "<seq:features>\n";
            
            for (var i:int = 0; i < sequenceProvider.features.length; i++) {
                var feature:Feature = sequenceProvider.features[i];
                
                iceXmlString += "    <seq:feature>\n";
                iceXmlString += "        <seq:label>" + feature.name + "</seq:label>\n";
                iceXmlString += "        <seq:complement>" + ((feature.strand == StrandType.BACKWARD) ? "true" : "false") + "</seq:complement>\n";
                iceXmlString += "        <seq:type>" + feature.type + "</seq:type>\n";
                iceXmlString += "        <seq:location>\n";  // Features only have one location right now
                iceXmlString += "            <seq:genbank_start>" + (feature.start + 1).toString() + "</seq:genbank_start>\n";
                iceXmlString += "            <seq:end>" + feature.end.toString() + "</seq:end>\n";
                iceXmlString += "        </seq:location>\n";
                
                for (var j:int = 0; j < feature.notes.length; j++) {
                    var attribute:FeatureNote = feature.notes[j];
                    
                    iceXmlString += "        <seq:attribute name=\"" + attribute.name + "\">" + attribute.value + "</seq:attribute>\n";
                }
                
                iceXmlString += "    </seq:feature>\n"
            }
            
            iceXmlString += "</seq:features>\n";
            iceXmlString += "<seq:sequence>" + sequenceProvider.sequence.toString() + "</seq:sequence>\n";
            iceXmlString += "</seq:seq>\n";
            
            return iceXmlString;
        }
        
        public static function jbeiSeqXmlToSequenceProvider(string:String):SequenceProvider
        {
            if (string == null || string == "") {
                return null;
            }
            
            return null;  //TODO
        }
    }
}