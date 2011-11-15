package org.jbei.registry.utils
{
    import flash.utils.ByteArray;
    
    import mx.collections.ArrayCollection;
    import mx.utils.SHA256;
    
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.bio.sequence.common.StrandType;
    import org.jbei.bio.sequence.common.SymbolList;
	import org.jbei.bio.sequence.common.Location;
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
            iceXmlString += "<seq:sequence>" + sequenceProvider.sequence.toString() + "</seq:sequence>\n";
            iceXmlString += "<seq:features>\n";
            
            for (var i:int = 0; i < sequenceProvider.features.length; i++) {
                var feature:Feature = sequenceProvider.features[i];
                // calculate seq hash for liniar and circular case
                var sequence:String = sequenceProvider.sequence.seqString();
                if (feature.end < feature.start) {
                    sequence = sequence.substring(feature.start, sequence.length) + sequence.substring(0, feature.end);
                } else {
                    sequence = sequence.substring(feature.start, feature.end);
                }
                if (feature.strand == -1) {
                    sequence = DNATools.reverseComplement(DNATools.createDNA(sequence)).seqString();
                }
                var byteArray:ByteArray = new ByteArray();
                byteArray.writeUTF(sequence);
                var seqHash:String = SHA256.computeDigest(byteArray);
                
                iceXmlString += "    <seq:feature>\n";
                iceXmlString += "        <seq:label>" + feature.name + "</seq:label>\n";
                iceXmlString += "        <seq:complement>" + ((feature.strand == StrandType.BACKWARD) ? "true" : "false") + "</seq:complement>\n";
                iceXmlString += "        <seq:type>" + feature.type + "</seq:type>\n";
				for (var k:int = 0; k < feature.locations.length; k++) {
                	iceXmlString += "        <seq:location>\n";
					var location:Location = feature.locations[k];
					iceXmlString += "            <seq:genbankStart>" + (location.start + 1).toString() + "</seq:genbankStart>\n";
					iceXmlString += "            <seq:end>" + (location.end).toString() + "</seq:end>\n";
					iceXmlString += "        </seq:location>\n";
				}
                
				if (feature.notes != null) {
	                for (var j:int = 0; j < feature.notes.length; j++) {
	                    var attribute:FeatureNote = feature.notes[j];
	                    iceXmlString += "        <seq:attribute name=\"" + attribute.name + "\" quoted=\"" + attribute.quoted.toString().toLocaleLowerCase() + "\" >" + attribute.value + "</seq:attribute>\n";
	                }
				}
                iceXmlString += "        <seq:seqHash>" + seqHash + "</seq:seqHash>\n"; 
                iceXmlString += "    </seq:feature>\n"
            }
            
            iceXmlString += "</seq:features>\n";
            
            iceXmlString += "</seq:seq>\n";
            
            return iceXmlString;
        }
        
        public static function jbeiSeqXmlToSequenceProvider(jbeiXml:String):SequenceProvider
        {            
            // see SequenceProvider.fromJbeiSeqXml
           return null;
        }
    }
}