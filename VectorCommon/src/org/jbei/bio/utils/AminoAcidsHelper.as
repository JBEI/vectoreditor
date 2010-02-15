package org.jbei.bio.utils
{
	import flash.utils.Dictionary;
	
	import org.jbei.bio.data.AminoAcid;
	
	public class AminoAcidsHelper
	{
		private var aminoAcidsTable:Dictionary = null;
		
		private static var _instance:AminoAcidsHelper;
		
		// Constructor
		public function AminoAcidsHelper()
		{
			if(AminoAcidsHelper._instance) {
				throw new Error("Only one instance of AminoAcidHelper can be created");
			}
			
			createAminoAcidsTable();
		}
		
		// Properties
		public static function get instance():AminoAcidsHelper
		{
			if(! _instance) {
				_instance = new AminoAcidsHelper();
			}
			
			return _instance;
		}
		
		// Public Methods
		public function aminoAcidFromBP(basePairs:String):AminoAcid
		{
			if(! aminoAcidsTable) {
				createAminoAcidsTable();
			}
			
			return aminoAcidsTable[basePairs];
		}
		
		public function isStartCodon(basePairs:String):Boolean
		{
			basePairs = basePairs.toUpperCase();
			
			return (basePairs == 'ATG'
				|| basePairs == 'AUG');
		}
		
		public function isStopCodon(basePairs:String):Boolean
		{
			basePairs = basePairs.toUpperCase();
			
			return (basePairs == 'TAA'
				|| basePairs == 'TAG'
				|| basePairs == 'TGA'
				|| basePairs == 'UAA'
				|| basePairs == 'UAG'
				|| basePairs == 'UGA');
		}
		
		public function evaluatePossibleStop(codon:String):Boolean
		{
			var n1:Array = getNucleotideVariations(codon.charAt(0));
			var n2:Array = getNucleotideVariations(codon.charAt(1));
			var n3:Array = getNucleotideVariations(codon.charAt(2));
			
			for(var i1:int = 0; i1 < n1.length; i1++) {
				for(var i2:int = 0; i2 < n2.length; i2++) {
					for(var i3:int = 0; i3 < n3.length; i3++) {
						var testCodon:String = n1[i1] + n2[i2] + n3[i3];
						
						if(isStopCodon(testCodon)) {
							return true;
						}
					}
				}
			}
			
			return false;
		}
		
		// Private Methods
		private function createAminoAcidsTable():void
		{
			var alanine:AminoAcid = new AminoAcid('Alanine', 'Ala', 'A');
			var arginine:AminoAcid = new AminoAcid('Arginine', 'Arg', 'R');
			var asparagine:AminoAcid = new AminoAcid('Asparagine', 'Asn', 'N');
			var asparticAcid:AminoAcid = new AminoAcid('Aspartic acid', 'Asp', 'D');
			var cysteine:AminoAcid = new AminoAcid('Cysteine', 'Cys', 'C');
			var glutamicAcid:AminoAcid = new AminoAcid('Glutamic acid', 'Glu', 'E');
			var glutamine:AminoAcid = new AminoAcid('Glutamine', 'Gln', 'Q');
			var glycine:AminoAcid = new AminoAcid('Glycine', 'Gly', 'G');
			var histidine:AminoAcid = new AminoAcid('Histidine', 'His', 'H');
			var isoleucine:AminoAcid = new AminoAcid('Isoleucine ', 'Ile', 'I');
			var leucine:AminoAcid = new AminoAcid('Leucine', 'Leu', 'L');
			var lysine:AminoAcid = new AminoAcid('Lysine', 'Lys', 'K');
			var methionine:AminoAcid = new AminoAcid('Methionine', 'Met', 'M');
			var phenylalanine:AminoAcid = new AminoAcid('Phenylalanine', 'Phe', 'F');
			var proline:AminoAcid = new AminoAcid('Proline', 'Pro', 'P');
			var serine:AminoAcid = new AminoAcid('Serine', 'Ser', 'S');
			var threonine:AminoAcid = new AminoAcid('Threonine', 'Thr', 'T');
			var tryptophan:AminoAcid = new AminoAcid('Tryptophan', 'Try', 'W');
			var tyrosine:AminoAcid = new AminoAcid('Tyrosine', 'Tyr', 'Y');
			var valine:AminoAcid = new AminoAcid('Valine ', 'Val', 'V');
			
			aminoAcidsTable = new Dictionary();
			
			aminoAcidsTable['GCT'] = alanine;
			aminoAcidsTable['GCC'] = alanine;
			aminoAcidsTable['GCA'] = alanine;
			aminoAcidsTable['GCG'] = alanine;
			aminoAcidsTable['GCU'] = alanine;
			aminoAcidsTable['CGT'] = arginine;
			aminoAcidsTable['CGC'] = arginine;
			aminoAcidsTable['CGA'] = arginine;
			aminoAcidsTable['CGG'] = arginine;
			aminoAcidsTable['AGA'] = arginine;
			aminoAcidsTable['AGG'] = arginine;
			aminoAcidsTable['CGU'] = arginine;
			aminoAcidsTable['AAT'] = asparagine;
			aminoAcidsTable['AAC'] = asparagine;
			aminoAcidsTable['AAU'] = asparagine;
			aminoAcidsTable['GAT'] = asparticAcid;
			aminoAcidsTable['GAC'] = asparticAcid;
			aminoAcidsTable['GAU'] = asparticAcid;
			aminoAcidsTable['TGT'] = cysteine;
			aminoAcidsTable['TGC'] = cysteine;
			aminoAcidsTable['UGU'] = cysteine;
			aminoAcidsTable['UGC'] = cysteine;
			aminoAcidsTable['GAA'] = glutamicAcid;
			aminoAcidsTable['GAG'] = glutamicAcid;
			aminoAcidsTable['CAA'] = glutamine;
			aminoAcidsTable['CAG'] = glutamine;
			aminoAcidsTable['GGT'] = glycine;
			aminoAcidsTable['GGC'] = glycine;
			aminoAcidsTable['GGA'] = glycine;
			aminoAcidsTable['GGG'] = glycine;
			aminoAcidsTable['GGU'] = glycine;
			aminoAcidsTable['CAT'] = histidine;
			aminoAcidsTable['CAC'] = histidine;
			aminoAcidsTable['CAU'] = histidine;
			aminoAcidsTable['ATT'] = isoleucine;
			aminoAcidsTable['ATC'] = isoleucine;
			aminoAcidsTable['ATA'] = isoleucine;
			aminoAcidsTable['AUU'] = isoleucine;
			aminoAcidsTable['AUC'] = isoleucine;
			aminoAcidsTable['AUA'] = isoleucine;
			aminoAcidsTable['CTT'] = leucine;
			aminoAcidsTable['CTC'] = leucine;
			aminoAcidsTable['CTA'] = leucine;
			aminoAcidsTable['CTG'] = leucine;
			aminoAcidsTable['TTA'] = leucine;
			aminoAcidsTable['TTG'] = leucine;
			aminoAcidsTable['CUU'] = leucine;
			aminoAcidsTable['CUC'] = leucine;
			aminoAcidsTable['CUA'] = leucine;
			aminoAcidsTable['CUG'] = leucine;
			aminoAcidsTable['UUA'] = leucine;
			aminoAcidsTable['UUG'] = leucine;
			aminoAcidsTable['AAA'] = lysine;
			aminoAcidsTable['AAG'] = lysine;
			aminoAcidsTable['ATG'] = methionine;
			aminoAcidsTable['AUG'] = methionine;
			aminoAcidsTable['TTT'] = phenylalanine;
			aminoAcidsTable['TTC'] = phenylalanine;
			aminoAcidsTable['UUU'] = phenylalanine;
			aminoAcidsTable['UUC'] = phenylalanine;
			aminoAcidsTable['CCT'] = proline;
			aminoAcidsTable['CCC'] = proline;
			aminoAcidsTable['CCA'] = proline;
			aminoAcidsTable['CCG'] = proline;
			aminoAcidsTable['CCU'] = proline;
			aminoAcidsTable['TCT'] = serine;
			aminoAcidsTable['TCC'] = serine;
			aminoAcidsTable['TCA'] = serine;
			aminoAcidsTable['TCG'] = serine;
			aminoAcidsTable['AGT'] = serine;
			aminoAcidsTable['AGC'] = serine;
			aminoAcidsTable['UCU'] = serine;
			aminoAcidsTable['UCC'] = serine;
			aminoAcidsTable['UCA'] = serine;
			aminoAcidsTable['UCG'] = serine;
			aminoAcidsTable['AGU'] = serine;
			aminoAcidsTable['ACT'] = threonine;
			aminoAcidsTable['ACC'] = threonine;
			aminoAcidsTable['ACA'] = threonine;
			aminoAcidsTable['ACG'] = threonine;
			aminoAcidsTable['ACU'] = threonine;
			aminoAcidsTable['TGG'] = tryptophan;
			aminoAcidsTable['UGG'] = tryptophan;
			aminoAcidsTable['TAT'] = tyrosine;
			aminoAcidsTable['TAC'] = tyrosine;
			aminoAcidsTable['UAU'] = tyrosine;
			aminoAcidsTable['UAC'] = tyrosine;
			aminoAcidsTable['GTT'] = valine;
			aminoAcidsTable['GTC'] = valine;
			aminoAcidsTable['GTA'] = valine;
			aminoAcidsTable['GTG'] = valine;
			aminoAcidsTable['GUU'] = valine;
			aminoAcidsTable['GUC'] = valine;
			aminoAcidsTable['GUA'] = valine;
			aminoAcidsTable['GUG'] = valine;
		}
		
		/*
		K = G or T
		M = A or C
		R = A or G
		Y = C or T
		S = C or G
		W = A or T
		B = C or G or T
		V = A or C or G
		H = A or C or T
		D = A or G or T
		N = G or A or T or C
		*/
		private function getNucleotideVariations(nucleotide:String):Array
		{
			var result:Array = new Array();
			
			if(nucleotide == 'A' || nucleotide == 'C' || nucleotide == 'T' || nucleotide == 'G' || nucleotide == 'U') {
				result = new Array(nucleotide);
			} else if(nucleotide == 'K') {
				result = new Array('G', 'T');
			} else if(nucleotide == 'M') {
				result = new Array('A', 'C');
			} else if(nucleotide == 'R') {
				result = new Array('A', 'G');
			} else if(nucleotide == 'Y') {
				result = new Array('C', 'T');
			} else if(nucleotide == 'S') {
				result = new Array('C', 'G');
			} else if(nucleotide == 'W') {
				result = new Array('A', 'T');
			} else if(nucleotide == 'B') {
				result = new Array('C', 'G', 'T');
			} else if(nucleotide == 'V') {
				result = new Array('A', 'C', 'G');
			} else if(nucleotide == 'H') {
				result = new Array('A', 'C', 'T');
			} else if(nucleotide == 'D') {
				result = new Array('A', 'G', 'T');
			} else if(nucleotide == 'N') {
				result = new Array('A', 'C', 'T', 'G');
			}
			
			return result;
		}
	}
}
