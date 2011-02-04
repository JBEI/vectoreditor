package org.jbei.registry.utils
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.enzymes.RestrictionEnzyme;
	import org.jbei.registry.models.DNAFeature;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.UserPreferences;
	import org.jbei.registry.models.UserRestrictionEnzymes;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class StandaloneUtils
	{
		public static function standaloneSequence():FeaturedDNASequence {
			var sequence:FeaturedDNASequence = new FeaturedDNASequence();
			
            sequence.name = "pUC19"
			sequence.sequence = "tcgcgcgtttcggtgatgacggtgaaaacctctgacacatgcagctcccggagacggtcacagcttgtctgtaagcggatgccgggagcagacaagcccgtcagggcgcgtcagcgggtgttggcgggtgtcggggctggcttaactatgcggcatcagagcagattgtactgagagtgcaccatatgcggtgtgaaataccgcacagatgcgtaaggagaaaataccgcatcaggcgccattcgccattcaggctgcgcaactgttgggaagggcgatcggtgcgggcctcttcgctattacgccagctggcgaaagggggatgtgctgcaaggcgattaagttgggtaacgccagggttttcccagtcacgacgttgtaaaacgacggccagtgaattcgagctcggtacccggggatcctctagagtcgacctgcaggcatgcaagcttggcgtaatcatggtcatagctgtttcctgtgtgaaattgttatccgctcacaattccacacaacatacgagccggaagcataaagtgtaaagcctggggtgcctaatgagtgagctaactcacattaattgcgttgcgctcactgcccgctttccagtcgggaaacctgtcgtgccagctgcattaatgaatcggccaacgcgcggggagaggcggtttgcgtattgggcgctcttccgcttcctcgctcactgactcgctgcgctcggtcgttcggctgcggcgagcggtatcagctcactcaaaggcggtaatacggttatccacagaatcaggggataacgcaggaaagaacatgtgagcaaaaggccagcaaaaggccaggaaccgtaaaaaggccgcgttgctggcgtttttccataggctccgcccccctgacgagcatcacaaaaatcgacgctcaagtcagaggtggcgaaacccgacaggactataaagataccaggcgtttccccctggaagctccctcgtgcgctctcctgttccgaccctgccgcttaccggatacctgtccgcctttctcccttcgggaagcgtggcgctttctcatagctcacgctgtaggtatctcagttcggtgtaggtcgttcgctccaagctgggctgtgtgcacgaaccccccgttcagcccgaccgctgcgccttatccggtaactatcgtcttgagtccaacccggtaagacacgacttatcgccactggcagcagccactggtaacaggattagcagagcgaggtatgtaggcggtgctacagagttcttgaagtggtggcctaactacggctacactagaagaacagtatttggtatctgcgctctgctgaagccagttaccttcggaaaaagagttggtagctcttgatccggcaaacaaaccaccgctggtagcggtggtttttttgtttgcaagcagcagattacgcgcagaaaaaaaggatctcaagaagatcctttgatcttttctacggggtctgacgctcagtggaacgaaaactcacgttaagggattttggtcatgagattatcaaaaaggatcttcacctagatccttttaaattaaaaatgaagttttaaatcaatctaaagtatatatgagtaaacttggtctgacagttaccaatgcttaatcagtgaggcacctatctcagcgatctgtctatttcgttcatccatagttgcctgactccccgtcgtgtagataactacgatacgggagggcttaccatctggccccagtgctgcaatgataccgcgagacccacgctcaccggctccagatttatcagcaataaaccagccagccggaagggccgagcgcagaagtggtcctgcaactttatccgcctccatccagtctattaattgttgccgggaagctagagtaagtagttcgccagttaatagtttgcgcaacgttgttgccattgctacaggcatcgtggtgtcacgctcgtcgtttggtatggcttcattcagctccggttcccaacgatcaaggcgagttacatgatcccccatgttgtgcaaaaaagcggttagctccttcggtcctccgatcgttgtcagaagtaagttggccgcagtgttatcactcatggttatggcagcactgcataattctcttactgtcatgccatccgtaagatgcttttctgtgactggtgagtactcaaccaagtcattctgagaatagtgtatgcggcgaccgagttgctcttgcccggcgtcaatacgggataataccgcgccacatagcagaactttaaaagtgctcatcattggaaaacgttcttcggggcgaaaactctcaaggatcttaccgctgttgagatccagttcgatgtaacccactcgtgcacccaactgatcttcagcatcttttactttcaccagcgtttctgggtgagcaaaaacaggaaggcaaaatgccgcaaaaaagggaataagggcgacacggaaatgttgaatactcatactcttcctttttcaatattattgaagcatttatcagggttattgtctcatgagcggatacatatttgaatgtatttagaaaaataaacaaataggggttccgcgcacatttccccgaaaagtgccacctgacgtctaagaaaccattattatcatgacattaacctataaaaataggcgtatcacgaggccctttcgtc";
			sequence.features = new ArrayCollection();
			sequence.features.addItem(new DNAFeature(146, 469, -1, "lacZalpha", null, "CDS"));
			sequence.features.addItem(new DNAFeature(396, 452, -1, "multple cloning site", null, "misc_feature"));
			sequence.features.addItem(new DNAFeature(514, 519, -1, "Plac promoter", null, "-10_signal"));
			sequence.features.addItem(new DNAFeature(538, 543, -1, "Plac promoter", null, "-35_signal"));
			sequence.features.addItem(new DNAFeature(563, 575, -1, "CAP protein binding site", null, "protein_bind"));
			sequence.features.addItem(new DNAFeature(867, 1445, -1, "pMB1 origin of replication", null, "rep_origin"));
			sequence.features.addItem(new DNAFeature(876, 1419, -1, "RNAII transcript", null, "misc_RNA"));
			sequence.features.addItem(new DNAFeature(1273, 1278, 1, "RNAI promoter (clockwise); TTGAAG", null, "-35_signal"));
			sequence.features.addItem(new DNAFeature(1295, 1300, 1, "RNAI promoter (clockwise) GCTACA", null, "-10_signal"));
			sequence.features.addItem(new DNAFeature(1309, 1416, 1, "RNAI transcript", null, "misc_RNA"));
			sequence.features.addItem(new DNAFeature(1429, 1434, -1, "RNAII promoter", null, "-10_signal"));
			sequence.features.addItem(new DNAFeature(1450, 1455, -1, "RNAII promoter", null, "-35_signal"));
			sequence.features.addItem(new DNAFeature(1626, 2486, -1, "bla", null, "CDS"));
			sequence.features.addItem(new DNAFeature(2418, 2486, -1, "bla", null, "sig_peptide"));
			sequence.features.addItem(new DNAFeature(2530, 2535, -1, "bla promoter", null, "-10_signal"));
			sequence.features.addItem(new DNAFeature(2551, 2556, -1, "bla promoter", null, "-35_signal"));
			
            /*CONFIG::digestion {
                sequence.sequence = "CCTAATGAGTGAGCTAACTTACATTAATTGCGTTGCGCTCACTGCCCGGAATTCTTTCCAGTCGGGAAACCTGTCGTGCCAGCTGCATTAATGAATCGGCCAACGCGCGGGGAGAGGCGGTTTGCGTATTGGGCGCCAGGGTGGTTTTTCTTTTCACCAGTGAGACGGGCAACAGCTGATTGCCCTTCACCGCCTGGCCCTGAGAGAGTTGCAGCAAGCGGTCCACGCTGGTTTGCCCCAGCAGGCGAAAATCCTGTTTGATGGTGGTTAACGGCGGGATATAACATGAGCTGTCTTCGGTATCGTCGTATCCCACTACCGAGATGTCCGCACCAACGCGCAGCCCGGACTCGGTAATGGCGCGCATTGCGCCCAGCGCCATCTGATCGTTGGCAACCAGCATCGCAGTGGGAACGATGCCCTCATTCAGCATTTGCATGGTTTGTTGAAAACCGGACATGGCACTCCAGTCGCCTTCCCGTTCCGCTATCGGCTGAATTTGATTGCGAGTGAGATATTTATGCCAGCCAGCCAGACGCAGACGCGCCGAGACAGAACTTAATGGGCCCGCTAACAGCGCGATTTGCTGGTGACCCAATGCGACCAGATGCTCCACGCCCAGTCGCGTACCGTCTTCATGGGAGAAAATAATACTGTTGATGGGTGTCTGGTCAGAGACATCAAGAAATAACGCCGGAACATTAGTGCAGGCAGCTTCCACAGCAATGGCATCCTGGTCATCCAGCGGATAGTTAATGATCAGCCCACTGACGCGTTGCGCGAGAAGATTGTGCACCGCCGCTTTACAGGCTTCGACGCGCCAATCAGCAACGACTGTTTGCCCGCCAGTTGTTGTGCCACGCGGTTGGGAATGTAATTCAGCTCCGCCATCGCCGCTTCCACTTTTTCCCGCGTTTTCGCAGAAACGTGGCTGGCCTGGTTCACCACGCGGGAAACGGTCTGATAAGAGACACCGGCATACTCTGCGACATCGTATAACGTTACTGGTTTCACATTCACCACCCTGAATTGACTCTCTTCCGGGCGCTATCATGCCATACCGCGAAAGGTTTTGCGCCATTCGATGGTGTCCGGGATCTCGACGCTCTCCCTTATGCGACTCCTGCATTAGGAAGCAGCCCAGTAGTAGGTTGAGGCCGTTGAGCACCGCCGCCGCAAGGAATGGTGCATGCAAGGAAAGGCGATCGCGTTGCGTTGATGATGCCTAATTTATTGCAATATCCGGTGGCGCTGTTTGGCATTTTGCGTGCCGGGATGATCGTCGTAAACGTTAACCCGTTGTATACCCCGCGTGAGCTTGAGCATCAGCTTAACGATAGCGGCGCATCGGCGATTGTTATCGTGTCTAACTTTGCTCACACACTGGAAAAAGTGGTTGATAAAACCGCCGTTCAGCACGTAATTCTGACCCGTATGGGCGATCAGCTATCTACGGCAAAAGGCACGGTAGTCAATTTCGTTGTTAAATACATCAAGCGTTTGGTGCCGAAATACCATCTCGAGCTGCCAGATGCCATTTCATTTCGTAGCGCACTGCATAACGGCTACCGGATGCAGTACGTCAAACCCGAACTGGTGCCGGAAGATTTAGCTTTTCTGCAATACACCGGCGGCACCACTGGTGTGGCGAAAATCGGTTTGCCGGTGCCGTCGACGGAAGCCAAACTGGTGGATGATGATGATAATGAAGTACCACCAGGTCAACCGGGTGAGCTTTGTGTCAAAGGACCGCAGGTGATGCTGGGTTACTGGCAGCGTCCCGATGCTACCGATGAAATCATCAAAAATGGCTGGTTACACACCGGCGACCGGATATCAAAATCAATCCCTGTTCCACCATTCAACAATAAACTGAATGGGCTTTTTTGGGATGAAGATGAAGAGTTTGATTTAGGAGGAAACAGAATGCGCCCATTACATCCGATTGATTTTATATTCCTGTCACTAGAAAAAAGACAACAGCCTATGCATGTAGGTGGTTTATTTTTGTTTCAGATTCCTGATAACGCCCCAGACACCTTTATTCAGGATCTGGTGAATGATATCC";
                sequence.features = new ArrayCollection();
                sequence.features.addItem(new DNAFeature(1500, 1575, 1, "lacUV5 promoter", null, "promoter"));
                sequence.features.addItem(new DNAFeature(1516, 1579, 1, "lac operator", null, "misc_binding"));
                sequence.features.addItem(new DNAFeature(1595, 1614, 1, "RBS", null, "RBS"));
                sequence.features.addItem(new DNAFeature(1615, 1800, 1, "fadD", null, "CDS"));
                sequence.features.addItem(new DNAFeature(49, 1131, -1, "lacI", null, "CDS"));
            }*/
            
			return sequence;
		}
		
		public static function standaloneUserPreferences():UserPreferences
		{
			var userPreferences:UserPreferences = new UserPreferences();
			
			userPreferences.bpPerRow = -1;
			userPreferences.orfMinimumLength = 300;
			userPreferences.sequenceFontSize = 11;
			
			return userPreferences;
		}
		
		public static function standaloneUserRestrictionEnzymes():UserRestrictionEnzymes
		{
			return new UserRestrictionEnzymes();
		}
	}
}
