package org.jbei.registry.model.vo
{
	import mx.collections.ArrayCollection;
	
	[RemoteClass(alias="org.jbei.registry.lib.models.Sequence")]
	public class Sequence
	{
		public var entry:Object;
		
		private var _id:int;
		private var _sequence:String;
		private var _sequenceUser:String;
		private var _fwdHash:String;
		private var _revHash:String;
		private var _sequenceFeatures:ArrayCollection; /* of SequenceFeature */
		
		// Constructor
		public function Sequence(sequence:String = null, fwdHash:String = null, revHash:String = null, sequenceFeatures:ArrayCollection /* of SequenceFeature */ = null)
		{
			_sequence = sequence;
			_fwdHash = fwdHash;
			_revHash = revHash;
			_sequenceFeatures = sequenceFeatures;
		}
		
		// Properties
		public function get id():int
		{
			return _id;
		}
		
		public function set id(value:int):void	
		{
			_id = value;
		}
		
		public function get sequence():String
		{
			return _sequence;
		}
		
		public function set sequence(value:String):void	
		{
			_sequence = value;
		}
		
		public function get sequenceUser():String
		{
			return _sequenceUser;
		}
		
		public function set sequenceUser(value:String):void	
		{
			_sequenceUser = value;
		}
		
		public function get fwdHash():String
		{
			return _fwdHash;
		}
		
		public function set fwdHash(value:String):void	
		{
			_fwdHash = value;
		}
		
		public function get revHash():String
		{
			return _revHash;
		}
		
		public function set revHash(value:String):void	
		{
			_revHash = value;
		}
		
		public function get sequenceFeatures():ArrayCollection /* of SequenceFeature */
		{
			return _sequenceFeatures;
		}
		
		public function set sequenceFeatures(value:ArrayCollection /* of SequenceFeature */):void
		{
			_sequenceFeatures = value;
		}
	}
}
