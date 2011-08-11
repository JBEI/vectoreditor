package org.jbei.model.fields
{
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.jbei.Notifications;
	import org.jbei.model.EntryTypeField;
	import org.jbei.model.registry.Attachment;
	import org.jbei.model.registry.EntryFundingSource;
	import org.jbei.model.registry.FundingSource;
	import org.jbei.model.registry.Link;
	import org.jbei.model.registry.Name;
	import org.jbei.model.registry.SelectionMarker;
	import org.jbei.model.registry.Sequence;
	import org.jbei.model.registry.Strain;
	import org.jbei.model.save.EntrySet;
	import org.jbei.model.save.StrainSet;
	import org.jbei.model.util.ZipFileUtil;
	import org.jbei.view.EntryType;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.GridRow;

	public class StrainFields implements EntryFields
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
		public static const SEQUENCE_FILENAME:EntryTypeField = new EntryTypeField( SEQUENCE_FILENAME, "Sequence FileName", false ); 
		public static const ATTACHMENT_FILENAME:EntryTypeField = new EntryTypeField( ATTACHMENT_FILENAME, "Attachment FileName", false );
		public static const SELECTION_MARKERS:EntryTypeField = new EntryTypeField( SELECTION_MARKERS, "Selection Markers", false ); 
		public static const PARENTAL_STRAIN:EntryTypeField = new EntryTypeField( PARENTAL_STRAIN, "Parental Strain", false );
		public static const GENOTYPE_OR_PHENOTYPE:EntryTypeField = new EntryTypeField( GENOTYPE_OR_PHENOTYPE, "Genotype/Phenotype", false );
		public static const PLASMIDS:EntryTypeField = new EntryTypeField( PLASMIDS, "Plasmids", false );
		
		private var _fields:ArrayCollection;	// <EntryTypeField>
		private var _zipUtil:ZipFileUtil;
		private var _errors:ArrayCollection;
		private var _set:StrainSet;
		
		public function set sequenceZipFile( file:FileReference ) : void
		{
			_zipUtil = new ZipFileUtil( file );
		}
		
		public function set attachmentZipFile( file:FileReference ) : void
		{
		}
		
		public function get entrySet() : EntrySet
		{		
			return this._set;
		}
		
		public function StrainFields() 
		{
			_fields = new ArrayCollection();
			_errors = new ArrayCollection();
			_set = new StrainSet( EntryType.STRAIN );
			
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
			_fields.addItem( PARENTAL_STRAIN );
			_fields.addItem( GENOTYPE_OR_PHENOTYPE );
			_fields.addItem( PLASMIDS );
		}
		
		public function get fields() : ArrayCollection
		{
			return _fields;
		}
		
		public function extractFromRow( row:GridRow ) : Object
		{
			this._errors.removeAll();
			
			var strain:Strain = new Strain();
			
			for( var j:int = 0; j < this._fields.length; j += 1 )
			{
				var field:EntryTypeField = fields.getItemAt( j ) as EntryTypeField;
				var cell:GridCell = row.cellAt( j );
				
				if( cell.text.length == 0 )
				{
					if( field.required )
					{
						this._errors.addItem( new FieldCellError( cell, field.name + " is required and cannot be empty." ) );
					}
					continue;
				}
				else
				{
					extractField( field, cell, strain );
				}
			}
			
			return strain;
		}
		
		public function setToRow( currentRowIndex:int, currentRow:GridRow ) : Boolean 
		{
			var strain:Strain = this.entrySet.entries.getItemAt( 0 ) as Strain;
			
			for( var j:int = 0; j < this._fields.length; j += 1 )
			{
				var field:EntryTypeField = fields.getItemAt( j ) as EntryTypeField;
				var cell:GridCell = currentRow.cellAt( j );
				
				switch( field )
				{
					case PRINCIPAL_INVESTIGATOR:
						if( strain.entryFundingSources == null || strain.entryFundingSources.length == 0 )
							break;
						
						var source:EntryFundingSource = strain.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
						cell.text = source.fundingSource.principalInvestigator;
						break;
					
					case FUNDING_SOURCE:
						if( strain.entryFundingSources == null || strain.entryFundingSources.length == 0 )
							break;
						
						var entrySource:EntryFundingSource = strain.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
						cell.text = entrySource.fundingSource.fundingSource;
						break;
					
					case INTELLECTUAL_PROP_INFO:
						cell.text = strain.intellectualProperty;
						break;
					
					case BIO_SAFETY_LEVEL:
						cell.text = String(strain.bioSafetyLevel);
						break;
					
					case NAME:
						var names:ArrayCollection = strain.names;
						if( names == null || names.length == 0 )
							break;
						
						var namesStr:String = "";
						for( var i:int; i < names.length; i ++ )
						{
							var name:Name = names.getItemAt( i ) as Name;
							namesStr += name.name;
							if( i < names.length - 1 )
								namesStr += ",";
						}
						cell.text = namesStr;
						break;
					
					case ALIAS:
						cell.text = strain.alias;
						break;
					
					case KEYWORDS:
						cell.text = strain.keywords;
						break; 
					
					case SUMMARY:
						cell.text = strain.shortDescription;
						break;
					
					case NOTES:
						cell.text = strain.longDescription;
						break;
					
					case REFERENCES:
						cell.text = strain.references;
						break;
					
					case LINKS:
						var links:ArrayCollection = strain.links;
						if( links == null || links.length == 0 )
							break;
						
						var linkStr:String = "";
						for( var l:int; l < links.length; l ++ )
						{
							var link:Link = links.getItemAt( l ) as Link;
							linkStr += link.link;
							if( l < links.length - 1 )
								linkStr += ",";
						}
						cell.text = linkStr;
						break;
					
					case STATUS:
						cell.text = strain.status;
						break;
					
					case SEQUENCE_FILENAME:
						var seq:Sequence = strain.sequence;
						if( seq == null )
							break;
						cell.text = seq.filename;
						break;
					
					case ATTACHMENT_FILENAME:
						var attachment:Attachment = strain.attachment;
						if( attachment == null )
							break;
						cell.text = attachment.fileName;
						break;
					
					case SELECTION_MARKERS:
						var markers:ArrayCollection = strain.selectionMarkers;
						if( markers == null || markers.length == 0 )
							break;
						
						var markerStr:String = "";
						for( var markerIter:int = 0; markerIter < markers.length; markerIter += 1 )
						{
							var marker:SelectionMarker = markers.getItemAt( markerIter ) as SelectionMarker;
							markerStr += marker.name;
							if( markerIter < markers.length - 1 )
								markerStr += ",";
						}
						cell.text = markerStr;
						break;
					
					case PARENTAL_STRAIN:
						cell.text = strain.host;
						break;
					
					case GENOTYPE_OR_PHENOTYPE:
						cell.text = strain.genotypePhenotype;
						break;
					
					case PLASMIDS:
						cell.text = strain.plasmids;
						break;
				}
			}

			return true;
		}
		
		public function get errors() : ArrayCollection
		{
			return _errors;
		}
		
		private function createFundingSources( strain:Strain ) : void
		{
			if( strain.entryFundingSources && strain.entryFundingSources.length > 0 )
				return;

			var sources:ArrayCollection = new ArrayCollection();				// <EntryFundingSource>
			var fundingSource:FundingSource = new FundingSource();
			fundingSource.fundingSource = "";
			var newEntryFundingSource:EntryFundingSource = new EntryFundingSource();
			newEntryFundingSource.fundingSource = fundingSource;
			newEntryFundingSource.entry = strain;
			sources.addItem( newEntryFundingSource );
			strain.entryFundingSources = sources;
		}
		
		protected function extractField( field:EntryTypeField, cell:GridCell, strain:Strain ) : void
		{
			var value:String = cell.text;
			switch( field )
			{
				case PRINCIPAL_INVESTIGATOR:
					createFundingSources( strain );
					
					var source:EntryFundingSource = strain.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					source.fundingSource.principalInvestigator = value;
					break;
				
				case FUNDING_SOURCE:
					createFundingSources( strain );
					
					var entrySource:EntryFundingSource = strain.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					entrySource.fundingSource.fundingSource = value;
					break;
				
				case INTELLECTUAL_PROP_INFO:
					strain.intellectualProperty = value;
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
					}
					break;
				
				case NAME:
					var result:ArrayCollection = new ArrayCollection(); // <Name>
					var names:Array = value.split( /\s*, +\s*/ );
					for( var i:int = 0; i < names.length; i += 1 )
					{
						var nameStr:String = names[i];
						var name:Name = new Name();
						name.entry = strain;
						name.name = nameStr;
						result.addItem( name );
					}
					
					strain.names = result;
					break;
				
				case ALIAS:
					strain.alias = value;
					break;
				
				case KEYWORDS:
					strain.keywords = value;
					break; 
				
				case SUMMARY:
					strain.shortDescription = value;
					break;
				
				case NOTES:
					strain.longDescription = value;
					break;
				
				case REFERENCES:
					strain.references = value;
					break;
				
				case LINKS:
					var result2:ArrayCollection = new ArrayCollection(); // <Link>
					var links:Array = value.split( /\s*,+\s*/ );
					for( var linkIter:int = 0; linkIter < links.length; linkIter += 1 )
					{
						var linkStr:String = links[linkIter];
						var link:Link = new Link();
						link.link = linkStr;
						result2.addItem( link );
					}
					strain.links = result2;
					break;
				
				case STATUS:
					var comp:String = value.toLowerCase();
					// TODO : "magic" strings
					if( comp == "complete" || comp == "in progress" || comp == "planned" )
						strain.status = comp;
					else
						this._errors.addItem( new FieldCellError( cell, field.name + "'s value must be one of [Complete, In Progress, Planned]" ) );
					break;

				case SEQUENCE_FILENAME:
					if( !this._zipUtil && value.length > 0 )
						this._errors.addItem( new FieldCellError( cell, "Please upload sequence zip archive!" ) );
					else if( value.length > 0 && ( this._zipUtil && !this._zipUtil.containsFile( value ) ) )
						this._errors.addItem( new FieldCellError( cell, "File with name " + value + " not found in zip archive!" ) );
					else
					{
						var seq:Sequence = new Sequence();
						seq.filename = value;
						seq.sequenceUser = value;
						strain.sequence = seq;
					}
					break;
				
				case ATTACHMENT_FILENAME:
					var attachment:Attachment = new Attachment();
					attachment.fileName = value;
					strain.attachment = attachment;
					break;
				
				case SELECTION_MARKERS:
					var markers:ArrayCollection = new ArrayCollection();
					var markerStrings:Array = value.split( /\s*, +\s*/ );
					
					for( var markerIter:int = 0; markerIter < markerStrings.length; markerIter += 1 )
					{
						var marker:SelectionMarker = new SelectionMarker();
						marker.entry = strain;
						marker.name = markerStrings[markerIter];
						markers.addItem( marker );
					}
					strain.selectionMarkers = markers;
					break;
				
				case PARENTAL_STRAIN:
					strain.host = value;
					break;
				
				case GENOTYPE_OR_PHENOTYPE:
					strain.genotypePhenotype = value;
					break;
				
				case PLASMIDS:
					strain.plasmids = value;
					break;
				
				default:
					trace( "unhandled field for status: " + field ); 
			}
		}
	}
}
