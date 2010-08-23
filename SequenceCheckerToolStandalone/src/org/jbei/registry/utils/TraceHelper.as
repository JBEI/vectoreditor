package org.jbei.registry.utils
{
    import org.jbei.registry.models.TraceData;
    import org.jbei.registry.models.TraceSequence;
    import org.jbei.registry.models.TraceSequenceAlignment;

    /**
     * @author Zinovii Dmytriv
     */
    public class TraceHelper
    {
        public static function traceDataToTraceSequence(traceData:TraceData):TraceSequence
        {
            if(!traceData) {
                return null;
            }
            
            var traceSequence:TraceSequence = new TraceSequence();
            
            traceSequence.filename = traceData.filename;
            traceSequence.sequence = traceData.sequence;
            
            var traceSequenceAlignment:TraceSequenceAlignment = new TraceSequenceAlignment();
            traceSequence.traceSequenceAlignment = traceSequenceAlignment;
            
            if(traceData.score >= 0) {
                traceSequenceAlignment.score = traceData.score;
                traceSequenceAlignment.strand = traceData.strand;
                traceSequenceAlignment.queryStart = traceData.queryStart;
                traceSequenceAlignment.queryEnd = traceData.queryEnd;
                traceSequenceAlignment.subjectStart = traceData.subjectStart;
                traceSequenceAlignment.subjectEnd = traceData.subjectEnd;
                traceSequenceAlignment.queryAlignment = traceData.queryAlignment;
                traceSequenceAlignment.subjectAlignment = traceData.subjectAlignment;
            }
            
            return traceSequence;
        }
        
        public static function traceSequenceToTraceData(traceSequence:TraceSequence):TraceData
        {
            if(!traceSequence) {
                return null;
            }
            
            var traceData:TraceData = new TraceData();
            
            traceData.filename = traceSequence.filename;
            traceData.sequence = traceSequence.sequence;
            
            if(traceSequence.traceSequenceAlignment) {
                traceData.score = traceSequence.traceSequenceAlignment.score;
                traceData.strand = traceSequence.traceSequenceAlignment.strand;
                traceData.queryStart = traceSequence.traceSequenceAlignment.queryStart;
                traceData.queryEnd = traceSequence.traceSequenceAlignment.queryEnd;
                traceData.subjectStart = traceSequence.traceSequenceAlignment.subjectStart;
                traceData.subjectEnd = traceSequence.traceSequenceAlignment.subjectEnd;
                traceData.queryAlignment = traceSequence.traceSequenceAlignment.queryAlignment;
                traceData.subjectAlignment = traceSequence.traceSequenceAlignment.subjectAlignment;
            }
            
            return traceData;
        }
    }
}