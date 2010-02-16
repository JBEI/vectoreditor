package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;
	
	[RemoteClass(alias="org.jbei.ice.lib.models.Entry")]
	public class Entry
	{
		private var _id:int;
		private var _recordId:String;
		private var _versionId:String;
		private var _recordType:String;
		private var _owner:String;
		private var _ownerEmail:String;
		private var _creator:String;
		private var _creatorEmail:String;
		private var _alias:String;
		private var _keywords:String;
		private var _status:String;
		private var _shortDescription:String;
		private var _longDescription:String;
		private var _references:String;
		private var _creationTime:Date;
		private var _modificationTime:Date;
		private var _sequence:Sequence;
		private var _selectionMarkers:ArrayCollection; /* of SelectionMarker */
		private var _links:ArrayCollection; /* of Link */
		private var _names:ArrayCollection; /* of Name */
		private var _partNumbers:ArrayCollection; /* of PartNumber */
		private var _bioSafetyLevel:int;
		private var _intellectualProperty:String;
		private var _entryFundingSources:ArrayCollection; /* of FundingSource */
		
		// Constructor
		public function Entry() {}
		
		// Properties
		public function get id():int
		{
			return _id;
		}
		
		public function set id(value:int):void	
		{
			_id = value;
		}
		
		public function get recordId():String
		{
			return _recordId;
		}
		
		public function set recordId(value:String):void	
		{
			_recordId = value;
		}
		
		public function get versionId():String
		{
			return _versionId;
		}
		
		public function set versionId(value:String):void	
		{
			_versionId = value;
		}
				
		public function get keywords():String
		{
			return _keywords;
		}
		
		public function set keywords(value:String):void	
		{
			_keywords = value;
		}

		public function get recordType():String
		{
			return _recordType;
		}
		
		public function set recordType(value:String):void	
		{
			_recordType = value;
		}
		
		public function get owner():String
		{
			return _owner;
		}
		
		public function set owner(value:String):void	
		{
			_owner = value;
		}
		
		public function get ownerEmail():String
		{
			return _ownerEmail;
		}
		
		public function set ownerEmail(value:String):void	
		{
			_ownerEmail = value;
		}
		
		public function get creator():String
		{
			return _creator;
		}
		
		public function set creator(value:String):void	
		{
			_creator = value;
		}
		
		public function get creatorEmail():String
		{
			return _creatorEmail;
		}
		
		public function set creatorEmail(value:String):void	
		{
			_creatorEmail = value;
		}
		
		public function get alias():String
		{
			return _alias;
		}
		
		public function set alias(value:String):void	
		{
			_alias = value;
		}
		
		public function get status():String
		{
			return _status;
		}
		
		public function set status(value:String):void	
		{
			_status = value;
		}
		
		public function get shortDescription():String
		{
			return _shortDescription;
		}
		
		public function set shortDescription(value:String):void	
		{
			_shortDescription = value;
		}
		
		public function get longDescription():String
		{
			return _longDescription;
		}
		
		public function set longDescription(value:String):void	
		{
			_longDescription = value;
		}
		
		public function get references():String
		{
			return _references;
		}
		
		public function set references(value:String):void	
		{
			_references = value;
		}
		
		public function get creationTime():Date
		{
			return _creationTime;
		}
		
		public function set creationTime(value:Date):void	
		{
			_creationTime = value;
		}
		
		public function get modificationTime():Date
		{
			return _modificationTime;
		}
		
		public function set modificationTime(value:Date):void	
		{
			_modificationTime = value;
		}
		
		public function get sequence():Sequence
		{
			return _sequence;
		}
		
		public function set sequence(value:Sequence):void	
		{
			_sequence = value;
		}
		
		public function get selectionMarkers():ArrayCollection /* of SelectionMarker */
		{
			return _selectionMarkers;
		}
		
		public function set selectionMarkers(value:ArrayCollection /* of SelectionMarker */):void	
		{
			_selectionMarkers = value;
		}
		
		public function get links():ArrayCollection /* of Link */
		{
			return _links;
		}
		
		public function set links(value:ArrayCollection /* of Link */):void	
		{
			_links = value;
		}
		
		public function get names():ArrayCollection /* of Name */
		{
			return _names;
		}
		
		public function set names(value:ArrayCollection /* of Name */):void
		{
			_names = value;
		}
		
		public function get partNumbers():ArrayCollection /* of PartNumber */
		{
			return _partNumbers;
		}
		
		public function set partNumbers(value:ArrayCollection /* of PartNumber */):void
		{
			_partNumbers = value;
		}
		
		// Public Methods
		public function combinedName(delimiter:String = ", "):String
		{
			var result:String = "";
			
			if(! _names) return result;
			
			result = _names.toArray().join(delimiter);
			
			return result;
		}
		
		public function get bioSafetyLevel():int
		{
			return _bioSafetyLevel;
		}
		
		public function set bioSafetyLevel(value:int):void	
		{
			_bioSafetyLevel = value;
		}
		
		public function get intellectualProperty():String
		{
			return _intellectualProperty;
		}
		
		public function set intellectualProperty(value:String):void	
		{
			_intellectualProperty = value;
		}
		
		public function get entryFundingSources():ArrayCollection
		{
			return _entryFundingSources;
		}
		
		public function set entryFundingSources(value:ArrayCollection):void	
		{
			_entryFundingSources = value;
		}
	}
}
