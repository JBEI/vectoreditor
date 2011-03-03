package org.jbei.model.registry
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.registry.PartNumber;

	[RemoteClass(alias="org.jbei.ice.lib.models.Entry")]
	public class Entry
	{
		private var _alias:String;
		private var _links:ArrayCollection = new ArrayCollection();			  // <Link>
		private var _names:ArrayCollection = new ArrayCollection(); 		  // <Name> required
		private var _partNumbers:ArrayCollection = new ArrayCollection();	  // <PartNumber>
		private var _status:String; 				  
		private var _keywords:String;
		private var _shortDescription:String;		  // aka summary. required (text area)
		private var _references:String;
		private var _bioSafetyLevel:int; 			  // 1 or 2 
		private var _intellectualProperty:String;
		private var _fundingSources:ArrayCollection = new ArrayCollection();  // <FundingSource>
		private var _principalInvestigator:String;
		private var _longDescription:String;
		private var _creationTime:Date;
		private var _selectionMarkers:ArrayCollection = new ArrayCollection(); // <SelectionMarker>
		private var _id:Number;
		private var _owner:String;
		private var _creator:String;
		private var _creatorEmail:String;
		private var _ownerEmail:String;
		private var _modificationTime:Date;
		private var _versionId:String;
		private var _recordType:String;
		
		// extras not present in ice
		private var _sequence:Sequence;
		private var _attachment:Attachment;
		
		public function Entry()
		{
		}
		
		public function get versionId() : String
		{
			return this._versionId;
		}
		
		public function set versionId( id:String ) : void
		{
			this._versionId = id;
		}
		
		public function get recordType() : String
		{
			return this._recordType;
		}
		
		public function set recordType( type:String ) : void
		{
			this._recordType = type;
		}
		
		public function set ownerEmail( email:String ) : void
		{
			this._ownerEmail = email;
		}
		
		public function get ownerEmail() : String
		{
			return this._ownerEmail;
		}
		
		public function get owner() : String
		{
			return this._owner;
		}
		
		public function set owner( owner:String ) : void
		{
			this._owner = owner;
		}
		
		public function get id() : Number
		{
			return this._id;
		}
		
		public function set id( id:Number ) : void
		{
			this._id = id;
		}
		
		public function set creator( creator:String ) : void
		{
			this._creator = creator;
		}
		
		public function get creator() : String
		{
			return this._creator;
		}
		
		public function set creatorEmail( email:String ) : void
		{
			this._creatorEmail = email;
		}
		
		public function get creatorEmail() : String
		{
			return this._creatorEmail;
		}
		
		public function set longDescription( notes:String ) : void
		{
			this._longDescription = notes;
		}
		
		public function get longDescription() : String
		{
			return this._longDescription;
		}
		
		public function set principalInvestigator( principalInvestigator:String ) : void
		{
			this._principalInvestigator = principalInvestigator;
		}
		
		public function get principalInvestigator() : String
		{
			return this._principalInvestigator;
		}
		
		public function set entryFundingSources( fundingSources:ArrayCollection ) : void
		{
			this._fundingSources.removeAll();
			if( fundingSources )
				this._fundingSources.addAll( fundingSources );
		}
		
		public function get entryFundingSources() : ArrayCollection
		{
			return this._fundingSources;
		}
		
		public function set intellectualProperty( intellectualProperty:String ) : void
		{
			this._intellectualProperty = intellectualProperty;
		}
		
		public function get intellectualProperty() : String
		{
			return this._intellectualProperty;
		}
		
		public function set bioSafetyLevel( safetyLevel:int ) : void
		{
			this._bioSafetyLevel = safetyLevel;
		}
		
		public function get bioSafetyLevel() : int
		{
			return this._bioSafetyLevel;
		}
		
		public function set references( references:String ) : void
		{
			this._references = references;
		}
		
		public function get references() : String
		{
			return this._references;
		}
		
		public function set shortDescription( shortDescription:String ) : void
		{
			this._shortDescription = shortDescription;
		}
		
		public function get shortDescription() : String
		{
			return this._shortDescription;
		}
		
		public function set keywords( keywords:String ) : void
		{
			this._keywords = keywords;
		}
		
		public function get keywords() : String
		{
			return this._keywords;
		}
		
		public function set status( status:String ) : void
		{
			this._status = status;
		}
		
		public function get status() : String
		{
			return this._status;
		}
		
		public function get names() : ArrayCollection
		{
			return this._names;
		}
		
		public function set names( names:ArrayCollection ) : void
		{
			this._names.removeAll();
			if( names )
				this._names.addAll( names ); 
		}
		
		public function get onePartNumber() : PartNumber
		{
			var result:PartNumber = null;
			
			if( this._partNumbers && this._partNumbers.length > 0 )
				result = this._partNumbers.getItemAt( 0 ) as PartNumber;
			
			return result;
		}
		
		public function set partNumbers( input:ArrayCollection ) : void
		{
			this._partNumbers.removeAll();
			if( input )
				this._partNumbers.addAll( input );
		}
		
		public function get oneName() : Name
		{
			var result:Name = null;
			if( names && names.length > 0 )
				result = names.getItemAt( 0 ) as Name;
			
			return result;
		}
		public function set links( links:ArrayCollection ) : void
		{
			this.links.removeAll();
			if( links )
				this._links.addAll( links );
		}
		
		public function get links() : ArrayCollection
		{
			return this._links;
		}
		
		public function get alias() : String
		{
			return this._alias;
		}
		
		public function set alias( alias:String ) : void
		{
			this._alias = alias;
		}
		
		public function set creationTime( date:Date ) : void
		{
			this._creationTime = date;
		}
		
		public function set modificationTime( date:Date ) : void
		{
			this._modificationTime = date;
		}
		
		public function get modificationTime() : Date
		{
			return this._modificationTime;
		}
		
		public function set selectionMarkers( markers:ArrayCollection ) : void
		{
			this._selectionMarkers.removeAll();
			if( markers )
				this._selectionMarkers.addAll( markers );
		}
		
		public function get selectionMarkers() : ArrayCollection
		{
			return this._selectionMarkers;
		}
		
		public function get sequence( ): Sequence
		{
			return this._sequence;
		}
		
		public function set sequence( sequence:Sequence ) : void
		{
			this._sequence = sequence;
		}
		
		public function get attachment() : Attachment
		{
			return this._attachment;
		}
		
		public function set attachment( attachment:Attachment ) : void
		{
			this._attachment = attachment;
		}
	}
}