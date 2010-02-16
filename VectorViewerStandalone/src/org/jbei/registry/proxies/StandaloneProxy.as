package org.jbei.registry.proxies
{
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.FeatureNote;
	import org.jbei.registry.model.vo.RestrictionEnzyme;
	import org.jbei.registry.model.vo.RestrictionEnzymeGroup;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.model.vo.Plasmid;

	public class StandaloneProxy extends WebService
	{
		private var commonRestrictionEnzymesXML:XML = <enzymes><enzyme><name>AatII</name><site>gacgtc</site><cutType>0</cutType><reverseRegex><![CDATA[gacgtc]]></reverseRegex><forwardRegex><![CDATA[gacgtc]]></forwardRegex><downstream><dsForward>5</dsForward><dsReverse>1</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>AvrII</name><site>cctagg</site><cutType>0</cutType><reverseRegex><![CDATA[c{2}tag{2}]]></reverseRegex><forwardRegex><![CDATA[c{2}tag{2}]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>BamHI</name><site>ggatcc</site><cutType>0</cutType><reverseRegex><![CDATA[g{2}atc{2}]]></reverseRegex><forwardRegex><![CDATA[g{2}atc{2}]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>BglII</name><site>agatct</site><cutType>0</cutType><reverseRegex><![CDATA[agatct]]></reverseRegex><forwardRegex><![CDATA[agatct]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>BsgI</name><site>gtgcag</site><cutType>0</cutType><reverseRegex><![CDATA[ctgcac]]></reverseRegex><forwardRegex><![CDATA[gtgcag]]></forwardRegex><downstream><dsForward>22</dsForward><dsReverse>20</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>EagI</name><site>cggccg</site><cutType>0</cutType><reverseRegex><![CDATA[cg{2}c{2}g]]></reverseRegex><forwardRegex><![CDATA[cg{2}c{2}g]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>EcoRI</name><site>gaattc</site><cutType>0</cutType><reverseRegex><![CDATA[ga{2}t{2}c]]></reverseRegex><forwardRegex><![CDATA[ga{2}t{2}c]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>EcoRV</name><site>gatatc</site><cutType>0</cutType><reverseRegex><![CDATA[gatatc]]></reverseRegex><forwardRegex><![CDATA[gatatc]]></forwardRegex><downstream><dsForward>3</dsForward><dsReverse>3</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>HindIII</name><site>aagctt</site><cutType>0</cutType><reverseRegex><![CDATA[a{2}gct{2}]]></reverseRegex><forwardRegex><![CDATA[a{2}gct{2}]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>KpnI</name><site>ggtacc</site><cutType>0</cutType><reverseRegex><![CDATA[g{2}tac{2}]]></reverseRegex><forwardRegex><![CDATA[g{2}tac{2}]]></forwardRegex><downstream><dsForward>5</dsForward><dsReverse>1</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>NcoI</name><site>ccatgg</site><cutType>0</cutType><reverseRegex><![CDATA[c{2}atg{2}]]></reverseRegex><forwardRegex><![CDATA[c{2}atg{2}]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>NdeI</name><site>catatg</site><cutType>0</cutType><reverseRegex><![CDATA[catatg]]></reverseRegex><forwardRegex><![CDATA[catatg]]></forwardRegex><downstream><dsForward>2</dsForward><dsReverse>4</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>NheI</name><site>gctagc</site><cutType>0</cutType><reverseRegex><![CDATA[gctagc]]></reverseRegex><forwardRegex><![CDATA[gctagc]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>NotI</name><site>gcggccgc</site><cutType>0</cutType><reverseRegex><![CDATA[gcg{2}c{2}gc]]></reverseRegex><forwardRegex><![CDATA[gcg{2}c{2}gc]]></forwardRegex><downstream><dsForward>2</dsForward><dsReverse>6</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>PstI</name><site>ctgcag</site><cutType>0</cutType><reverseRegex><![CDATA[ctgcag]]></reverseRegex><forwardRegex><![CDATA[ctgcag]]></forwardRegex><downstream><dsForward>5</dsForward><dsReverse>1</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>PvuI</name><site>cgatcg</site><cutType>0</cutType><reverseRegex><![CDATA[cgatcg]]></reverseRegex><forwardRegex><![CDATA[cgatcg]]></forwardRegex><downstream><dsForward>4</dsForward><dsReverse>2</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>SacI</name><site>gagctc</site><cutType>0</cutType><reverseRegex><![CDATA[gagctc]]></reverseRegex><forwardRegex><![CDATA[gagctc]]></forwardRegex><downstream><dsForward>5</dsForward><dsReverse>1</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>SacII</name><site>ccgcgg</site><cutType>0</cutType><reverseRegex><![CDATA[c{2}gcg{2}]]></reverseRegex><forwardRegex><![CDATA[c{2}gcg{2}]]></forwardRegex><downstream><dsForward>4</dsForward><dsReverse>2</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>SalI</name><site>gtcgac</site><cutType>0</cutType><reverseRegex><![CDATA[gtcgac]]></reverseRegex><forwardRegex><![CDATA[gtcgac]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>SmaI</name><site>cccggg</site><cutType>0</cutType><reverseRegex><![CDATA[c{3}g{3}]]></reverseRegex><forwardRegex><![CDATA[c{3}g{3}]]></forwardRegex><downstream><dsForward>3</dsForward><dsReverse>3</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>SpeI</name><site>actagt</site><cutType>0</cutType><reverseRegex><![CDATA[actagt]]></reverseRegex><forwardRegex><![CDATA[actagt]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>SphI</name><site>gcatgc</site><cutType>0</cutType><reverseRegex><![CDATA[gcatgc]]></reverseRegex><forwardRegex><![CDATA[gcatgc]]></forwardRegex><downstream><dsForward>5</dsForward><dsReverse>1</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>XbaI</name><site>tctaga</site><cutType>0</cutType><reverseRegex><![CDATA[tctaga]]></reverseRegex><forwardRegex><![CDATA[tctaga]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>XhoI</name><site>ctcgag</site><cutType>0</cutType><reverseRegex><![CDATA[ctcgag]]></reverseRegex><forwardRegex><![CDATA[ctcgag]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme><enzyme><name>XmaI</name><site>cccggg</site><cutType>0</cutType><reverseRegex><![CDATA[c{3}g{3}]]></reverseRegex><forwardRegex><![CDATA[c{3}g{3}]]></forwardRegex><downstream><dsForward>1</dsForward><dsReverse>5</dsReverse></downstream><upstream></upstream></enzyme></enzymes>;
		
		// Constructor
		public function StandaloneProxy()
		{
			var plasmid:Plasmid = new Plasmid();
		}
		
		// Public Method
		public function fetchEntry(entryId:String):void
		{
			// fake response
			dispatchEvent(new ResultEvent(ResultEvent.RESULT, false, true, testFeaturedSequence()));
		}
		
		public function fetchUserSettings():void
		{
			// fake response
			dispatchEvent(new ResultEvent(ResultEvent.RESULT));
		}
		
		public function fetchUserRestrictionEnzymes():void
		{
			// fake response
			loadRestrictionEnzymes(); // TODO: MOVE, shouldn't be here!
			
			dispatchEvent(new ResultEvent(ResultEvent.RESULT));
		}
		
		// Private Method
		private function testFeaturedSequence():FeaturedSequence
		{
			/*var dnaSequence:DNASequence = new DNASequence("tttacactttatgcttccggctcgtataatgtgtggaattgtgagcggataacaattgaattcaccagatctcatatggtacctgcagggatccttactcgagaagcttataaaacgaaaggctcagtcgaaagactgggcctttcgttttatgacaccatcgaatggtgcaaaacctttcgcggtatggcatgatagcgcccggaagagagtcaattcagggtggtgaatgtgaaaccagtaacgttatacgatgtcgcagagtatgccggtgtctcttatcagaccgtttcccgcgtggtgaaccaggccagccacgtttctgcgaaaacgcgggaaaaagtggaagcggcgatggcggagctgaattacattcccaaccgcgtggcacaacaactggcgggcaaacagtcgttgctgattggcgttgccacctccagtctggccctgcacgcgccgtcgcaaattgtcgcggcgattaaatctcgcgccgatcaactgggtgccagcgtggtggtgtcgatggtagaacgaagcggcgtcgaagcctgtaaagcggcggtgcacaatcttctcgcgcaacgcgtcagtgggctgatcattaactatccgctggatgaccaggatgccattgctgtggaagctgcctgcactaatgttccggcgttatttcttgatgtctctgaccagacacccatcaacagtattattttctcccatgaagacggtacgcgactgggcgtggagcatctggtcgcattgggtcaccagcaaatcgcgctgttagcgggcccattaagttctgtctcggcgcgtctgcgtctggctggctggcataaatatctcactcgcaatcaaattcagccgatagcggaacgggaaggcgactggagtgccatgtccggttttcaacaaaccatgcaaatgctgaatgagggcatcgttcccactgcgatgctggttgccaacgatcagatggcgctgggcgcaatgcgcgccattaccgagtccgggctgcgcgttggtgcggatatctcggtagtgggatacgacgataccgaagacagctcatgttatatcccgccgttaaccaccatcaaacaggattttcgcctgctggggcaaaccagcgtggaccgcttgctgcaactctctcagggccaggcggtgaagggcaatcagctgttgcccgtctcactggtgaaaagaaaaaccaccctggcgcccaatacgcaaaccgcctctccccgcgcgttggccgattcattaatgcagctggcacgacaggtttcccgactggaaagcgggcagtgagcgcaacgcaattaatgtgagttagctcactcattaggcctcccaggaggtggcacttttcggggaaatgtgcgcggaacccctatttgtttatttttctaaatacattcaaatatgtatccgctcatgaattaattcttagaaaaactcatcgagcatcaaatgaaactgcaatttattcatatcaggattatcaataccatatttttgaaaaagccgtttctgtaatgaaggagaaaactcaccgaggcagttccataggatggcaagatcctggtatcggtctgcgattccgactcgtccaacatcaatacaacctattaatttcccctcgtcaaaaataaggttatcaagtgagaaatcaccatgagtgacgactgaatccggtgagaatggcaaaagtttatgcatttctttccagacttgttcaacaggccagccattacgctcgtcatcaaaatcactcgcatcaaccaaaccgttattcattcgtgattgcgcctgagcgagacgaaatacgcgatcgctgttaaaaggacaattacaaacaggaatcgaatgcaaccggcgcaggaacactgccagcgcatcaacaatattttcacctgaatcaggatattcttctaatacctggaatgctgttttcccggggatcgcagtggtgagtaaccatgcatcatcaggagtacggataaaatgcttgatggtcggaagaggcataaattccgtcagccagtttagtctgaccatctcatctgtaacatcattggcaacgctacctttgccatgtttcagaaacaactctggcgcatcgggcttcccatacaatcgatagattgtcgcacctgattgcccgacattatcgcgagcccatttatacccatataaatcagcatccatgttggaatttaatcgcggcctagagcaagacgtttcccgttgaatatggctcataacaccccttgtattactgtttatgtaagcagacagttttattgttcatgaccaaaatcccttaacgtgagttttcgttccactgagcgtcagccagcggcatcagcaccttgtcgccttgcgtataatatttgcccatggctagcggagtgtatactggcttactatgttggcactgatgagggtgtcagtgaagtgcttcatgtggcaggagaaaaaaggctgcaccggtgcgtcagcagaatatgtgatacaggatatattccgcttcctcgctcactgactcgctacgctcggtcgttcgactgcggcgagcggaaatggcttacgaacggggcggagatttcctggaagatgccaggaagatacttaacagggaagtgagagggccgcggcaaagccgtttttccataggctccgcccccctgacaagcatcacgaaatctgacgctcaaatcagtggtggcgaaacccgacaggactataaagataccaggcgtttccccctggcggctccctcgtgcgctctcctgttcctgcctttcggtttaccggtgtcattccgctgttatggccgcgtttgtctcattccacgcctgacactcagttccgggtaggcagttcgctccaagctggactgtatgcacgaaccccccgttcagtccgaccgctgcgccttatccggtaactatcgtcttgagtccaacccggaaagacatgcaaaagcaccactggcagcagccactggtaattgatttagaggagttagtcttgaagtcatgcgccggttaaggctaaactgaaaggacaagttttggtgactgcgctcctccaagccagttacctcggttcaaagagttggtagctcagagaaccttcgaaaaaccgccctgcaaggcggttttttcgttttcagagcaagagattacgcgcagaccaaaacgatctcaagaagatcatcttattaatcagataaaatatttctaggatcatgagcccgaagtggcgagcccgatcttccccatcggtgatgtcggcgatataggcgccagcaaccgcacctgtggcgccggtgatgccggccacgatgcgtccggcgtagaggatctgctcatgtttgacagcttatcatcgatagcttccgatggcgcgccgagaggc");
			var featuredSequence:FeaturedSequence = new FeaturedSequence(dnaSequence, SequenceUtils.reverseComplement(dnaSequence));
			
			//featuredSequence.addFeature(new Feature(2409, 3251, "rep_origin", Feature.NEGATIVE, new Array(new FeatureNote("label", "p15A"))));
			featuredSequence.addFeature(new Feature(1, 58, "promoter", Feature.POSITIVE, new Array(new FeatureNote("label", "P-lacUV5"))));
			featuredSequence.addFeature(new Feature(1453, 2268, "CDS", Feature.NEGATIVE, new Array(new FeatureNote("label", "Km"))));
			featuredSequence.addFeature(new Feature(2296, 2322, "promoter", Feature.NEGATIVE, new Array(new FeatureNote("label", "P-kmr"))));
			featuredSequence.addFeature(new Feature(226, 1314, "CDS", Feature.POSITIVE, new Array(new FeatureNote("label", "lacIq"))));
			featuredSequence.addFeature(new Feature(1341, 1361, "stem_loop", Feature.POSITIVE, new Array(new FeatureNote("label", "Design-terminator"))));
			featuredSequence.addFeature(new Feature(110, 153, "terminator", Feature.POSITIVE, new Array(new FeatureNote("label", "rrnB\T1"))));
			featuredSequence.addFeature(new Feature(73, 109, "misc_feature", Feature.POSITIVE, new Array(new FeatureNote("label", "MCS"))));
			featuredSequence.addFeature(new Feature(1332, 1347, "stem_loop", Feature.POSITIVE, new Array(new FeatureNote("label", "stem\(5\mer)"))));
			featuredSequence.addFeature(new Feature(83, 139, "primer", Feature.POSITIVE, new Array(new FeatureNote("label", "0507-VKmP1-L"), new FeatureNote("note", "CCGCATggatccttactcgagaagcttataaaacgaaaggctcagtcgaaagactgg"))));
			featuredSequence.addFeature(new Feature(120, 179, "primer", Feature.NEGATIVE, new Array(new FeatureNote("label", "0507-Vkm-P2"), new FeatureNote("note", "60-mer: primer2: aggctcagtcgaaagactgggcctttcgttttatgacaccatcgaatggtgcaaaacctt"))));
			featuredSequence.addFeature(new Feature(1313, 1372, "primer", Feature.NEGATIVE, new Array(new FeatureNote("label", "0507-Vkm-P3"), new FeatureNote("note", "60-mer: aagtgccacctcctgggaggcctaatgagtgagctaactcacattaattgcgttgcgctc"))));
			featuredSequence.addFeature(new Feature(1337, 1386, "primer", Feature.POSITIVE, new Array(new FeatureNote("label", "0507-VkmP4"), new FeatureNote("note", "tagctcactcattaggcctcccaggaggtggcacttttcggggaaatgtg"))));
			featuredSequence.addFeature(new Feature(2334, 2387, "primer", Feature.NEGATIVE, new Array(new FeatureNote("label", "0507-VkmP5"), new FeatureNote("note", "aggcgacaaggtgctgatgccgctggctgacgctcagtggaacgaaaactcacg"))));
			featuredSequence.addFeature(new Feature(2336, 2389, "primer", Feature.POSITIVE, new Array(new FeatureNote("label", "0507-VkmP6"), new FeatureNote("note", "tgagttttcgttccactgagcgtcagccagcggcatcagcaccttgtcgccttg"))));
			featuredSequence.addFeature(new Feature(42, 94, "primer", Feature.NEGATIVE, new Array(new FeatureNote("label", "0507-Vkm-P7R"), new FeatureNote("note", "gagtaaggatccctgcaggtaccatatgagatctggtgaattcaattgttatccgctca"))));
			featuredSequence.addFeature(new Feature(1417, 1434, "stem_loop", Feature.NEGATIVE, new Array(new FeatureNote("label", "stem\(6mer)"))));
			featuredSequence.addFeature(new Feature(1088, 1088, "mutation", Feature.POSITIVE, new Array(new FeatureNote("label", "T(Leu)"), new FeatureNote("note", "a strong T/A signal appeared in 0519-Vkm-p3 signal, changing from Serine(C/G) to Leu (T/A)"))));
			featuredSequence.addFeature(new Feature(35, 57, "misc_signal", Feature.POSITIVE, new Array(new FeatureNote("label", "lacO"))));
			//featuredSequence.addFeature(new Feature(3398, 3415, "stem_loop", Feature.POSITIVE, new Array(new FeatureNote("label", "stem\(5bp)"))));
			featuredSequence.addFeature(new Feature(188, 196, "misc_feature", Feature.POSITIVE, new Array(new FeatureNote("label", "Putative\-10\site"))));
			featuredSequence.addFeature(new Feature(168, 173, "misc_feature", Feature.POSITIVE, new Array(new FeatureNote("label", "Putative\-35\site"))));
			featuredSequence.addFeature(new Feature(2882, 2900, "primer", Feature.POSITIVE, new Array(new FeatureNote("label", "MJD27Aug08-F-seq-p15ori"))));
			featuredSequence.addFeature(new Feature(1287, 1304, "primer", Feature.POSITIVE, new Array(new FeatureNote("label", "MJD16Sept08-R-seq-lacI"))));
			featuredSequence.addFeature(new Feature(219, 238, "primer", Feature.POSITIVE, new Array(new FeatureNote("label", "MJD29Sept-R-ctrl-pTYL"))));
			featuredSequence.addFeature(new Feature(25, 30, "-10_signal", Feature.POSITIVE, new Array(new FeatureNote("label", "-10\site"))));
			featuredSequence.addFeature(new Feature(37, 37, "misc_feature", Feature.POSITIVE, new Array(new FeatureNote("label", "Transcriptional\start\site"), new FeatureNote("note", "based on http://www.mun.ca/biochem/courses/3107/Topics/promoter_bacterial.html"))));*/
			
			return null;
		}
		
		private function loadRestrictionEnzymes():void
		{
			/*var commonREGroup:RestrictionEnzymeGroup = commonRestrictionEnzymeGroup();
			commonREGroup.isSystem = true;
			
			RestrictionEnzymeGroupManager.instance.register(commonREGroup);*/
		}
		
		private function commonRestrictionEnzymeGroup():RestrictionEnzymeGroup
		{
			/*var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("Common");
			
			for each (var enzymeXML:XML in commonRestrictionEnzymesXML.enzyme) {
				var name:String = enzymeXML.name;
				var site:String = enzymeXML.site;
				
				var forwardRegex:String = enzymeXML.forwardRegex;
				forwardRegex = forwardRegex.toUpperCase();
				
				var reverseRegex:String = enzymeXML.reverseRegex;
				reverseRegex = reverseRegex.toUpperCase();
				
				var cutType:String = enzymeXML.cutType;
				
				var ds:Array = null;
				if(enzymeXML.downstream != null) {
					ds = new Array(enzymeXML.dsForward, enzymeXML.dsReverse);
				}
				
				var us:Array = null;
				if(enzymeXML.upstream != null) {
					us = new Array(enzymeXML.usForward, enzymeXML.usReverse);
				}
				
				var re:RestrictionEnzyme = new RestrictionEnzyme(name, new DNASequence(site), forwardRegex, reverseRegex, ds, us);
				
				restrictionEnzymeGroup.addRestrictionEnzyme(re);
			}
			
			return restrictionEnzymeGroup;*/
			return null;
		}
	}
}
