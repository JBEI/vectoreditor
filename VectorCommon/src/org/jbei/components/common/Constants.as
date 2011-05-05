package org.jbei.components.common
{
    /**
     * General constants for all components.
     * 
     * @author Zinovii Dmytriv
     */
    public class Constants
    {
        /**
        * Clipboard key for sequence provider
        */
        public static const SEQUENCE_PROVIDER_CLIPBOARD_KEY:String = "SequenceProvider";
        
        /**
         * Clipboard key for digestion sequence
         */
        public static const DIGESTION_SEQUENCE_CLIPBOARD_KEY:String = "DigestionSequence";
        
        /**
        * Clipboard key for SequenceProvider's context. 
        * 
        * This key provides the external sequence context information for 
        * the copied sequence. For example, if a part of plasmid is copied,
        * it is sometimes helpful to send the rest of the plasmid along, so 
        * that the receiver can look for duplicate sequences in the plasmid
        * when designing primers. Requested by Device Editor
        * 
        * It is sent as {sequenceProvider: sequenceProvider, start:int, end:int};
        */
        public static const SEQUENCE_PROVIDER_EXTERNAL_CONTEXT_CLIPBOARD_KEY:String = "SequenceProviderExternalContext";
        public static const SEQUENCE_PROVIDER_EXTERNAL_CONTEXT_MAX_LENGTH:int = 20000;
        
        /**
        * Clipboard key for jbei-sequence-xml format
        */
        public static const JBEI_SEQUENCE_XML_CLIPBOARD_KEY:String = "jbei-sequence-xml";
    }
}