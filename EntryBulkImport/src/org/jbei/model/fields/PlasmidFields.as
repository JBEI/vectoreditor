package org.jbei.model.fields
{
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.EntryTypeField;
	import org.jbei.model.registry.Attachment;
	import org.jbei.model.registry.EntryFundingSource;
	import org.jbei.model.registry.FundingSource;
	import org.jbei.model.registry.Link;
	import org.jbei.model.registry.Name;
	import org.jbei.model.registry.Plasmid;
	import org.jbei.model.registry.SelectionMarker;
	import org.jbei.model.registry.Sequence;
	import org.jbei.model.save.EntrySet;
	import org.jbei.model.save.PlasmidSet;
	import org.jbei.model.util.ZipFileUtil;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.GridRow;
	
	public class PlasmidFields implements EntryFields
	{
		public static const PRINCIPAL_INVESTIGATOR:EntryTypeField = new EntryTypeField( PRINCIPAL_INVESTIGATOR, "Principal Investigator", true ); 		
		public static const FUNDING_SOURCE:EntryTypeField = new EntryTypeField( FUNDING_SOURCE, "Funding Source", false );
		public static const INTELLECTUAL_PROP_INFO:EntryTypeField = new EntryTypeField( INTELLECTUAL_PROP_INFO, "Intellectual Property", false );
		public static const BIO_SAFETY_LEVEL:EntryTypeField = new EntryTypeField( BIO_SAFETY_LEVEL, "Bio Safety Level", true );
		public static const NAME:EntryTypeField = new EntryTypeField( NAME, "Name", true ); 
		public static const ALIAS:EntryTypeField = new EntryTypeField( ALIAS, "Alias", false );		
		public static const KEYWORDS:EntryTypeField = new EntryTypeField( KEYWORDS, "Keywords", false );		
		public static const SUMMARY:EntryTypeField = new EntryTypeField( SUMMARY, "Summary", true ); 
		public static const NOTES:EntryTypeField = new EntryTypeField( NOTES, "Notes", false ); 
		public static const REFERENCES:EntryTypeField = new EntryTypeField( REFERENCES, "References", false );
		public static const LINKS:EntryTypeField = new EntryTypeField( LINKS, "Links", false );
		public static const STATUS:EntryTypeField = new EntryTypeField( STATUS, "Status", true );
		public static const SEQUENCE_FILENAME:EntryTypeField = new EntryTypeField( SEQUENCE_FILENAME, "Sequence Filename", false ); 
		public static const ATTACHMENT_FILENAME:EntryTypeField = new EntryTypeField( ATTACHMENT_FILENAME, "Attachment Filename", false );
		public static const SELECTION_MARKERS:EntryTypeField = new EntryTypeField( SELECTION_MARKERS, "Selection Markers", false ); 
		public static const CIRCULAR:EntryTypeField = new EntryTypeField( CIRCULAR, "Circular", false );  
		public static const BACKBONE:EntryTypeField = new EntryTypeField( BACKBONE, "Backbone", false );
		public static const PROMOTERS:EntryTypeField = new EntryTypeField( PROMOTERS, "Promoters", false );
		public static const ORIGIN_OF_REPLICATION:EntryTypeField = new EntryTypeField( ORIGIN_OF_REPLICATION, "Origin of Replication", false );
		
		private var _fields:ArrayCollection;
		private var _seqZip:ZipFileUtil;
		private var _errors:ArrayCollection;
		private var _set:PlasmidSet;
		
		public function set sequenceZipFile( file:FileReference ) : void
		{
			_seqZip = new ZipFileUtil( file );
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
		
		public function PlasmidFields() 
		{
			_fields = new ArrayCollection();
			_errors = new ArrayCollection();
			_set = new PlasmidSet();
			
			_fields.addItem( PRINCIPAL_INVESTIGATOR );
			_fields.addItem( FUNDING_SOURCE );
			_fields.addItem( INTELLECTUAL_PROP_INFO );
			_fields.addItem( BIO_SAFETY_LEVEL );
			_fields.addItem( NAME );
			_fields.addItem( ALIAS );
			_fields.addItem( KEYWORDS );
			_fields.addItem( SUMMARY );
			_fields.addItem( NOTES );
			_fields.addItem( REFERENCES );
			_fields.addItem( LINKS );
			_fields.addItem( STATUS );
			_fields.addItem( SEQUENCE_FILENAME );
			_fields.addItem( ATTACHMENT_FILENAME );
			_fields.addItem( SELECTION_MARKERS );
			_fields.addItem( CIRCULAR );
			_fields.addItem( BACKBONE );
			_fields.addItem( PROMOTERS );
			_fields.addItem( ORIGIN_OF_REPLICATION );
		}
		
		public function extractFromRow( row:GridRow ) : Object
		{
			this._errors.removeAll();
			
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
				{
					extractField( field, cell, plasmid );
				}
			}
			
			return plasmid;
		}
		
		private function createFundingSources( plasmid:Plasmid ) : void
		{
			if( plasmid.entryFundingSources && plasmid.entryFundingSources.length > 0 )
				return;
			
			var sources:ArrayCollection = new ArrayCollection();				// <EntryFundingSource>
			var fundingSource:FundingSource = new FundingSource();
			fundingSource.fundingSource = "";
			var newEntryFundingSource:EntryFundingSource = new EntryFundingSource();
			newEntryFundingSource.fundingSource = fundingSource;
			newEntryFundingSource.entry = plasmid;
			sources.addItem( newEntryFundingSource );
			plasmid.entryFundingSources = sources;
		}
		
		private function extractField( field:EntryTypeField, cell:GridCell, plasmid:Plasmid ) : void
		{
			var value:String = cell.text;
			
			switch( field )
			{
				case PRINCIPAL_INVESTIGATOR:
					createFundingSources( plasmid );
					var source:EntryFundingSource = plasmid.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					source.fundingSource.principalInvestigator = value;
					break;
				
				case FUNDING_SOURCE:
					createFundingSources( plasmid );
					var entrySource:EntryFundingSource = plasmid.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					entrySource.fundingSource.fundingSource = value;
					break;
				
				case INTELLECTUAL_PROP_INFO:
					plasmid.intellectualProperty = value;
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
						plasmid.bioSafetyLevel = num;
					}
					break;
				
				case NAME:
					var result:ArrayCollection = new ArrayCollection(); // <Name>
					var names:Array = value.split( "\\s*, +\\s*" );
					for( var i:int = 0; i < names.length; i += 1 )
					{
						var nameStr:String = names[i];
						var name:Name = new Name();
						name.entry = plasmid;
						name.name = nameStr;
						result.addItem( name );
					}
					
					plasmid.names = result;
					break;
				
				case ALIAS:
					plasmid.alias = value;
					break;
				
				case KEYWORDS:
					plasmid.keywords = value;
					break; 
				
				case SUMMARY:
					plasmid.shortDescription = value;
					break;
				
				case NOTES:
					plasmid.longDescription = value;
					break;
				
				case REFERENCES:
					plasmid.references = value;
					break;
				
				case LINKS:
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
				
				case STATUS:
					var comp:String = value.toLowerCase();
					// TODO : "magic" strings
					if( comp == "complete" || comp == "in progress" || comp == "planned" )
						plasmid.status = comp;
					else
						this._errors.addItem( new FieldCellError( cell, field.name + "'s value must be one of [Complete, In Progress, Planned]" ) );
					break;
				
				case SEQUENCE_FILENAME:
					if( !this._seqZip && value.length > 0 )
						this._errors.addItem( new FieldCellError( cell, "Please upload sequence zip archive!" ) );
					else if( value.length > 0 && ( this._seqZip && !this._seqZip.containsFile( value ) ) )
						this._errors.addItem( new FieldCellError( cell, "File \"" + value + "\" not found in \"" + this._seqZip.zipFile.name + "\"" ) );
					else
					{
						var seq:Sequence = new Sequence();
						seq.filename = value;
						seq.sequenceUser = value;
						plasmid.sequence = seq;
					}
					break;
				
				case ATTACHMENT_FILENAME:
					var attachment:Attachment = new Attachment();
					attachment.fileName = value;
					attachment.entry = plasmid;
					plasmid.attachment = attachment;
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
				
				// backbone
				case BACKBONE:
					plasmid.backbone = value;
					break;
				
				// selection markers
				case SELECTION_MARKERS:
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
				
				// origin of replication
				case ORIGIN_OF_REPLICATION:
					plasmid.originOfReplication = value;
					break;
				
				// promoters
				case PROMOTERS:
					plasmid.promoters = value;
					break;
			}
		}
		
		public function get fields():ArrayCollection
		{
			return _fields;
		}
	}
}