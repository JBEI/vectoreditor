package org.jbei.registry.utils
{
    import mx.collections.ArrayCollection;
    
    import org.jbei.bio.enzymes.RestrictionEnzyme;
    import org.jbei.registry.models.DNAFeature;
    import org.jbei.registry.models.FeaturedDNASequence;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class StandaloneUtils
    {
        public static function standaloneSequence():FeaturedDNASequence {
            var sequence:FeaturedDNASequence = new FeaturedDNASequence();
            
            sequence.name = "PJH_00006"
            sequence.sequence = "ggtctcactgactgactgactgactggagaccatcgatcgatcg";
            sequence.features = new ArrayCollection();
//            sequence.features.addItem(new DNAFeature(1500, 1575, 1, "lacUV5 promoter", null, "promoter"));
//            sequence.features.addItem(new DNAFeature(1516, 1579, 1, "lac operator", null, "misc_binding"));
//            sequence.features.addItem(new DNAFeature(1595, 1614, 1, "RBS", null, "RBS"));
//            sequence.features.addItem(new DNAFeature(1615, 3300, 1, "fadD", null, "CDS"));
//            sequence.features.addItem(new DNAFeature(3321, 4697, 1, "atfA", null, "CDS"));
//            sequence.features.addItem(new DNAFeature(3443, 3443, 1, "silentMut-removeBglII", null, "misc_feature"));
//            sequence.features.addItem(new DNAFeature(4702, 4735, 1, "BBa_B1002_term", null, "terminator"));
//            sequence.features.addItem(new DNAFeature(4787, 4862, 1, "lacUV5 promoter", null, "promoter"));
//            sequence.features.addItem(new DNAFeature(4803, 4879, 1, "lac operator", null, "misc_binding"));
//            sequence.features.addItem(new DNAFeature(4907, 6612, 1, "pdc", null, "CDS"));
//            sequence.features.addItem(new DNAFeature(6646, 7797, 1, "adhB", null, "CDS"));
//            sequence.features.addItem(new DNAFeature(7824, 8375, 1, "lTesA", null, "CDS"));
//            sequence.features.addItem(new DNAFeature(8400, 8528, 1, "dbl term", null, "terminator"));
//            sequence.features.addItem(new DNAFeature(9350, 9455, 1, "T0", null, "terminator"));
//            sequence.features.addItem(new DNAFeature(8662, 9344, -1, "colE1", null, "rep_origin"));
//            sequence.features.addItem(new DNAFeature(9485, 10340, -1, "Amp", null, "misc_marker"));
//            sequence.features.addItem(new DNAFeature(49, 1131, -1, "lacI", null, "CDS"));
            
            return sequence;
        }
    }
}
