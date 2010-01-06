package org.jbei.lib
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.DNASequence;
	import org.jbei.lib.common.IMemento;
	
	public class FeaturedSequenceMemento implements IMemento
	{
		private var _name:String;
		private var _circular:Boolean;
		private var _sequence:DNASequence;
		private var _oppositeSequence:DNASequence;
		private var _features:ArrayCollection;
		
		// Contructor
		public function FeaturedSequenceMemento(name:String, circular:Boolean, sequence:DNASequence, oppositeSequence:DNASequence, features:ArrayCollection)
		{
			_name = name;
			_circular = circular;
			_sequence = sequence;
			_oppositeSequence = oppositeSequence;
			_features = features;
		}
		
		// Properties
		public function get name():String
		{
			return _name;
		}
		
		public function get circular():Boolean
		{
			return _circular;
		}
		
		public function get sequence():DNASequence
		{
			return _sequence;
		}
		
		public function get oppositeSequence():DNASequence
		{
			return _oppositeSequence;
		}
		
		public function get features():ArrayCollection
		{
			return _features;
		}
	}
}
