package org.jbei.model.fields
{
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.EntryTypeField;
	import org.jbei.model.StrainWithPlasmid;
	import org.jbei.model.registry.Attachment;
	import org.jbei.model.registry.EntryFundingSource;
	import org.jbei.model.registry.FundingSource;
	import org.jbei.model.registry.Link;
	import org.jbei.model.registry.Name;
	import org.jbei.model.registry.Plasmid;
	import org.jbei.model.registry.SelectionMarker;
	import org.jbei.model.registry.Sequence;
	import org.jbei.model.registry.Strain;
	import org.jbei.model.save.EntrySet;
	import org.jbei.model.save.StrainWithPlasmidSet;
	import org.jbei.model.util.ZipFileUtil;
	import org.jbei.view.EntryType;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.GridRow;
	
	public class StrainWithPlasmidFields implements EntryFields
	{
		public static const PRINCIPAL_INVESTIGATOR:EntryTypeField = new EntryTypeField( PRINCIPAL_INVESTIGATOR, "Principal Investigator", true ); 		
		public static const FUNDING_SOURCE:EntryTypeField = new EntryTypeField( FUNDING_SOURCE, "Funding Source", false );
		public static const INTELLECTUAL_PROP_INFO:EntryTypeField = new EntryTypeField( INTELLECTUAL_PROP_INFO, "Intellectual Property", false );
		public static const BIO_SAFETY_LEVEL:EntryTypeField = new EntryTypeField( BIO_SAFETY_LEVEL, "Bio Safety Level", true );
		
		// plasmid portion
		public static const PLASMID_NAME:EntryTypeField = new EntryTypeField( PLASMID_NAME, "Plasmid Name", true ); 
		public static const PLASMID_ALIAS:EntryTypeField = new EntryTypeField( PLASMID_ALIAS, "Plasmid Alias", false );		
		public static const PLASMID_KEYWORDS:EntryTypeField = new EntryTypeField( PLASMID_KEYWORDS, "Plasmid Keywords", false );		
		public static const PLASMID_SUMMARY:EntryTypeField = new EntryTypeField( PLASMID_SUMMARY, "Plasmid Summary", true ); 
		public static const PLASMID_NOTES:EntryTypeField = new EntryTypeField( PLASMID_NOTES, "Plasmid Notes", false ); 
		public static const PLASMID_REFERENCES:EntryTypeField = new EntryTypeField( PLASMID_REFERENCES, "Plasmid References", false );
		public static const PLASMID_LINKS:EntryTypeField = new EntryTypeField( PLASMID_LINKS, "Plasmid Links", false );
		public static const PLASMID_STATUS:EntryTypeField = new EntryTypeField( PLASMID_STATUS, "Plasmid Status", true );
		public static const CIRCULAR:EntryTypeField = new EntryTypeField( CIRCULAR, "Circular", true );
		public static const PLASMID_BACKBONE:EntryTypeField = new EntryTypeField( PLASMID_BACKBONE, "Plasmid Backbone", false );
		public static const PLASMID_PROMOTERS:EntryTypeField = new EntryTypeField( PLASMID_PROMOTERS, "Plasmid Promoters", false );
		public static const PLASMID_ORIGIN_OF_REPLICATION:EntryTypeField = new EntryTypeField( PLASMID_ORIGIN_OF_REPLICATION, "Plasmid Origin of Replication", false );
		public static const PLASMID_SEQUENCE_FILENAME:EntryTypeField = new EntryTypeField( PLASMID_SEQUENCE_FILENAME, "Plasmid Sequence FileName", false ); 
		public static const PLASMID_ATTACHMENT_FILENAME:EntryTypeField = new EntryTypeField( PLASMID_ATTACHMENT_FILENAME, "Plasmid Attachment FileName", false );
		public static const PLASMID_SELECTION_MARKERS:EntryTypeField = new EntryTypeField( PLASMID_SELECTION_MARKERS, "Plasmid Selection Markers", false ); 
		
		// strain portion
		public static const STRAIN_NUMBER:EntryTypeField = new EntryTypeField( STRAIN_NUMBER, "Strain Number", true ); 
		public static const STRAIN_ALIAS:EntryTypeField = new EntryTypeField( STRAIN_ALIAS, "Strain Alias", false );		
		public static const STRAIN_SUMMARY:EntryTypeField = new EntryTypeField( STRAIN_SUMMARY, "Strain Summary", true ); 
		public static const STRAIN_NOTES:EntryTypeField = new EntryTypeField( STRAIN_NOTES, "Strain Notes", false ); 
		public static const STRAIN_REFERENCES:EntryTypeField = new EntryTypeField( STRAIN_REFERENCES, "Strain References", false );
		public static const STRAIN_LINKS:EntryTypeField = new EntryTypeField( STRAIN_LINKS, "Strain Links", false );
		public static const STRAIN_STATUS:EntryTypeField = new EntryTypeField( STRAIN_STATUS, "Strain Status", true );
		public static const STRAIN_SELECTION_MARKERS:EntryTypeField = new EntryTypeField( STRAIN_SELECTION_MARKERS, "Strain Selection Markers", false ); 
		public static const STRAIN_PARENTAL_STRAIN:EntryTypeField = new EntryTypeField( STRAIN_PARENTAL_STRAIN, "Strain Parental Strain", false );
		public static const STRAIN_GENOTYPE_OR_PHENOTYPE:EntryTypeField = new EntryTypeField( STRAIN_GENOTYPE_OR_PHENOTYPE, "Strain Genotype/Phenotype", false );
		public static const STRAIN_PLASMIDS:EntryTypeField = new EntryTypeField( STRAIN_PLASMIDS, "Strain Plasmids", false );
		public static const STRAIN_KEYWORDS:EntryTypeField = new EntryTypeField( STRAIN_KEYWORDS, "Strain Keywords", false );		
		public static const STRAIN_SEQUENCE_FILENAME:EntryTypeField = new EntryTypeField( STRAIN_SEQUENCE_FILENAME, "Strain Sequence FileName", false ); 
		public static const STRAIN_ATTACHMENT_FILENAME:EntryTypeField = new EntryTypeField( STRAIN_ATTACHMENT_FILENAME, "Strain Attachment FileName", false );
		
		private var _fields:ArrayCollection;
		private var _zipUtil:ZipFileUtil;
		private var _errors:ArrayCollection;		// <FieldCellError>
		private var _set:StrainWithPlasmidSet;
		
		public function set sequenceZipFile( file:FileReference ) : void
		{
			_zipUtil = new ZipFileUtil( file );
		}
		
		public function set attachmentZipFile( file:FileReference ) : void
		{
		}
		
		public function get errors() : ArrayCollection
		{
			return _errors;
		}
		
		public function get entrySet() : EntrySet
		{		
			return this._set;
		}
		
		public function StrainWithPlasmidFields()
		{
			_fields = new ArrayCollection();
			_errors = new ArrayCollection();
			_set = new StrainWithPlasmidSet( EntryType.STRAIN_WITH_PLASMID );
			
			_fields.addItem( PRINCIPAL_INVESTIGATOR );
			_fields.addItem( FUNDING_SOURCE );
			_fields.addItem( INTELLECTUAL_PROP_INFO );
			_fields.addItem( BIO_SAFETY_LEVEL );
			_fields.addItem( PLASMID_NAME );
			_fields.addItem( PLASMID_ALIAS );
			_fields.addItem( PLASMID_KEYWORDS );
			_fields.addItem( PLASMID_SUMMARY );
			_fields.addItem( PLASMID_NOTES );
			_fields.addItem( PLASMID_REFERENCES );
			_fields.addItem( PLASMID_LINKS );
			_fields.addItem( PLASMID_STATUS );
			_fields.addItem( CIRCULAR );
			_fields.addItem( PLASMID_BACKBONE );
			_fields.addItem( PLASMID_PROMOTERS );
			_fields.addItem( PLASMID_ORIGIN_OF_REPLICATION );
			_fields.addItem( PLASMID_SEQUENCE_FILENAME );
			_fields.addItem( PLASMID_ATTACHMENT_FILENAME );
			_fields.addItem( PLASMID_SELECTION_MARKERS );
			_fields.addItem( STRAIN_NUMBER );
			_fields.addItem( STRAIN_ALIAS );
			_fields.addItem( STRAIN_LINKS );
			_fields.addItem( STRAIN_STATUS );
			_fields.addItem( STRAIN_SELECTION_MARKERS );
			_fields.addItem( STRAIN_PARENTAL_STRAIN );
			_fields.addItem( STRAIN_GENOTYPE_OR_PHENOTYPE );
			_fields.addItem( STRAIN_PLASMIDS );
			_fields.addItem( STRAIN_KEYWORDS );
			_fields.addItem( STRAIN_SUMMARY );
			_fields.addItem( STRAIN_NOTES );
			_fields.addItem( STRAIN_REFERENCES );
			_fields.addItem( STRAIN_SEQUENCE_FILENAME );
			_fields.addItem( STRAIN_ATTACHMENT_FILENAME );
		}
		
		public function get fields() : ArrayCollection
		{
			return _fields;
		}
		
		public function extractFromRow( row:GridRow ) : Object
		{
			this._errors.removeAll();
			
			var strain:Strain = new Strain();
			strain.recordType = "strain";
			var plasmid:Plasmid = new Plasmid();
			plasmid.recordType = "plasmid";
			
			for( var j:int = 0; j < this._fields.length; j += 1 )
			{
				var field:EntryTypeField = fields.getItemAt( j ) as EntryTypeField;
				var cell:GridCell = row.cellAt( j );
				var value:String = cell.text;
				
				if( value.length == 0 )
				{
					if( field.required )
					{
						this._errors.addItem( new FieldCellError( cell, field.name + " is required and cannot be empty." ) );
					}
					continue;
				}
				else
					extractField( field, cell, strain, plasmid );
			}

			return new StrainWithPlasmid( strain, plasmid);
		}
		
		private function createFundingSources( strain:Strain, plasmid:Plasmid ) : void
		{
			// check to make sure that it has not already been created
			if( !strain.entryFundingSources || strain.entryFundingSources.length == 0 )
			{
				// strain funding sources
				var newStrainFundingSource:EntryFundingSource = new EntryFundingSource();
				newStrainFundingSource.entry = strain;
				var fundingSource:FundingSource = new FundingSource();
				fundingSource.fundingSource = "";
				newStrainFundingSource.fundingSource = fundingSource;
				var strainFundingSources:ArrayCollection = new ArrayCollection();				// <EntryFundingSource>
				strainFundingSources.addItem( newStrainFundingSource );
				strain.entryFundingSources = strainFundingSources;
			}
			
			if( !plasmid.entryFundingSources || plasmid.entryFundingSources.length == 0 ) 
			{
				// plasmid funding source
				var newPlasmidFundingSource:EntryFundingSource = new EntryFundingSource();
				newPlasmidFundingSource.entry = plasmid;
				newPlasmidFundingSource.fundingSource = fundingSource;
				var plasmidFundingSources:ArrayCollection = new ArrayCollection();				// <EntryFundingSource>
				plasmidFundingSources.addItem( newPlasmidFundingSource );
				plasmid.entryFundingSources = plasmidFundingSources;
			}
		}
		
		private function extractField( field:EntryTypeField, cell:GridCell, strain:Strain, plasmid:Plasmid ) : void
		{
			var value:String = cell.text;
			
			switch( field )
			{
				case PRINCIPAL_INVESTIGATOR:
					this.createFundingSources( strain, plasmid );
					var strainSource:EntryFundingSource = strain.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					strainSource.fundingSource.principalInvestigator = value;
					var plasmidSource:EntryFundingSource = plasmid.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					plasmidSource.fundingSource.principalInvestigator = value;
					break;
				
				case FUNDING_SOURCE:
					this.createFundingSources( strain, plasmid );
					var strainS:EntryFundingSource = strain.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					strainS.fundingSource.fundingSource = value;
					var plasmidS:EntryFundingSource = plasmid.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					plasmidS.fundingSource.fundingSource = value;
					break;
				
				case INTELLECTUAL_PROP_INFO:
					plasmid.intellectualProperty = value;
					strain.intellectualProperty = "";
					break;
				
				case BIO_SAFETY_LEVEL:
					if( isNaN( Number( value ) ) )
					{
						this._errors.addItem( new FieldCellError( cell, "Value must be '1' or '2'" ) );
						break;
					}
					else
					{
						var num:int = parseInt( value );
						if( num < 1 || num > 2 )
						{
							this._errors.addItem( new FieldCellError( cell, "Value must be '1' or '2'" ) );
							break;
						}
						strain.bioSafetyLevel = num;
						plasmid.bioSafetyLevel = num;
					}
					break;
				
				case PLASMID_NAME:
					var result:ArrayCollection = new ArrayCollection(); // <Name>
					var names:Array = value.split( "\\s*, +\\s*" );
					for( var i:int = 0; i < names.length; i += 1 )
					{
						var nameStr:String = names[i];
						var name:Name = new Name();
						name.name = nameStr;
						result.addItem( name );
					}
					
					plasmid.names = result;
					break;
				
				case PLASMID_ALIAS:
					plasmid.alias = value;
					break;
				
				case PLASMID_KEYWORDS:
					plasmid.keywords = value;
					break; 
				
				case PLASMID_SUMMARY:
					plasmid.shortDescription = value;
					break;
				
				case PLASMID_NOTES:
					plasmid.longDescription = value;
					break;
				
				case PLASMID_REFERENCES:
					plasmid.references = value;
					break;
				
				case PLASMID_LINKS:
					var result2:ArrayCollection = new ArrayCollection(); // <Link>
					var links:Array = value.split( "\\s*,+\\s*" );
					for( var linkIter:int = 0; linkIter < links.length; linkIter += 1 )
					{
						var linkStr:String = links[linkIter];
						var link:Link = new Link();
						link.link = linkStr;
						result2.addItem( link );
					}
					plasmid.links = result2;
					break;
				
				case PLASMID_STATUS:
					var comp:String = value.toLowerCase();
					// TODO : "magic" strings
					if( comp == "complete" || comp == "in progress" || comp == "planned" )
						plasmid.status = comp;
					else
						this._errors.addItem( new FieldCellError( cell, field.name + "'s value must be one of [Complete, In Progress, Planned]" ) );
					break;
				
				case CIRCULAR:
					switch( value ) 
					{
						case "1":
						case "true":
						case "yes":
							plasmid.circular = new Boolean( true );
							break;
						
						case "0":
						case "false":
						case "no":
							plasmid.circular = new Boolean( false );
							break;
						
						default:
							this._errors.addItem( new FieldCellError( cell, "Please enter \"true\" or \"yes\" or \"false\" or \"no\"!" ) );
					}
					break;

				case PLASMID_BACKBONE:
					plasmid.backbone = value;
					break;
				
				case PLASMID_PROMOTERS:
					plasmid.promoters = value;
					break;
				
				case PLASMID_ORIGIN_OF_REPLICATION:
					plasmid.originOfReplication = value;
					break;
				
				case PLASMID_SEQUENCE_FILENAME:
					if( !this._zipUtil && value.length > 0 )
					{
						// TODO : consider highlighting zip archive upload button in this instance
						this._errors.addItem( new FieldCellError( cell, "Please upload sequence zip archive!" ) );
					}
					else if( value.length > 0 && ( this._zipUtil && !this._zipUtil.containsFile( value ) ) )
					{
						this._errors.addItem( new FieldCellError( cell, "File with name " + value + " not found in zip archive!" ) );
					}
					else
					{
						var seq:Sequence = new Sequence();
						seq.filename = value;
						seq.sequenceUser = value;
						plasmid.sequence = seq;
					}
					break;
				
				case PLASMID_ATTACHMENT_FILENAME:
					var attachment:Attachment = new Attachment();
					attachment.fileName = value;
					attachment.entry = plasmid;
					plasmid.attachment = attachment;
					break;
				
				case PLASMID_SELECTION_MARKERS:
					var markers:ArrayCollection = new ArrayCollection();
					if( value.length == 0 )
						break;
					
					var markerStrings:Array = value.split( "\\s*, +\\s*" );
					
					for( var markerIter:int = 0; markerIter < markerStrings.length; markerIter += 1 )
					{
						var marker:SelectionMarker = new SelectionMarker();
						marker.entry = plasmid;
						marker.name = markerStrings[markerIter];
						markers.addItem( marker );
					}
					plasmid.selectionMarkers = markers;
					break;
				
				// strain fields
				case STRAIN_NUMBER:
					var strainNames:ArrayCollection = new ArrayCollection(); // <Name>
					var strainName:Array = value.split( "\\s*, +\\s*" );
					for( var j:int = 0; j < strainName.length; j += 1 )
					{
						var nameString:String = strainName[i];
						var actualName:Name = new Name();
						actualName.name = nameString;
						strainNames.addItem( actualName );
					}
					
					strain.names = strainNames;
					break;
				
				case STRAIN_ALIAS:
					strain.alias = value;
					break;
				
				case STRAIN_LINKS:
					var linksCollection:ArrayCollection = new ArrayCollection(); // <Link>
					var linksValue:Array = value.split( "\\s*,+\\s*" );
					for( linkIter = 0; linkIter < linksCollection.length; linkIter += 1 )
					{
						linkStr = links[linkIter];
						link = new Link();
						link.link = linkStr;
						linksCollection.addItem( link );
					}
					strain.links = linksCollection;
					break;
					
				case STRAIN_STATUS:
					var status:String = value.toLowerCase();
					// TODO : "magic" strings
					if( status == "complete" || status == "in progress" || status == "planned" )
						strain.status = status;
					else
						this._errors.addItem( new FieldCellError( cell, field.name + "'s value must be one of [Complete, In Progress, Planned]" ) );
					break;
				
				case STRAIN_SELECTION_MARKERS:
					var strainMarkers:ArrayCollection = new ArrayCollection();
					if( value.length == 0 )
						break;
					
					var strainMarkerStrings:Array = value.split( "\\s*, +\\s*" );
					
					for( markerIter = 0; markerIter < strainMarkerStrings.length; markerIter += 1 )
					{
						var selectionMarker:SelectionMarker = new SelectionMarker();
						selectionMarker.entry = strain;
						selectionMarker.name = strainMarkerStrings[markerIter];
						strainMarkers.addItem( selectionMarker );
					}
					strain.selectionMarkers = strainMarkers;
					break;
				
				case STRAIN_PARENTAL_STRAIN:
					strain.host = value;
					break;
				
				case STRAIN_GENOTYPE_OR_PHENOTYPE:
					strain.genotypePhenotype = value;
					break;
				
				case STRAIN_PLASMIDS:
					strain.plasmids = value;
					break;
				
				case STRAIN_KEYWORDS:
					strain.keywords = value;
					break;
				
				case STRAIN_SUMMARY:
					strain.shortDescription = value;
					break;
				
				case STRAIN_NOTES:
					strain.longDescription = value;
					break;
				
				case STRAIN_REFERENCES:
					strain.references = value;
					break;
				
				case STRAIN_SEQUENCE_FILENAME:
					// zip uploaded but no entries is considered ok
					if( !this._zipUtil && value.length > 0 )
						this._errors.addItem( new FieldCellError( cell, "Please upload sequence zip archive!" ) );
					else if( value.length > 0 && ( this._zipUtil && !this._zipUtil.containsFile( value ) ) )
						this._errors.addItem( new FieldCellError( cell, "File with name " + value + " not found in zip archive!" ) );
					else
					{
						var sequence:Sequence = new Sequence();
						sequence.filename = value;
						sequence.sequenceUser = value;
						strain.sequence = sequence;
					}
					break;
				
				case STRAIN_ATTACHMENT_FILENAME:
					var strainAttachment:Attachment = new Attachment();
					strainAttachment.fileName = value;
					strain.attachment = strainAttachment;
					break;
			}
		}
	}
}