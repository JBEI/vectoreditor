package org.jbei.registry.utils
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.Feature;
	import org.jbei.registry.models.Link;
	import org.jbei.registry.models.Name;
	import org.jbei.registry.models.PartNumber;
	import org.jbei.registry.models.Plasmid;
	import org.jbei.registry.models.Sequence;
	import org.jbei.registry.models.SequenceFeature;
	
	public class StandaloneUtils
	{
		public static function standaloneEntry():Entry
		{
			var plasmid:Plasmid = new Plasmid();
			plasmid.alias = "Standalone Alias";
			plasmid.backbone = "Standalone BB";
			plasmid.circular = true;
			plasmid.creationTime = new Date();
			plasmid.creator = "Zinovii Dmytriv";
			plasmid.creatorEmail = "zdmytriv@lbl.gov";
			plasmid.keywords = null;
			plasmid.links = new ArrayCollection();
			plasmid.links.addItem(new Link("http://google.com", "JBEI:Standalone"));
			plasmid.longDescription = "Standalone part long description";
			plasmid.modificationTime = null;
			plasmid.names = new ArrayCollection();
			plasmid.names.addItem(new Name("pNJH-0006"));
			plasmid.originOfReplication = "Standalone OOR";
			plasmid.owner = "Zinovii Dmytriv";
			plasmid.ownerEmail = "zdmytriv@lbl.gov";
			plasmid.partNumbers = new ArrayCollection();
			plasmid.partNumbers.addItem(new PartNumber("JBz_000001"));
			plasmid.promoters = "Promoter1, Promoter2";
			plasmid.recordId = "12345678-12345678-12345678-123456781111";
			plasmid.recordType = "plasmid";
			plasmid.references = "Standalone references";
			plasmid.shortDescription = "Short Description";
			plasmid.status = "public";
			plasmid.versionId = "12345678-12345678-12345678-123456781111";
			
			var sequence:Sequence = new Sequence();
			sequence.fwdHash = "";
			sequence.revHash = "";
			sequence.sequence = "gacgtcggtgcctaatgagtgagctaacttacattaattgcgttgcgctcactgcccgctttccagtcgggaaacctgtcgtgccagctgcattaatgaatcggccaacgcgcggggagaggcggtttgcgtattgggcgccagggtggtttttcttttcaccagtgagacgggcaacagctgattgcccttcaccgcctggccctgagagagttgcagcaagcggtccacgctggtttgccccagcaggcgaaaatcctgtttgatggtggttaacggcgggatataacatgagctgtcttcggtatcgtcgtatcccactaccgagatgtccgcaccaacgcgcagcccggactcggtaatggcgcgcattgcgcccagcgccatctgatcgttggcaaccagcatcgcagtgggaacgatgccctcattcagcatttgcatggtttgttgaaaaccggacatggcactccagtcgccttcccgttccgctatcggctgaatttgattgcgagtgagatatttatgccagccagccagacgcagacgcgccgagacagaacttaatgggcccgctaacagcgcgatttgctggtgacccaatgcgaccagatgctccacgcccagtcgcgtaccgtcttcatgggagaaaataatactgttgatgggtgtctggtcagagacatcaagaaataacgccggaacattagtgcaggcagcttccacagcaatggcatcctggtcatccagcggatagttaatgatcagcccactgacgcgttgcgcgagaagattgtgcaccgccgctttacaggcttcgacgccgcttcgttctaccatcgacaccaccacgctggcacccagttgatcggcgcgagatttaatcgccgcgacaatttgcgacggcgcgtgcagggccagactggaggtggcaacgccaatcagcaacgactgtttgcccgccagttgttgtgccacgcggttgggaatgtaattcagctccgccatcgccgcttccactttttcccgcgttttcgcagaaacgtggctggcctggttcaccacgcgggaaacggtctgataagagacaccggcatactctgcgacatcgtataacgttactggtttcacattcaccaccctgaattgactctcttccgggcgctatcatgccataccgcgaaaggttttgcgccattcgatggtgtccgggatctcgacgctctcccttatgcgactcctgcattaggaagcagcccagtagtaggttgaggccgttgagcaccgccgccgcaaggaatggtgcatgcaaggagatggcgcccaacagtcccccggccacggggcctgccaccatacccacgccgaaacaagcgctcatgagcccgaagtggcgagcccgatcttccccatcggtgatgtcggcgatataggcgccagcaaccgcacctgtggcgccggtgatgccggccacgatgcgtccggcgtagaggatcgagatcgtttaggcaccccaggctttacactttatgcttccggctcgtataatgtgtggaattgtgagcggataacaatttcagaattcaaaagatcttttaagaaggagatatacatatgaagaaggtttggcttaaccgttatcccgcggacgttccgacggagatcaaccctgaccgttatcaatctctggtagatatgtttgagcagtcggtcgcgcgctacgccgatcaacctgcgtttgtgaatatgggggaggtaatgaccttccgcaagctggaagaacgcagtcgcgcgtttgccgcttatttgcaacaagggttggggctgaagaaaggcgatcgcgttgcgttgatgatgcctaatttattgcaatatccggtggcgctgtttggcattttgcgtgccgggatgatcgtcgtaaacgttaacccgttgtataccccgcgtgagcttgagcatcagcttaacgatagcggcgcatcggcgattgttatcgtgtctaactttgctcacacactggaaaaagtggttgataaaaccgccgttcagcacgtaattctgacccgtatgggcgatcagctatctacggcaaaaggcacggtagtcaatttcgttgttaaatacatcaagcgtttggtgccgaaataccatctgccagatgccatttcatttcgtagcgcactgcataacggctaccggatgcagtacgtcaaacccgaactggtgccggaagatttagcttttctgcaatacaccggcggcaccactggtgtggcgaaaggcgcgatgctgactcaccgcaatatgctggcgaacctggaacaggttaacgcgacctatggtccgctgttgcatccgggcaaagagctggtggtgacggcgctgccgctgtatcacatttttgccctgaccattaactgcctgctgtttatcgaactgggtgggcagaacctgcttatcactaacccgcgcgatattccagggttggtaaaagagttagcgaaatatccgtttaccgctatcacgggcgttaacaccttgttcaatgcgttgctgaacaataaagagttccagcagctggatttctccagtctgcatctttccgcaggcggtgggatgccagtgcagcaagtggtggcagagcgttgggtgaaactgaccggacagtatctgctggaaggctatggccttaccgagtgtgcgccgctggtcagcgttaacccatatgatattgattatcatagtggtagcatcggtttgccggtgccgtcgacggaagccaaactggtggatgatgatgataatgaagtaccaccaggtcaaccgggtgagctttgtgtcaaaggaccgcaggtgatgctgggttactggcagcgtcccgatgctaccgatgaaatcatcaaaaatggctggttacacaccggcgacatcgcggtaatggatgaagaaggattcctgcgcattgtcgatcgtaaaaaagacatgattctggtttccggttttaacgtctatcccaacgagattgaagatgtcgtcatgcagcatcctggcgtacaggaagtcgcggctgttggcgtaccttccggctccagtggtgaagcggtgaaaatcttcgtagtgaaaaaagatccatcgcttaccgaagagtcactggtgactttttgccgccgtcagctcacgggatacaaagtaccgaagctggtggagtttcgtgatgagttaccgaaatctaacgtcggaaaaattttgcgacgagaattacgtgacgaagcgcgcggcaaagtggacaataaagcctgaactagtaaggaggaaacagaatgcgcccattacatccgattgattttatattcctgtcactagaaaaaagacaacagcctatgcatgtaggtggtttatttttgtttcagattcctgataacgccccagacacctttattcaggatctggtgaatgatatccggatatcaaaatcaatccctgttccaccattcaacaataaactgaatgggcttttttgggatgaagatgaagagtttgatttagatcatcattttcgtcatattgcactgcctcatcctggtcgtattcgtgaattgcttatttatatttcacaagagcacagtacgctgctagatcgggcaaagcccttgtggacctgcaatattattgaaggaattgaaggcaatcgttttgccatgtacttcaaaattcaccatgcgatggtcgatggcgttgctggtatgcggttaattgaaaaatcactctcccatgatgtaacagaaaaaagtatcgtgccaccttggtgtgttgagggaaaacgtgcaaagcgcttaagagaacctaaaacaggtaaaattaagaaaatcatgtctggtattaagagtcagcttcaggcgacacccacagtcattcaagagctttctcagacagtatttaaagatattggacgtaatcctgatcatgtttcaagctttcaggcgccttgttctattttgaatcagcgtgtgagctcatcgcgacgttttgcagcacagtcttttgacctagatcgttttcgtaatattgccaaatcgttgaatgtgaccattaatgatgttgtactagcggtatgttctggtgcattacgtgcgtatttgatgagtcataatagtttgccttcaaaaccattaattgccatggttccagcctctattcgcaatgacgattcagatgtcagcaaccgtattacgatgattctggcaaatttggcaacccacaaagatgatcctttacaacgtcttgaaattatccgccgtagtgttcaaaactcaaagcaacgcttcaaacgtatgaccagcgatcagattctaaattatagtgctgtcgtatatggccctgcaggactcaacataatttctggcatgatgccaaaacgccaagccttcaatctggttatttccaatgtgcctggcccaagagagccactttactggaatggtgccaaacttgatgcactctacccagcttcaattgtattagacggtcaagcattgaatattacaatgaccagttatttagataaacttgaagttggtttgattgcatgccgtaatgcattgccaagaatgcagaatttactgacacatttagaagaagaaattcaactatttgaaggcgtaattgcaaagcaggaagatattaaaacagccaattaaggatcgcaaaaaaccccgcttcggcggggttttttcgccctgtggcgccggtgatgccggccacgatgcgtccggcgtagaggatcgagatcgtttaggcaccccaggctttacactttatgcttccggctcgtataatgtgtggaattgtgagcggataacaatttcaaaattcaaaggaaggatctctgcagtaggaggaattaaccatgagttatactgtcggtacctatttagcggagcggcttgtccagattggtctcaagcatcacttcgcagtcgcgggcgactacaacctcgtccttcttgacaacctgcttttgaacaaaaacatggagcaggtttattgctgtaacgaactgaactgcggtttcagtgcagaaggttatgctcgtgccaaaggcgcagcagcagccgtcgttacctacagcgtcggtgcgctttccgcatttgatgctatcggtggcgcctatgcagaaaaccttccggttatcctgatctccggtgctccgaacaacaatgaccacgctgctggtcacgtgttgcatcacgctcttggcaaaaccgactatcactatcagttggaaatggccaagaacatcacggccgccgctgaagcgatttataccccggaagaagctccggctaaaatcgatcacgtgattaaaactgctcttcgtgagaagaagccggtttatctcgaaatcgcttgcaacattgcttccatgccctgcgccgctcctggaccggcaagcgcattgttcaatgacgaagccagcgacgaagcttctttgaatgcagcggttgaagaaaccctgaaattcatcgccnaccgcgacaaagttgccgtcctcgtcggcagcaagctgcgcgcagctggtgctgaagaagctgctgtcaaatttgctgatgctcttggtggcgcagttgctaccatggctgctgcaaaaagcttcttcccagaagaaaacccgcattacatcggtacctcatggggtgaagtcagctatccgggcgttgaaaagacgatgaaagaagccgatgcggttatcgctctggctcctgtctttaacgactactccaccactggttggacggatattcctgatcctaagaaactggttctcgctgaaccgcgttctgtcgtcgttaacggcattcgcttccccagcgtccatctgaaagactatctgacccgtttggctcagaaagtttccaagaaaaccggtgctttggacttcttcaaatccctcaatgcaggtgaactgaagaaagccgctccggctgatccgagtgctccgttggtcaacgcagaaatcgcccgtcaggtcgaagctcttctgaccccgaacacgacggttattgctgaaaccggtgactcttggttcaatgctcagcgcatgaagctcccgaacggtgctcgcgttgaatatgaaatgcagtggggtcacattggttggtccgttcctgccgccttcggttatgccgtcggtgctccggaacgtcgcaacatcctcatggttggtgatggttccttccagctgacggctcaggaagtcgctcagatggttcgcctgaaactgccggttatcatcttcttgatcaataactatggttacaccatcgaagttatgatccatgatggtccgtacaacaacatcaagaactgggattatgccggtctgatggaagtgttcaacggtaacggtggttatgacagcggtgctggtaaaggcctgaaggctaaaaccggtggcgaactggcagaagctatcaaggttgctctggcaaacaccgacggcccaaccctgatcgaatgcttcatcggtcgtgaagactgcactgaagaattggtcaaatggggtaagcgcgttgctgccgccaacagccgtaagcctgttaacaagctcctctaggagcggccgccaccgcggaggaggaatgagtaatggcttcttcaactttttatattcctttcgtcaacgaaatgggcgaaggttcgcttgaaaaagcaatcaaggatcttaacggcagcggctttaaaaatgcgctgatcgtttctgatgctttcatgaacaaatccggtgttgtgaagcaggttgctgacctgttgaaagcacagggtattaattctgctgtttatgatggcgttatgccgaacccgactgttaccgcagttctggaaggccttaagatcctgaaggataacaattcagacttcgtcatctccctcggtggtggttctccccatgactgcgccaaagccatcgctctggtcgcaaccaatggtggtgaagtcaaagactacgaaggtatcgacaaatctaagaaacctgccctgcctttgatgtcaatcaacacgacggctggtacggcttctgaaatgacgcgtttctgcatcatcactgatgaagtccgtcacgttaagatggccattgttgaccgtcacgttaccccgatggtttccgtcaacgatcctctgttgatggttggtatgccaaaaggcctgaccgccgccaccggtatggatgctctgacccacgcatttgaagcttattcttcaacggcagctactccgatcaccgatgcttgcgctttgaaagcagcttccatgatcgctaagaatctgaagaccgcttgcgacaacggtaaggatatgccggctcgtgaagctatggcttatgcccaattcctcgctggtatggccttcaacaacgcttcgcttggttatgtccatgctatggctcaccagttgggcggttactacaacctgccgcatggtgtctgcaacgctgttctgcttccgcatgttctggcttataacgcctctgtcgttgctggtcgtctgaaagacgttggtgttgctatgggtctcgatatcgccaatctcggtgataaagaaggcgcagaagccaccattcaggctgttcgcgatctggctgcttccattggtattccagcaaacctgaccgagctgggtgctaagaaagaagatgtgccgcttcttgctgaccacgctctgaaagatgcttgtgctctgaccaacccgcgtcagggtgatcagaaagaagttgaagaactcttcctgagcgctttctaaggatctaattcaaaggaggccatcctatggcggacacgttattgattctgggtgatagcctgagcgccgggtatcgaatgtctgccagcgcggcctggcctgccttgttgaatgataagtggcagagtaaaacgtcggtagttaatgccagcatcagcggcgacacctcgcaacaaggactggcgcgccttccggctctgctgaaacagcatcagccgcgttgggtgctggttgaactgggcggcaatgacggtttgcgtggttttcagccacagcaaaccgagcaaacgctgcgccagattttgcaggatgtcaaagccgccaacgctgaaccattgttaatgcaaatacgtctgcctgcaaactatggtcgccgttataatgaagcctttagcgccatttaccccaaactcgccaaagagtttgatgttccgctgctgcccttttttatggaagaggtctacctcaagccacaatggatgcaggatgacggtattcatcccaaccgcgacgcccagccgtttattgccgactggatggcgaagcagttgcagcctttagtaaatcatgactcataaggatccaatctcgagtaaggatctccaggcatcaaataaaacgaaaggctcagtcgaaagactgggcctttcgttttatctgttgtttgtcggtgaacgctctctactagagtcacactggctcaccttcgggtgggcctttctgcgtttatacctagggcgttcggctgcggcgagcggtatcagctcactcaaaggcggtaatacggttatccacagaatcaggggataacgcaggaaagaacatgtgagcaaaaggccagcaaaaggccaggaaccgtaaaaaggccgcgttgctggcgtttttccataggctccgcccccctgacgagcatcacaaaaatcgacgctcaagtcagaggtggcgaaacccgacaggactataaagataccaggcgtttccccctggaagctccctcgtgcgctctcctgttccgaccctgccgcttaccggatacctgtccgcctttctcccttcgggaagcgtggcgctttctcatagctcacgctgtaggtatctcagttcggtgtaggtcgttcgctccaagctgggctgtgtgcacgaaccccccgttcagcccgaccgctgcgccttatccggtaactatcgtcttgagtccaacccggtaagacacgacttatcgccactggcagcagccactggtaacaggattagcagagcgaggtatgtaggcggtgctacagagttcttgaagtggtggcctaactacggctacactagaaggacagtatttggtatctgcgctctgctgaagccagttaccttcggaaaaagagttggtagctcttgatccggcaaacaaaccaccgctggtagcggtggtttttttgtttgcaagcagcagattacgcgcagaaaaaaaggatctcaagaagatcctttgatcttttctacggggtctgacgctcagtggaacgaaaactcacgttaagggattttggtcatgactagtgcttggattctcaccaataaaaaacgcccggcggcaaccgagcgttctgaacaaatccagatggagttctgaggtcattactggatctatcaacaggagtccaagcgagctcgtaaacttggtctgacagttaccaatgcttaatcagtgaggcacctatctcagcgatctgtctatttcgttcatccatagttgcctgactccccgtcgtgtagataactacgatacgggagggcttaccatctggccccagtgctgcaatgataccgcgagacccacgctcaccggctccagatttatcagcaataaaccagccagccggaagggccgagcgcagaagtggtcctgcaactttatccgcctccatccagtctattaattgttgccgggaagctagagtaagtagttcgccagttaatagtttgcgcaacgttgttgccattgctacaggcatcgtggtgtcacgctcgtcgtttggtatggcttcattcagctccggttcccaacgatcaaggcgagttacatgatcccccatgttgtgcaaaaaagcggttagctccttcggtcctccgatcgttgtcagaagtaagttggccgcagtgttatcactcatggttatggcagcactgcataattctcttactgtcatgccatccgtaagatgcttttctgtgactggtgagtactcaaccaagtcattctgagaatagtgtatgcggcgaccgagttgctcttgcccggcgtcaatacgggataataccgcgccacatagcagaactttaaaagtgctcatcattggaaaacgttcttcggggcgaaaactctcaaggatcttaccgctgttgagatccagttcgatgtaacccactcgtgcacccaactgatcttcagcatcttttactttcaccagcgtttctgggtgagcaaaaacaggaaggcaaaatgccgcaaaaaagggaataagggcgacacggaaatgttgaatactcatactcttcctttttcaatattattgaagcatttatcagggttattgtctcatgagcggatacatatttgaatgtatttagaaaaataaacaaataggggttccgcgcacatttccccgaaaagtgccacct";
			sequence.sequenceUser = "";
			sequence.sequenceFeatures = new ArrayCollection();
			sequence.sequenceFeatures.addItem(new SequenceFeature(1500, 1575, 1, new Feature("lacUV5 promoter", null, null, "", 0, "promoter")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1516, 1579, 1, new Feature("lac operator", null, null, "", 0, "misc_binding")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1595, 1614, 1, new Feature("RBS", null, null, "", 0, "RBS")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1615, 3300, 1, new Feature("fadD", null, null, "", 0, "CDS")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(3321, 4697, 1, new Feature("atfA", null, null, "", 0, "CDS")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(3443, 3443, 1, new Feature("silentMut-removeBglII", null, null, "", 0, "misc_feature")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(4702, 4735, 1, new Feature("BBa_B1002_term", null, null, "", 0, "terminator")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(4787, 4862, 1, new Feature("lacUV5 promoter", null, null, "", 0, "promoter")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(4803, 4879, 1, new Feature("lac operator", null, null, "", 0, "misc_binding")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(4907, 6612, 1, new Feature("pdc", null, null, "", 0, "CDS")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(6646, 7797, 1, new Feature("adhB", null, null, "", 0, "CDS")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(7824, 8375, 1, new Feature("lTesA", null, null, "", 0, "CDS")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(8400, 8528, 1, new Feature("dbl term", null, null, "", 0, "terminator")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(9350, 9455, 1, new Feature("T0", null, null, "", 0, "terminator")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(8662, 9344, -1, new Feature("colE1", null, null, "", 0, "rep_origin")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(9485, 10340, -1, new Feature("Amp", null, null, "", 0, "misc_marker")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(49, 1131, -1, new Feature("lacI", null, null, "", 0, "CDS")));
			
			plasmid.sequence = sequence;
			
			return plasmid;
		}
		
		public static function standaloneEntry3():Entry
		{
			var plasmid:Plasmid = new Plasmid();
			plasmid.alias = "Standalone Alias";
			plasmid.backbone = "Standalone BB";
			plasmid.circular = true;
			plasmid.creationTime = new Date();
			plasmid.creator = "Zinovii Dmytriv";
			plasmid.creatorEmail = "zdmytriv@lbl.gov";
			plasmid.keywords = "test, plasmid";
			plasmid.links = new ArrayCollection();
			plasmid.links.addItem(new Link("http://google.com", "JBEI:Standalone"));
			plasmid.longDescription = "Standalone part long description";
			plasmid.modificationTime = null;
			plasmid.names = new ArrayCollection();
			plasmid.names.addItem(new Name("Standalone Part"));
			plasmid.names.addItem(new Name("Test Part"));
			plasmid.originOfReplication = "Standalone OOR";
			plasmid.owner = "Zinovii Dmytriv";
			plasmid.ownerEmail = "zdmytriv@lbl.gov";
			plasmid.partNumbers = new ArrayCollection();
			plasmid.partNumbers.addItem(new PartNumber("JBz_000001"));
			plasmid.promoters = "Promoter1, Promoter2";
			plasmid.recordId = "12345678-12345678-12345678-123456781111";
			plasmid.recordType = "plasmid";
			plasmid.references = "Standalone references";
			plasmid.shortDescription = "Short Description";
			plasmid.status = "public";
			plasmid.versionId = "12345678-12345678-12345678-123456781111";
			
			var sequence:Sequence = new Sequence();
			sequence.fwdHash = "";
			sequence.revHash = "";
			sequence.sequence = "TTTACACTTTGTGCAGATGCTTCCGGCTCGTATAATGTGTGGAACACGTCTTGTGAGCGGATAACAATTGAATTCACCAGATCTCATATGGTACCTGCAGGGATCCTTACTCGAGAAGCTTATAAAACGAAAGGCTCAGTCGAAAGACTGGGCCTTTCGTTTTATGACACCATCGAATGGTGCAAAACCTTTCGCGGTATGGCATGATAGCGCCCGGAAGAGAGTCAATTCAGGGTGGTGAATGTGAAACCAGTAACGTTATACGATGTCGCAGAGTATGCCGGTGTCTCTTATCAGACCGTTTCCCGCGTGGTGAACCAGGCCAGCCACGTTTCTGCGAAAACGCGGGAAAAAGTGGAAGCGGCGATGGCGGAGCTGAATTACATTCCCAACCGCGTGGCACAACAACTGGCGGGCAAACAGTCGTTGCTGATTGGCGTTGCCACCTCCAGTCTGGCCCTGCACGCGCCGTCGCAAATTGTCGCGGCGATTAAATCTCGCGCCGATCAACTGGGTGCCAGCGTGGTGGTGTCGATGGTAGAACGAAGCGGCGTCGAAGCCTGTAAAGCGGCGGTGCACAATCTTCTCGCGCAACGCGTCAGTGGGCTGATCATTAACTATCCGCTGGATGACCAGGATGCCATTGCTGTGGAAGCTGCCTGCACTAATGTTCCGGCGTTATTTCTTGATGTCTCTGACCAGACACCCATCAACAGTATTATTTTCTCCCATGAAGACGGTACGCGACTGGGCGTGGAGCATCTGGTCGCATTGGGTCACCAGCAAATCGCGCTGTTAGCGGGCCCATTAAGTTCTGTCTCGGCGCGTCTGCGTCTGGCTGGCTGGCATAAATATCTCACTCGCAATCAAATTCAGCCGATAGCGGAACGGGAAGGCGACTGGAGTGCCATGTCCGGTTTTCAACAAACCATGCAAATGCTGAATGAGGGCATCGTTCCCACTGCGATGCTGGTTGCCAACGATCAGATGGCGCTGGGCG";
			sequence.sequenceUser = "";
			sequence.sequenceFeatures = new ArrayCollection();
			sequence.sequenceFeatures.addItem(new SequenceFeature(10, 58, 1, new Feature("P-lacUV5", null, null, "", 0, "promoter")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(900, 100, 1, new Feature("test cds", null, null, "", 0, "cds")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(310, 310, 1, new Feature("test terminator", null, null, "", 0, "terminator")));
			
			plasmid.sequence = sequence;
			
			return plasmid;
		}
		
		public static function standaloneEntry2():Entry
		{
			var plasmid:Plasmid = new Plasmid();
			plasmid.alias = "Standalone Alias";
			plasmid.backbone = "Standalone BB";
			plasmid.circular = true;
			plasmid.creationTime = new Date();
			plasmid.creator = "Zinovii Dmytriv";
			plasmid.creatorEmail = "zdmytriv@lbl.gov";
			plasmid.keywords = "test, plasmid";
			plasmid.links = new ArrayCollection();
			plasmid.links.addItem(new Link("http://google.com", "JBEI:Standalone"));
			plasmid.longDescription = "Standalone part long description";
			plasmid.modificationTime = null;
			plasmid.names = new ArrayCollection();
			plasmid.names.addItem(new Name("Standalone Part"));
			plasmid.names.addItem(new Name("Test Part"));
			plasmid.originOfReplication = "Standalone OOR";
			plasmid.owner = "Zinovii Dmytriv";
			plasmid.ownerEmail = "zdmytriv@lbl.gov";
			plasmid.partNumbers = new ArrayCollection();
			plasmid.partNumbers.addItem(new PartNumber("JBz_000001"));
			plasmid.promoters = "Promoter1, Promoter2";
			plasmid.recordId = "12345678-12345678-12345678-123456781111";
			plasmid.recordType = "plasmid";
			plasmid.references = "Standalone references";
			plasmid.shortDescription = "Short Description";
			plasmid.status = "public";
			plasmid.versionId = "12345678-12345678-12345678-123456781111";
			
			var sequence:Sequence = new Sequence();
			sequence.fwdHash = "";
			sequence.revHash = "";
			sequence.sequence = "TTTACACTTTGTGCAGATGCTTCCGGCTCGTATAATGTGTGGAACACGTCTTGTGAGCGGATAACAATTGAATTCACCAGATCTCATATGGTACCTGCAGGGATCCTTACTCGAGAAGCTTATAAAACGAAAGGCTCAGTCGAAAGACTGGGCCTTTCGTTTTATGACACCATCGAATGGTGCAAAACCTTTCGCGGTATGGCATGATAGCGCCCGGAAGAGAGTCAATTCAGGGTGGTGAATGTGAAACCAGTAACGTTATACGATGTCGCAGAGTATGCCGGTGTCTCTTATCAGACCGTTTCCCGCGTGGTGAACCAGGCCAGCCACGTTTCTGCGAAAACGCGGGAAAAAGTGGAAGCGGCGATGGCGGAGCTGAATTACATTCCCAACCGCGTGGCACAACAACTGGCGGGCAAACAGTCGTTGCTGATTGGCGTTGCCACCTCCAGTCTGGCCCTGCACGCGCCGTCGCAAATTGTCGCGGCGATTAAATCTCGCGCCGATCAACTGGGTGCCAGCGTGGTGGTGTCGATGGTAGAACGAAGCGGCGTCGAAGCCTGTAAAGCGGCGGTGCACAATCTTCTCGCGCAACGCGTCAGTGGGCTGATCATTAACTATCCGCTGGATGACCAGGATGCCATTGCTGTGGAAGCTGCCTGCACTAATGTTCCGGCGTTATTTCTTGATGTCTCTGACCAGACACCCATCAACAGTATTATTTTCTCCCATGAAGACGGTACGCGACTGGGCGTGGAGCATCTGGTCGCATTGGGTCACCAGCAAATCGCGCTGTTAGCGGGCCCATTAAGTTCTGTCTCGGCGCGTCTGCGTCTGGCTGGCTGGCATAAATATCTCACTCGCAATCAAATTCAGCCGATAGCGGAACGGGAAGGCGACTGGAGTGCCATGTCCGGTTTTCAACAAACCATGCAAATGCTGAATGAGGGCATCGTTCCCACTGCGATGCTGGTTGCCAACGATCAGATGGCGCTGGGCGCAATGCGCGCCATTACCGAGTCCGGGCTGCGCGTTGGTGCGGATATCTCGGTAGTGGGATACGACGATACCGAAGACAGCTCATGTTATATCCCGCCGTTAACCACCATCAAACAGGATTTTCGCCTGCTGGGGCAAACCAGCGTGGACCGCTTGCTGCAACTCTCTCAGGGCCAGGCGGTGAAGGGCAATCAGCTGTTGCCCGTCTCACTGGTGAAAAGAAAAACCACCCTGGCGCCCAATACGCAAACCGCCTCTCCCCGCGCGTTGGCCGATTCATTAATGCAGCTGGCACGACAGGTTTCCCGACTGGAAAGCGGGCAGTGAGCGCAACGCAATTAATGTGAGTTAGCTCACTCATTAGGCCTCCCAGGAGGTGGCACTTTTCGGGGAAATGTGCGCGGAACCCCTATTTGTTTATTTTTCTAAATACATTCAAATATGTATCCGCTCATGAATTAATTCTTAGAAAAACTCATCGAGCATCAAATGAAACTGCAATTTATTCATATCAGGATTATCAATACCATATTTTTGAAAAAGCCGTTTCTGTAATGAAGGAGAAAACTCACCGAGGCAGTTCCATAGGATGGCAAGATCCTGGTATCGGTCTGCGATTCCGACTCGTCCAACATCAATACAACCTATTAATTTCCCCTCGTCAAAAATAAGGTTATCAAGTGAGAAATCACCATGAGTGACGACTGAATCCGGTGAGAATGGCAAAAGTTTATGCATTTCTTTCCAGACTTGTTCAACAGGCCAGCCATTACGCTCGTCATCAAAATCACTCGCATCAACCAAACCGTTATTCATTCGTGATTGCGCCTGAGCGAGACGAAATACGCGATCGCTGTTAAAAGGACAATTACAAACAGGAATCGAATGCAACCGGCGCAGGAACACTGCCAGCGCATCAACAATATTTTCACCTGAATCAGGATATTCTTCTAATACCTGGAATGCTGTTTTCCCGGGGATCGCAGTGGTGAGTAACCATGCATCATCAGGAGTACGGATAAAATGCTTGATGGTCGGAAGAGGCATAAATTCCGTCAGCCAGTTTAGTCTGACCATCTCATCTGTAACATCATTGGCAACGCTACCTTTGCCATGTTTCAGAAACAACTCTGGCGCATCGGGCTTCCCATACAATCGATAGATTGTCGCACCTGATTGCCCGACATTATCGCGAGCCCATTTATACCCATATAAATCAGCATCCATGTTGGAATTTAATCGCGGCCTAGAGCAAGACGTTTCCCGTTGAATATGGCTCATAACACCCCTTGTATTACTGTTTATGTAAGCAGACAGTTTTATTGTTCATGACCAAAATCCCTTAACGTGAGTTTTCGTTCCACTGAGCGTCAGCCAGCGGCATCAGCACCTTGTCGCCTTGCGTATAATATTTGCCCATGGCTAGCGGAGTGTATACTGGCTTACTATGTTGGCACTGATGAGGGTGTCAGTGAAGTGCTTCATGTGGCAGGAGAAAAAAGGCTGCACCGGTGCGTCAGCAGAATATGTGATACAGGATATATTCCGCTTCCTCGCTCACTGACTCGCTACGCTCGGTCGTTCGACTGCGGCGAGCGGAAATGGCTTACGAACGGGGCGGAGATTTCCTGGAAGATGCCAGGAAGATACTTAACAGGGAAGTGAGAGGGCCGCGGCAAAGCCGTTTTTCCATAGGCTCCGCCCCCCTGACAAGCATCACGAAATCTGACGCTCAAATCAGTGGTGGCGAAACCCGACAGGACTATAAAGATACCAGGCGTTTCCCCCTGGCGGCTCCCTCGTGCGCTCTCCTGTTCCTGCCTTTCGGTTTACCGGTGTCATTCCGCTGTTATGGCCGCGTTTGTCTCATTCCACGCCTGACACTCAGTTCCGGGTAGGCAGTTCGCTCCAAGCTGGACTGTATGCACGAACCCCCCGTTCAGTCCGACCGCTGCGCCTTATCCGGTAACTATCGTCTTGAGTCCAACCCGGAAAGACATGCAAAAGCACCACTGGCAGCAGCCACTGGTAATTGATTTAGAGGAGTTAGTCTTGAAGTCATGCGCCGGTTAAGGCTAAACTGAAAGGACAAGTTTTGGTGACTGCGCTCCTCCAAGCCAGTTACCTCGGTTCAAAGAGTTGGTAGCTCAGAGAACCTTCGAAAAACCGCCCTGCAAGGCGGTTTTTTCGTTTTCAGAGCAAGAGATTACGCGCAGACCAAAACGATCTCAAGAAGATCATCTTATTAATCAGATAAAATATTTCTAGGATCATGAGCCCGAAGTGGCGAGCCCGATCTTCCCCATCGGTGATGTCGGCGATATAGGCGCCAGCAACCGCACCTGTGGCGCCGGTGATGCCGGCCACGATGCGTCCGGCGTAGAGGATCTGCTCATGTTTGACAGCTTATCATCGATAGCTTCCGATGGCGCGCCGAGAGGCAAA";
			sequence.sequenceUser = "";
			sequence.sequenceFeatures = new ArrayCollection();
			sequence.sequenceFeatures.addItem(new SequenceFeature(1, 58, 1, new Feature("P-lacUV5", null, null, "", 0, "promoter")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(2409, 3251, -1, new Feature("p15A", null, null, "", 0, "rep_origin")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1453, 2268, -1, new Feature("Km", null, null, "", 0, "CDS")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(2296, 2322, -1, new Feature("P-kmr", null, null, "", 0, "promoter")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(226, 1314, 1, new Feature("lacIq", null, null, "", 0, "CDS")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1341, 1361, 1, new Feature("Design-terminator", null, null, "", 0, "stem_loop")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(110, 153, 1, new Feature("rrnB\T1", null, null, "", 0, "terminator")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(73, 109, 1, new Feature("MCS", null, null, "", 0, "misc_feature")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1332, 1347, 1, new Feature("stem\(5\mer)", null, null, "", 0, "stem_loop")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(83, 139, 1, new Feature("0507-VKmP1-L", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(120, 179, -1, new Feature("0507-Vkm-P2", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1313, 1372, -1, new Feature("0507-Vkm-P3", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1337, 1386, 1, new Feature("0507-VkmP4", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(2334, 2387, -1, new Feature("0507-VkmP5", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(2336, 2389, 1, new Feature("0507-VkmP6", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(42, 94, -1, new Feature("0507-Vkm-P7R", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1417, 1434, -1, new Feature("stem\(6mer)", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1088, 1088, 1, new Feature("T(Leu)", null, null, "", 0, "mutation")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(35, 57, 1, new Feature("lacO", null, null, "", 0, "misc_signal")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(3398, 3415, 1, new Feature("stem\(5bp)", null, null, "", 0, "stem_loop")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(188, 196, 1, new Feature("Putative\-10\site", null, null, "", 0, "misc_feature")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(168, 173, 1, new Feature("Putative\-35\site", null, null, "", 0, "misc_feature")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(2882, 2900, 1, new Feature("MJD27Aug08-F-seq-p15ori", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(1287, 1304, 1, new Feature("MJD16Sept08-R-seq-lacI", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(219, 238, 1, new Feature("MJD29Sept-R-ctrl-pTYL", null, null, "", 0, "primer")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(25, 30, 1, new Feature("-10\site", null, null, "", 0, "-10_signal")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(37, 37, 1, new Feature("Transcriptional\start\site", null, null, "", 0, "misc_feature")));
			sequence.sequenceFeatures.addItem(new SequenceFeature(2000, 1000, 1, new Feature("test cds", null, null, "", 0, "cds")));
			
			plasmid.sequence = sequence;
			
			return plasmid;
		}
	}
}
