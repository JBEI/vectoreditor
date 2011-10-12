package flexUnitTests
{
	import mx.collections.ArrayCollection;
	
	import org.flexunit.Assert;
	import org.jbei.bio.sequence.common.Location;
	import org.jbei.bio.sequence.dna.Feature;
	import org.jbei.bio.sequence.DNATools;
	import org.jbei.lib.SequenceProvider;
	
	/**
	 * @author Timothy Ham
	 */
	public class SequenceProviderTestCases
	{		
		
		private var _sequenceProvider:SequenceProvider;
		private var _referenceSequenceProvider:SequenceProvider;
		[Before]
		public function setUp():void
		{
			// 64bp sequence
			var sequence:String = "tcgcgcgtttcggtgatgacggtgaaaacctctgacacatgcagctcccggagacggtcacagc";
			_referenceSequenceProvider = new SequenceProvider("test", true, DNATools.createDNA(sequence));
			
			_referenceSequenceProvider.features = new ArrayCollection();
			var feature:Feature = new Feature("lacZalpha", 10, 20, "CDS", -1, null);
			feature.locations.push(new Location(25, 30));
			_referenceSequenceProvider.features.addItem(feature);
			
			feature = new Feature("cds2", 40, 50, "CDS", 1, null);
			feature.locations.push(new Location(55, 5));
			_referenceSequenceProvider.features.addItem(feature);
			_sequenceProvider = _referenceSequenceProvider;
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testRemoveSequenceFnSn1FcSn1():void
		{
			_sequenceProvider.removeSequence(5, 8);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(7, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(17, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(22, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(27, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(37, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(47, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(52, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[1].end);
			
		}
		
		[Test]
		public function testRemoveSequenceFnSn2():void
		{
			_sequenceProvider.removeSequence(35, 38);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(10, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(20, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(25, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(30, (features[0] as Feature).locations[1].end);
			Assert.assertEquals(37, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(47, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(52, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[1].end);
		}
		
		[Test]
		public function testRemoveSequenceFnSn3A():void
		{
			_sequenceProvider.removeSequence(8, 31);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(1, features.length);
			Assert.assertEquals(17, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(27, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(32, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[0] as Feature).locations[1].end);
		}
		
		[Test]
		public function testRemoveSequenceFnSn4():void
		{
			_sequenceProvider.removeSequence(15, 22);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(10, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(15, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(18, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(23, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(33, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(43, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(48, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[1].end);
		}
		
		[Test]
		public function testRemoveSequenceFnSn5():void
		{
			_sequenceProvider.removeSequence(8, 23);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(8, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(15, (features[0] as Feature).locations[0].end);

			Assert.assertEquals(25, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(35, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(40, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[1].end);
		}
		
		
		[Test]
		public function testRemoveSequenceFnSn6():void
		{
			_sequenceProvider.removeSequence(25, 33);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(10, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(25, (features[0] as Feature).locations[0].end);
			
			Assert.assertEquals(32, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(42, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(47, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[1].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSn1():void
		{
			_sequenceProvider.removeSequence(32, 37);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(10, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(20, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(25, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(30, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(35, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(45, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(50, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[1].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSn1b():void
		{
			_sequenceProvider.removeSequence(39, 40);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(10, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(20, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(25, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(30, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(39, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(49, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(54, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[1].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSn2():void
		{
			_sequenceProvider.removeSequence(45, 55);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(10, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(20, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(25, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(30, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(40, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[0].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSn3():void
		{
			_sequenceProvider.removeSequence(2, 4);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(8, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(18, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(23, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(28, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(38, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(48, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(53, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(3, (features[1] as Feature).locations[1].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSn4():void
		{
			_sequenceProvider.removeSequence(35, 45);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(10, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(20, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(25, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(30, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(35, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(40, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(45, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[1].end);
		}
		
		public function testRemoveSequenceFcSn5():void
		{
			_sequenceProvider.removeSequence(35, 45);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(10, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(20, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(25, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(30, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(35, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(40, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(45, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(5, (features[1] as Feature).locations[1].end);
		}
		
		
		[Test]
		public function testRemoveSequenceFcSn6():void
		{
			_sequenceProvider.removeSequence(3, 45);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(1, features.length);
			Assert.assertEquals(3, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(8, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(13, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(3, (features[0] as Feature).locations[1].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSc1():void
		{
			_sequenceProvider.removeSequence(53, 3);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(7, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(17, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(22, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(27, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(37, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(47, (features[1] as Feature).locations[0].end);
			Assert.assertEquals(0, (features[1] as Feature).locations[1].start);
			Assert.assertEquals(2, (features[1] as Feature).locations[1].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSc2():void
		{
			_sequenceProvider.removeSequence(53, 8);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(2, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(12, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(17, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(22, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(1, (features[1] as Feature).locations.length);
			Assert.assertEquals(32, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(0, (features[1] as Feature).locations[0].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSc3():void
		{
			_sequenceProvider.removeSequence(35, 3);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(2, features.length);
			Assert.assertEquals(7, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(17, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(22, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(27, (features[0] as Feature).locations[1].end);
			
			Assert.assertEquals(1, (features[1] as Feature).locations.length);
			Assert.assertEquals(0, (features[1] as Feature).locations[0].start);
			Assert.assertEquals(2, (features[1] as Feature).locations[0].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSc4():void
		{
			_sequenceProvider.removeSequence(35, 8);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(1, features.length);
			Assert.assertEquals(2, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(12, (features[0] as Feature).locations[0].end);
			Assert.assertEquals(17, (features[0] as Feature).locations[1].start);
			Assert.assertEquals(22, (features[0] as Feature).locations[1].end);
		}

		[Test]
		public function testRemoveSequenceFcSc5():void
		{
			_sequenceProvider.removeSequence(51, 41);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(1, features.length);
			Assert.assertEquals(0, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(10, (features[0] as Feature).locations[0].end);
		}
		
		[Test]
		public function testRemoveSequenceFcSc6():void
		{
			_sequenceProvider.removeSequence(4, 1);
			var features:ArrayCollection = _sequenceProvider.features;
			Assert.assertEquals(1, features.length);
			Assert.assertEquals(0, (features[0] as Feature).locations[0].start);
			Assert.assertEquals(3, (features[0] as Feature).locations[0].end);
		}
		
	}
}