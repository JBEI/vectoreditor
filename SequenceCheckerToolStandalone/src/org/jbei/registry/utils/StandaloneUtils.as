package org.jbei.registry.utils
{
    import flash.utils.flash_proxy;
    
    import mx.collections.ArrayCollection;
    import mx.effects.Sequence;
    
    import org.jbei.registry.models.DNAFeature;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.models.SequenceCheckerData;
    import org.jbei.registry.models.SequenceCheckerProject;
    import org.jbei.registry.models.TraceSequence;
    import org.jbei.registry.models.TraceSequenceAlignment;

    /**
     * @author Zinovii Dmytriv
     */
    public class StandaloneUtils
    {
        public static function standaloneSequenceCheckerProject():SequenceCheckerProject
        {
            var sequenceCheckerProject:SequenceCheckerProject = new SequenceCheckerProject();
            
            var featuredDNASequence:FeaturedDNASequence = new FeaturedDNASequence("", "cctctccacccaagcggccggagaacctgcgtgcaatccatcttgttcaatcatgcgaaacgatcctcatcctgtctcttgatcagatcatgatcccctgcgccatcagatccttggcggcaagaaagccatccagtttactttgcagggcttcccaaccttaccagagggcgccccagctggcaattccgaattcatgagatctcacatggcatggatgaactatacaaataataaggatctagagaatataaaaagccagattattaatccggcttttttattatttggatcttccctatcagtgatagagattgacatccctatcagtgatagagatactgagcacggatctattaaagaggagaaaggatctatgcagggttctgtgacagagtttctaaaaccgcgcctggttgatatcgagcaagtgagttcgacgcacgccaaggtgacccttgagcctttagagcgtggctttggccatactctgggtaacgcactgcgccgtattctgctctcatcgatgccgggttgcgcggtgaccgaggttgagattgatggtgtactacatgagtacagcaccaaagaaggcgttcaggaagatatcctggaaatcctgctcaacctgaaagggctggcggtgagagttcagggcaaagatgaagttattcttaccttgaataaatctggcattggccctgtgactgcagccgatatcacccacgacggtgatgtcgaaatcgtcaagccgcagcacgtgatctgccacctgaccgatgagaacgcgtctattagcatgcgtatcaaagttcagcgcggtcgtggttatgtgccggcttctacccgtattcattcggaagaagatgagcgcccaatcggccgtctgctggtcgacgcatgctacagccctgtggagcgtattgcctacaatgttgaagcagcgcgtgtagaacagcgtaccgacctggacaagctggtcatcgaaatggaaaccaacggcacaatcgatcctgaagaggcgattcgtcgtgcggcaaccattctggctgaacaactggaagctttcgttgacttacgtgatgtacgtcagcctgaagtgaaagaagagaaaccagagggatctgccccgcgagtccggaccggatctggggtacccgccatggcggagaggcccttccagtgtcgaatctgcatgcgtaacttcagtcgtagtgaccacctgagccggcacatccgcacccacacaggcgagaagccttttgcctgtgacatttgtgggaggaaatttgccgacaaccgggaccgcacaaagcataccaagatacacacgggcggacagcggccgtacgcatgccctgtcgagtcctgcgatcgccgcttttctgacaggaagacacttatcgagcatatccgcatccacaccggtcagaagcccttccagtgtcgaatctgcatgcgtaacttcagtaccagcagcggcctgagccgccacatccgcacccacacaggatctcagaagcccttccagtgtcgaatctgcatgcgtaacttcagtcgtagtgaccacctgagcgaacacatccgcacccacacaggcgagaagccttttgcctgtgacatttgtgggaggaaatttgccaccagcagcgaccgcacaaagcataccaagatacacctgcgccaaaaagatgcggcccggtaataaggatctagagaatataaaaagccagattattaatccggcttttttattatttggatcctaactcgagtaaggatctccaggcatcaaataaaacgaaaggctcagtcgaaagactgggcctttcgttttatctgttgtttgtcggtgaacgctctctactagagtcacactggctcaccttcgggtgggcctttctgcgtttatacctagggatatattccgcttcctcgctcactgactcgctacgctcggtcgttcgactgcggcgagcggaaatggcttacgaacggggcggagatttcctggaagatgccaggaagatacttaacagggaagtgagagggccgcggcaaagccgtttttccataggctccgcccccctgacaagcatcacgaaatctgacgctcaaatcagtggtggcgaaacccgacaggactataaagataccaggcgtttccccctggcggctccctcgtgcgctctcctgttcctgcctttcggtttaccggtgtcattccgctgttatggccgcgtttgtctcattccacgcctgacactcagttccgggtaggcagttcgctccaagctggactgtatgcacgaaccccccgttcagtccgaccgctgcgccttatccggtaactatcgtcttgagtccaacccggaaagacatgcaaaagcaccactggcagcagccactggtaattgatttagaggagttagtcttgaagtcatgcgccggttaaggctaaactgaaaggacaagttttggtgactgcgctcctccaagccagttacctcggttcaaagagttggtagctcagagaaccttcgaaaaaccgccctgcaaggcggttttttcgttttcagagcaagagattacgcgcagaccaaaacgatctcaagaagatcatcttattaatcagataaaatatttctagatttcagtgcaatttatctcttcaaatgtagcacctgaagtcagccccatacgatataagttgttactagtgcttggattctcaccaataaaaaacgcccggcggcaaccgagcgttctgaacaaatccagatggagttctgaggtcattactggatctatcaacaggagtccaagcgagctctcgaaccccagagtcccgctcagaagaactcgtcaagaaggcgatagaaggcgatgcgctgcgaatcgggagcggcgataccgtaaagcacgaggaagcggtcagcccattcgccgccaagctcttcagcaatatcacgggtagccaacgctatgtcctgatagcggtccgccacacccagccggccacagtcgatgaatccagaaaagcggccattttccaccatgatattcggcaagcaggcatcgccatgggtcacgacgagatcctcgccgtcgggcatgcgcgccttgagcctggcgaacagttcggctggcgcgagcccctgatgctcttcgtccagatcatcctgatcgacaagaccggcttccatccgagtacgtgctcgctcgatgcgatgtttcgcttggtggtcgaatgggcaggtagccggatcaagcgtatgcagccgccgcattgcatcagccatgatggatactttctcggcaggagcaaggtgagatgacaggagatcctgccccggcacttcgcccaatagcagccagtcccttcccgcttcagtgacaacgtcgagcacagctgcgcaaggaacgcccgtcgtggccagccacgatagccgcgctgcctcgtcctgcagttcattcagggcaccggacaggtcggtcttgacaaaaagaaccgggcgcccctgcgctgacagccggaacacggcggcatcagagcagccgattgtctgttgtgcccagtcatagccgaatag");
            var features:ArrayCollection = new ArrayCollection();
            features.addItem(new DNAFeature(1500, 1575, 1, "lacUV5 promoter", null, "promoter"));
            features.addItem(new DNAFeature(1516, 1579, 1, "lac operator", null, "misc_binding"));
            features.addItem(new DNAFeature(1595, 1614, 1, "RBS", null, "RBS"));
            features.addItem(new DNAFeature(1615, 3300, 1, "fadD", null, "CDS"));
            features.addItem(new DNAFeature(49, 1131, -1, "lacI", null, "CDS"));
            
            featuredDNASequence.features = features;
            
            var sequenceCheckerData:SequenceCheckerData = new SequenceCheckerData();
            
            sequenceCheckerProject.sequenceCheckerData = sequenceCheckerData;
            sequenceCheckerData.sequence = featuredDNASequence;
            sequenceCheckerData.traces = standaloneTraces();
            
            return sequenceCheckerProject;
        }
        
        private static function standaloneTraces():ArrayCollection /* of TraceData */
        {
            var traceSequences:ArrayCollection = new ArrayCollection();
            
            traceSequences.addItem(TraceHelper.traceSequenceToTraceData(standaloneTraceSequence1()));
            traceSequences.addItem(TraceHelper.traceSequenceToTraceData(standaloneTraceSequence2()));
            traceSequences.addItem(TraceHelper.traceSequenceToTraceData(standaloneTraceSequence3()));
            traceSequences.addItem(TraceHelper.traceSequenceToTraceData(standaloneTraceSequence4()));
            
            return traceSequences;
        }
        
        private static function standaloneTraceSequence1():TraceSequence
        {
            var  traceSequenceAlignment:TraceSequenceAlignment = new TraceSequenceAlignment(2192, 1, 19, 1222, 6, 1197, "tgacattaacctataaaaataggcgtatcacgaggcagaatttcagataaaaaaaatccttagctttcgctaaggatgatttctggaattcaaaagatctagagaatataaaaagccagattattaatccggcttttttattatttggatctggtagacgtctagtaactggatctccgtattctttacactttatgcttccggctcgtatgttgtgtcgaccgagcggataacaattggatctattaaagaggagaaaggatctatgcgtaaaggagaagaacttttcactggagttgtcccaattcttgttgaattagatggtgatgttaatgggcacaaattttctgtcagtggagagggtgaaggtgatgcaacatacggaaaacttacccttaaatttatttgcactactggaaaactacctgttccatggccaacacttgtcactactttcggttatggtgttcaatgctttgcgagatacccagatcatatgaaacagcatgactttttcaagagtgccatgcccgaaggttatgtacaggaaagaactatatttttcaaagatgacgggaactacaagacacgtgctgaagtcaagtttgaaggtgatacccttgttaatagaatcgagttaaaaggtattgattttaaagaagatggaaacattcttggacacaaattggaatacaactataactcacacaatgtatacatcatggcagacaaacaaaagaatggaatcaaagttaacttcaaaattagacacaacattgaagatggaagcgttcaactagcagaccattatcaacaaaatactccaattggcgatggccctgtccttttaccagacaaccattacctgtccacacaatctgccctttcgaaagatcccaacgaaaagagagaccacatggtccttcttgagtttgtaaccgctgctgggattacacatggcatggatgaactatacaaataataaggatctagagaatataaaaagccagattattaatccggc-ttttttattatttggatcttccctatcagtgatagagattgacatccctatcagtgatagagatactgagcacggatctattaaagaggagaaaggatctatgcagggttctgtgacagagtttctaaaaccgcgcctggttgatatcgagcaagtgagttcgacg-cacgccaaggtgac", "tgac-ttaacctataaaaataggcgtatcacgaggcagaatttcagatnnnnnnnntccttagctttcgctaaggatgatttctggaattcaaaagatctagagaatataaaaagccagattattaatccggcttttttattatttggatctggtagacgtctagtaactggatctccgtattctttacactttatgcttccggctcgtatgttgtgtcgaccgagcggataacaattggatctattaaagaggagaaaggatctatgcgtaaaggagaagaacttttcactggagttgtcccaattcttgttgaattagatggtgatgttaatgggcacaaattttctgtcagtggagagggtgaaggtgatgcaacatacggaaaacttacccttaaatttatttgcactactggaaaactacctgttccatggccaacacttgtcactactttcggttatggtgttcaatgctttgcgagatacccagatcatatgaaacagcatgactttttcaagagtgccatgcccgaaggttatgtacaggaaagaactatatttttcaaagatgacgggaactacaagacacgtgctgaagtcaagtttgaaggtgatacccttgttaatagaatcgagttaaaaggtattgattttaaagaagatggaaacattcttggacacaaattggaatacaactataactcacacaatgtatacatcatggcagacaaacaaaagaatggaatcaaagttaacttcaaaattagacacaacattgaagatggaagcgttcaactagcagaccattatcaacaaaatactccaattggcgatggccctgtccttttaccagacaaccattacctgtccacacaatctgccctttcgaaagatcccaacgaaaagagagaccacatggtccttcttgagtttgtaaccgctgctgggattacacatggcatggatgaactatacaaataataaggatctagagaatataaaaagccagattatt-atccggcnnnnnnnattatttggatcttccctatcagtgatagagattgacatccctatcagtgatagagatactgagcac-gatcta-taaagaggag-aatgatctatgcag---tctgtgac-gag-ttctaaa--cgcg-ctgatgaatatcgagc-agtggagtcgacgccacgccaaggtgac");
            
            var traceSequence:TraceSequence = new TraceSequence("WH_12-14F__2009-01-30_A07_063.ab1", "zdmytriv@lbl.gov", "caaactgacttaacctataaaaataggcgtatcacgaggcagaatttcagataaaaaaaatccttagctttcgctaaggatgatttctggaattcaaaagatctagagaatataaaaagccagattattaatccggcttttttattatttggatctggtagacgtctagtaactggatctccgtattctttacactttatgcttccggctcgtatgttgtgtcgaccgagcggataacaattggatctattaaagaggagaaaggatctatgcgtaaaggagaagaacttttcactggagttgtcccaattcttgttgaattagatggtgatgttaatgggcacaaattttctgtcagtggagagggtgaaggtgatgcaacatacggaaaacttacccttaaatttatttgcactactggaaaactacctgttccatggccaacacttgtcactactttcggttatggtgttcaatgctttgcgagatacccagatcatatgaaacagcatgactttttcaagagtgccatgcccgaaggttatgtacaggaaagaactatatttttcaaagatgacgggaactacaagacacgtgctgaagtcaagtttgaaggtgatacccttgttaatagaatcgagttaaaaggtattgattttaaagaagatggaaacattcttggacacaaattggaatacaactataactcacacaatgtatacatcatggcagacaaacaaaagaatggaatcaaagttaacttcaaaattagacacaacattgaagatggaagcgttcaactagcagaccattatcaacaaaatactccaattggcgatggccctgtccttttaccagacaaccattacctgtccacacaatctgccctttcgaaagatcccaacgaaaagagagaccacatggtccttcttgagtttgtaaccgctgctgggattacacatggcatggatgaactatacaaataataaggatctagagaatataaaaagccagattattatccggctttttttattatttggatcttccctatcagtgatagagattgacatccctatcagtgatagagatactgagcacgatctataaagaggagaatgatctatgcagtctgtgacgagttctaaacgcgctgatgaatatcgagcagtggagtcgacgccacgccaaggtgac", traceSequenceAlignment);
            
            return traceSequence;
        }
        
        private static function standaloneTraceSequence2():TraceSequence
        {
            var  traceSequenceAlignment:TraceSequenceAlignment = new TraceSequenceAlignment(2206, 1, 932, 2138, 13, 1200, "cacatggtccttcttgagtttgtaaccgctgctgggattacacatggcatggatgaactatacaaataataaggatctagagaatataaaaagccagattattaatccggcttttttattatttggatcttccctatcagtgatagagattgacatccctatcagtgatagagatactgagcacggatctattaaagaggagaaaggatctatgcagggttctgtgacagagtttctaaaaccgcgcctggttgatatcgagcaagtgagttcgacgcacgccaaggtgacccttgagcctttagagcgtggctttggccatactctgggtaacgcactgcgccgtattctgctctcatcgatgccgggttgcgcggtgaccgaggttgagattgatggtgtactacatgagtacagcaccaaagaaggcgttcaggaagatatcctggaaatcctgctcaacctgaaagggctggcggtgagagttcagggcaaagatgaagttattcttaccttgaataaatctggcattggccctgtgactgcagccgatatcacccacgacggtgatgtcgaaatcgtcaagccgcagcacgtgatctgccacctgaccgatgagaacgcgtctattagcatgcgtatcaaagttcagcgcggtcgtggttatgtgccggcttctacccgtattcattcggaagaagatgagcgcccaatcggccgtctgctggtcgacgcatgctacagccctgtggagcgtattgcctacaatgttgaagcagcgcgtgtagaacagcgtaccgacctggacaagctggtcatcgaaatggaaaccaacggcacaatcgatcctgaagaggcgattcgtcgtgcggcaaccattctggctgaacaactggaagctttcgttgacttacgtgatgtacgtcagcctgaagtgaaagaagagaaaccagagggatctgccccgcgagtccggaccggatctctggaaccaggatctaaaccgtacaaatgtccggaatgtggtaaatccttctccactcatctggatctgattcgtcatcaacgtactcacactggatctaaaccgtacaaatgtccggaatgtggtaaatccttctcccaatcttcttctctggttcgtcatcaacgtact-cacactggatctaaaccgtacaaatgtccggaatgtggtaaatccttctcc", "cacatggtccttcttgagtttgtaaccgctgctgggattacacatggcatggatgaactatacaaataataaggatctagagaatataaaaagccagattattaatccggcttttttattatttggatcttccctatcagtgatagagattgacatccctatcagtgatagagatactgagcacggatctattaaagaggagaaaggatctatgcagggttctgtgacagagtttctaaaaccgcgcctggttgatatcgagcaagtgagttcgacgcacgccaaggtgacccttgagcctttagagcgtggctttggccatactctgggtaacgcactgcgccgtattctgctctcatcgatgccgggttgcgcggtgaccgaggttgagattgatggtgtactacatgagtacagcaccaaagaaggcgttcaggaagatatcctggaaatcctgctcaacctgaaagggctggcggtgagagttcagggcaaagatgaagttattcttaccttgaataaatctggcattggccctgtgactgcagccgatatcacccacgacggtgatgtcgaaatcgtcaagccgcagcacgtgatctgccacctgaccgatgagaacgcgtctattagcatgcgtatcaaagttcagcgcggtcgtggttatgtgccggcttctacccgtattcattcggaagaagatgagcgcccaatcggccgtctgctggtcgacgcatgctacagccctgtggagcgtattgcctacaatgttgaagcagcgcgtgtagaacagcgtaccgacctggacaagctggtcatcgaaatggaaaccaacggcacaatcgatcctgaagaggcgattcgtcgtgcggcaaccattctggctgaacaactggaagctttcgttgacttacgtgatgtacgtcagcctgaagtgaaagaagagaaaccagagggatctgccccgcgagtccggaccggatctctgg-accaggatct-aaccgtac-aatgtccggaatgt-gtaaatccttct-cactcatctggatctga-tcgtcatc-acgtactcacactggatctaaa-cgtacaaatgtccg--atgtgttaa--tcgtctcc--atcttcttctctgg-tcgtcatc-acgtactccacact-gatct-aacggtacaaatgttcggaa-gtggt-aatctctctcc");
            
            var traceSequence:TraceSequence = new TraceSequence("WH_12-14GF__2009-01-30_C07_059.ab1", "zdmytriv@lbl.gov", "tattcctttttacacatggtccttcttgagtttgtaaccgctgctgggattacacatggcatggatgaactatacaaataataaggatctagagaatataaaaagccagattattaatccggcttttttattatttggatcttccctatcagtgatagagattgacatccctatcagtgatagagatactgagcacggatctattaaagaggagaaaggatctatgcagggttctgtgacagagtttctaaaaccgcgcctggttgatatcgagcaagtgagttcgacgcacgccaaggtgacccttgagcctttagagcgtggctttggccatactctgggtaacgcactgcgccgtattctgctctcatcgatgccgggttgcgcggtgaccgaggttgagattgatggtgtactacatgagtacagcaccaaagaaggcgttcaggaagatatcctggaaatcctgctcaacctgaaagggctggcggtgagagttcagggcaaagatgaagttattcttaccttgaataaatctggcattggccctgtgactgcagccgatatcacccacgacggtgatgtcgaaatcgtcaagccgcagcacgtgatctgccacctgaccgatgagaacgcgtctattagcatgcgtatcaaagttcagcgcggtcgtggttatgtgccggcttctacccgtattcattcggaagaagatgagcgcccaatcggccgtctgctggtcgacgcatgctacagccctgtggagcgtattgcctacaatgttgaagcagcgcgtgtagaacagcgtaccgacctggacaagctggtcatcgaaatggaaaccaacggcacaatcgatcctgaagaggcgattcgtcgtgcggcaaccattctggctgaacaactggaagctttcgttgacttacgtgatgtacgtcagcctgaagtgaaagaagagaaaccagagggatctgccccgcgagtccggaccggatctctggaccaggatctaaccgtacaatgtccggaatgtgtaaatccttctcactcatctggatctgatcgtcatcacgtactcacactggatctaaacgtacaaatgtccgatgtgttaatcgtctccatcttcttctctggtcgtcatcacgtactccacactgatctaacggtacaaatgttcggaagtggtaatctctctccga", traceSequenceAlignment);
            
            return traceSequence;
        }
        
        private static function standaloneTraceSequence3():TraceSequence
        {
            var  traceSequenceAlignment:TraceSequenceAlignment = new TraceSequenceAlignment(2218, -1, 2633, 1454, 14, 1183, "cgaacgaccgagcgcagcgagtcagtgagcgaggaagcctgcataacgcgaagtaatcttttcggttttaaagaaaaagggcagggtggtgacaccttgcccgtttttttgccggactcgagtcaggatccaaataataaaaaagccggattaataatctggctttttatattctctagatccttattaagaggttttagatccagtgtgagtacgttgatgacgtaccagatgaccagaagtggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgtgcacgcagatgagccagttgggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgtgcacgacaagtacgacgagaggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgttcagtcagggtagagttttgggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgacgaaccagagaagaagattgggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgacgaatcagatccagatgagtggagaaggatttaccacattccggacatttgtacggtttagatcctggttccagagatccggtccggactcgcggggcagatccctctggtttctcttctttcacttcaggctgacgtacatcacgtaagtcaacgaaagcttccagttgttcagccagaatggttgccgcacgacgaatcgcctcttcaggatcgattgtgccgttggtttccatttcgatgaccagcttgtccaggtcggtacgctgttctacacgcgctgcttcaacattgtaggcaatacgctccacagggctgtagcatgcgtcgaccagcagacggccgattgggcgctcatcttcttccgaatgaatacgggtagaagccggcacataaccacgaccgcgctgaactttgatacgcatgctaatagacgcgttctcatcggtcaggtggcagatcacgtgctgcggcttgacgatttcgacatcaccgtcgt-gggtgatatcggctgcagt-cacagggccaatgccagat", "cggacgaccgagcgcagcgagtcagtgagcgaggaagcctgcataacgcgaagtaatcttttcggttttaaagaaaaagggcagggtggtgacaccttgccc--ttttttgccggactcgagtcaggatccaaataataaaaaagccggattaataatctggctttttatattctctagatccttattaagaggttttagatccagtgtgagtacgttgatgacgtaccagatgaccagaagtggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgtgcacgcagatgagccagttgggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgtgcacgacaagtacgacgagaggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgttcagtcagggtagagttttgggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgacgaaccagagaagaagattgggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgacgaatcagatccagatgagtggagaaggatttaccacattccggacatttgtacggtttagatcctggttccagagatccggtccggactcgcggggcagatccctctggtttctcttctttcacttcaggctgacgtacatcacgtaagtcaacgaaagcttccagttgttcagccagaatggttgccgcacgacgaatcgcctcttcacgatcgattgtgccgttggtttccatttcgatgaccagcttgtccaggtcggtacgctgttctacacgcgctgcttcaacattgtaggcaatacgctccaca-ggctgtagcatgcgtcgaccagcagacggccgatt-ggcgctcatcttctt-cgaatg-atacgggtagaag-cggcacataaccacgaccgcgctg-actttgatacgcatgctaatagacgcg-tctcatcggtcaggtggcagatcacgtgctgcg--ctgacgatttcgacatca-cgtcgtggggtgatatcggctgcagtccacaggccaattgccagat");
            
            var traceSequence:TraceSequence = new TraceSequence("WH_12-14R__2009-01-30_B07_061.ab1", "zdmytriv@lbl.gov", "ttgccttgcggcgcggacgaccgagcgcagcgagtcagtgagcgaggaagcctgcataacgcgaagtaatcttttcggttttaaagaaaaagggcagggtggtgacaccttgcccttttttgccggactcgagtcaggatccaaataataaaaaagccggattaataatctggctttttatattctctagatccttattaagaggttttagatccagtgtgagtacgttgatgacgtaccagatgaccagaagtggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgtgcacgcagatgagccagttgggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgtgcacgacaagtacgacgagaggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgttcagtcagggtagagttttgggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgacgaaccagagaagaagattgggagaaggatttaccacattccggacatttgtacggtttagatccagtgtgagtacgttgatgacgaatcagatccagatgagtggagaaggatttaccacattccggacatttgtacggtttagatcctggttccagagatccggtccggactcgcggggcagatccctctggtttctcttctttcacttcaggctgacgtacatcacgtaagtcaacgaaagcttccagttgttcagccagaatggttgccgcacgacgaatcgcctcttcacgatcgattgtgccgttggtttccatttcgatgaccagcttgtccaggtcggtacgctgttctacacgcgctgcttcaacattgtaggcaatacgctccacaggctgtagcatgcgtcgaccagcagacggccgattggcgctcatcttcttcgaatgatacgggtagaagcggcacataaccacgaccgcgctgactttgatacgcatgctaatagacgcgtctcatcggtcaggtggcagatcacgtgctgcgctgacgatttcgacatcacgtcgtggggtgatatcggctgcagtccacaggccaattgccagatatcg", traceSequenceAlignment);
            
            return traceSequence;
        }
        
        private static function standaloneTraceSequence4():TraceSequence
        {
            var  traceSequenceAlignment:TraceSequenceAlignment = new TraceSequenceAlignment(22, 1, 1504, 1514, 883, 893, "ccccgaaaagt", "ccccgaaaagt");
            
            var traceSequence:TraceSequence = new TraceSequence("1.fasta", "zdmytriv@lbl.gov", "aggtaataacaatctgcagagtgtgtcacaagtgttttgacagctgcttgttctggtcttcgcactctttccttttccgtcggttgggtttggtacttcgatcattggccgctcattgccatagaaaaaagattacccaatgcccgttgctcattggggatcgccgattactgtaataatgtttaatagtctactttagttttagtcgtggtatactgctatccataactactatgcttccgttagggtctcgtatttgtacccgctatacgtaggacgcaaatttattattatttacagagtgaaaataacacgtctctttccttacgatgaatcgctcgaattataatcagaattacaaattggtagtcgtcggaggcggtggtgttgggaagtcggcaatcactatacaattcatacagaaatactttgtgacagactatgatccaacaattgaagattcatacacaaaacaatgcgtagttgatgatgttccagcaaaattagatattttggatactgctggacaagaagaattcagtgccatgagagaacaatatatgagatctggtgaagggtttttgttagtgttttctgtagctgataaaactagttttaatgagatggaaaaatttcacagacaaatacttagagttaaagatagggacgaatttcctatgttgatggttggaaacaaggcagatttaagtagtcaaagaatggtttctatacaagatgcgcaaagtatggccatgcaactgaagataccttacatagaatgtagtgcaaaagcagggatgaacattgatcaatcattccatgaacttgttcgaattgtaagaaggtttcaattatctgaaagaccaccaattaaatctacgcccccgaaaagttcaaaaaggtgttccatactttagcaatttatgctggctaaatacaatgtgggtatgtttacataccagcccgctcttaactaaatcgttgtgttcccattattgtc", traceSequenceAlignment);
            
            return traceSequence;
        }
    }
}